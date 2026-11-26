# Lessons learned

Method notes kept while bringing a retail Scarlett title up under an HLE runtime. No game content,
no binaries, no title identifiers. Each item should stop a repeat or save a run.

## Method

**How to read an HLE failure.** Classify before you touch code. Ask in this order.

1. **Unimplemented export.** Evidence: a `[STUB] <dll>!<func> first called from <mod>+<RVA> ->
   returning <code>` line, `called_stubs` non-empty in `report.json`, and the title's own assert
   immediately after with the *same* code in `rax` (`0x80004001`). Fix = implement the export
   against observed arguments, not against the header.
2. **Silent refusal inside a QueryInterface.** Evidence is negative: crash with `rax=0x80004002`
   (`E_NOINTERFACE`), `unknown_iids: []`, `called_stubs: []`, and **no log line naming the
   interface**. The refusal sits in the title's call path but nothing logged it, so runs get spent
   guessing. Fix = log every refusal with the IID and caller RVA *before* theorising.
3. **Title-internal assert on a value it derived.** Evidence: `0x80000003` (int3), `called_stubs`
   empty, no HLE call between the last log line and the crash, registers holding derived data
   (`r8=0x7EFEFEFEFEFEFEFF` is a filled/uninitialised memory sentinel), and a vtable RVA appearing
   twice on the stack. Nothing is missing here. The title computed a value our host made wrong.
   Hunt the calling convention or the returned handle, not a missing export.
4. **Environment precondition.** Evidence: `report.json.environment` carries an `error`/`warning`
   (no DXC, no system runtime), or the same binary hash passes in one session and fails in another
   (`0x887A0022` over SSH, clean on the interactive desktop). The failure moves with the
   environment, not with the runtime.

**Silence is not success.** A stub that returns `S_OK` and a stub that returns a refusal are
indistinguishable in a log that only records the return value. A no-timeout message wait is the
worst shape: no crash, no progress, thread parked, looks identical to a slow boot. Rule: every
refusal path logs the call, arguments in hex, caller RVA and return code, at WARN or above, before
returning. A refusal you cannot see gets debugged twice. A refusal you logged gets fixed once.

**"The crash moved" is only evidence if the sequence and timestamp also moved.** Our run 5 to 6
changed RVA **and** the log sequence gained a factory acceptance and a device callback **and** the
stop came later in time. That is progress. An RVA change with an identical log sequence is ASLR,
allocator ordering or a thread race: rerun twice on the same commit and compare line by line
before claiming a fix worked.

## Traps we have actually hit

**Lab path leaked into a publish doc.** Symptom: a doc carried the real package directory name in a
`Path` row, in a repo about to go public. Root cause: docs written against real lab paths and
copied verbatim; sanitising was per-file and by eye. Check: grep the *tracked tree and full history*
for the package name, vendor strings, drive letters and user-home paths, and allow only `<LAB>`,
`<VM>`, `<vendor-package>`.

**Repo went public with licence text uncommitted.** Symptom: the public repo showed GPL-derived
patches with no `COPYING` beside them, though the file existed on disk. Root cause: publication was
verified by looking at the folder, not at the git tree. "It is in my working copy" is not "it is
published". Check: `git status --short` empty, `git ls-tree -r HEAD` for every licence file, then
fetch the raw URL anonymously.

**Git CRLF corrupted `.patch` files.** Symptom: `git am` rejects hunks that applied locally, or a
one-line patch arrives as a whole-file rewrite. Root cause: `core.autocrlf` rewrote line endings at
checkout, so the patch bytes no longer matched the upstream blob. Check: `.gitattributes` with
`*.patch -text` and `*.diff -text`; verify by cloning fresh and running `git apply --check`.

**Guest disk reverted on snapshot.** Symptom: payload staged and verified, snapshot taken, next
start has no payload, and the previous run's log exists only in the VM. Root cause: snapshot/start
restored an earlier disk image; a snapshot is not a save. Check: after every start, list the guest
paths you need *before* running, and pull logs host-side immediately.

**SSH session 0 is not the interactive desktop.** Symptom: swapchain creation fails with
`0x887A0022` and GameInput fails with a device error, only over SSH; the same build passes 30/30 on
the desktop. Root cause: session 0 has no desktop or window station, so both are correct refusals,
not porting bugs. Check: read `environment` and `d3d12.presents` first; run presentation through a
scheduled task with an interactive logon type.

**A "fix" that duplicated an upstream function.** Symptom: a local patch applies on the frozen
baseline but not on current upstream, and the stub count had already fallen from 30 to 8 on its
own. Root cause: a shim was written for a call upstream had already implemented; the base drifted
under it. Check: grep upstream HEAD for the export before writing anything, keep local patches in a
`baseline-only/` folder when upstream owns the symbol, and enforce one owner per export.

**`D:` was the Windows install ISO.** Symptom: `mkdir D:\lab\...` reported no error, later steps
found nothing at the path. Root cause: `D:` was the mounted install media, read-only, not scratch
space. Check: enumerate volumes before choosing a path, assert the directory exists after every
`mkdir`, and fail loudly on a non-empty `$LASTEXITCODE`.

## Environment hypotheses need environment proof

**Missing dump directory: three tests, two nulls.** We hypothesised the title asserted because the
dump directory did not exist. Test 1 (`mkdir`) failed silently: the drive was the Windows install ISO
(DriveType 5, ESD-ISO, 0 bytes free), so the directory was never created and the run proved nothing.
Test 2 (change the drive letter with `Set-CimInstance`) also returned nothing and the volume stayed
put, another null test that looked like disproof. The real answer was in the runtime's own config:
that drive is already mounted into the game folder, so the console path resolves there and needs no
guest drive at all.

1. Before testing a filesystem hypothesis, prove the path exists and is writable, and print that
   evidence in the run log.
2. A silent failure (a `mkdir` on read-only media, a CIM call that returns nothing) is not a
   negative result.
3. Read the emulator's mount table before changing the guest's.
4. Prefer the layer that already models the platform (mounts/VFS) over guest surgery.

## Crash-time probing

Six items from one int3, all verified during lab runs.

1. **A decoded instruction beats a register heuristic.** Two explanations competed for the same
   int3: device-info strings versus a crash-reporter registry. Decoding the function settled it.
   The nearby strings were adjacent, not causal.
2. **Assert messages lie by omission.** The int3 was `assert(count != 0)` on a vector that was empty
   because a lookup returned 0. The assert was a consequence, not the fault. Always ask what made
   the checked value zero before reading the assert text as a diagnosis.
3. **Measure the runtime value, do not infer it.** One probe run
   (`XCL_CRASH_PROBE=addr:len,reg`) turned three guesses into facts: the registry count was 1, not 0
   as inferred, and its single entry was all zeros.
4. **Probe with ReadProcessMemory, not an internal readable() map.** The first probe reported a
   valid `.data` page as unreadable and produced a false negative.
5. **Verify the address arithmetic before believing a probe.** One run read `0x600` bytes off
   because an address was typed short, and the "code bytes" it printed looked like evidence.
6. **Null tests must prove their precondition.** A silent `mkdir` on read-only media made a
   hypothesis look falsified when it had never been tested.

## Two-agent disagreement

When static analysis of a function and a register-pattern heuristic disagree, the function decode
wins. Keep the heuristic as a secondary hypothesis only, and label it as one.

## Checks before every run

1. Binary SHA-256 and size recorded host-side. No hash, no run.
2. Previous run's log and `report.json` pulled host-side and archived, non-empty.
3. Guest payload listed and re-pushed if absent; runtime `--version` matches the intended build.
4. No snapshot taken after staging; snapshots only from a clean boot, contents verified after start.
5. Compiler present: no missing-DXC error in `environment`, both compiler DLLs at the expected path.
6. Runtime hash and build profile match the intended build, static CRT, no runtime DLL in the game folder.
7. Expected first call written down (name, arguments, caller RVA) so that silence is detectable.
8. Expected next failure written down with its taxonomy item, so a different failure is not mistaken for progress.
9. Environment probed: adapter, feature level, wave lanes, interactive session, network state.
10. Stop at the first failure. No retry, no patch, no rebase, no snapshot in the same run.

## Reporting rules

- **Verified** = we observed it and an artifact exists. **Reported** = someone else said it; name the
  project, file and commit. **Inferred** = our reasoning; state the premise.
- Never promote a label. A reported claim stays reported until we reproduce it. An inference never
  becomes a sentence with no label in a later rewrite.
- Evidence is a SHA-256, an exact log line with its timestamp, a module plus RVA, a `report.json`
  field or a capture. Commit subjects, star counts, store pages and "should work" are not evidence.
- Every claim names the artifact it came from; the artifact lives host-side, not only in chat.
- Never in a public repo: game binaries or assets, extracted shaders/textures/audio, the leaked
  package name or any mirror, keys or decryption material, credentials or VM ids, absolute host
  paths, machine or user names, third-party code without a compatible licence, any "playable" claim
  without a frame.
- Absolute paths become `<LAB>` and `<VM>` in anything published. A claim with no artifact is
  deleted, not softened.
