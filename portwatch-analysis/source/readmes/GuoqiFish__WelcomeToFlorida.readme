# Xbox Scarlett compatibility probe

This directory contains a deliberately incomplete Windows-side probe for the
supplied Scarlett executable. It provides selected Xbox export names and a
DirectStorage adapter so initialization boundaries can be observed. It is not
an Xbox or GameOS emulator.

Build the probe DLLs with:

```powershell
.\compat\build.ps1
```

Run the executable under the diagnostic debugger with:

```powershell
.\compat\run-probe.ps1
```

An experimental command-list probe is available with:

```powershell
.\compat\run-probe.ps1 -NoopXboxCommandListExtensions
```

This wraps the native Windows command list, forwards its ordinary vtable calls,
and temporarily treats Xbox-only slots `+0x418` and `+0x420` as successful
no-ops. Their semantics are unknown, so this is a diagnostic experiment rather
than a correct implementation of those methods. It is intended to test whether
those calls are what poison `Close`; successful `Close` alone would still not
prove that rendering or presentation works.

An additional diagnostic probe can temporarily treat Xbox device slot `+0x278`
as a successful no-op:

```powershell
.\compat\run-probe.ps1 -NoopXboxCommandListExtensions -NoopXboxDeviceSlot278
```

The Xbox meaning of that device slot is unknown. This mode only tests whether
the native Windows method accidentally occupying the same vtable index is the
next startup blocker; it is not a device-method implementation.

An additional diagnostic mode keeps the observed 185 MiB XMem range as one
ordinary Windows reservation and skips the four observed placeholder-split
calls:

```powershell
.\compat\run-probe.ps1 -NoopXboxCommandListExtensions -NoopXboxDeviceSlot278 `
    -UseUnifiedXmemReservation -SkipObservedXmemPlaceholderSplits -FocusStartupVm
```

This mode is restricted to the observed request and five exact segment shapes.
It commits those segments inside one reservation so the host D3D12 runtime can
recognize a contiguous heap. The physical-page shim still uses CPU copy-in and
copy-out; this does not provide Xbox GPU aliases, cache coherency, or a complete
physical-memory implementation.

An experimental resource adapter can fill Xbox device slot `+0x428` for only
the observed startup buffer call:

```powershell
.\compat\run-probe.ps1 -NoopXboxCommandListExtensions -NoopXboxDeviceSlot278 `
    -UseUnifiedXmemReservation -SkipObservedXmemPlaceholderSplits `
    -EnableObservedXmemBufferResource -FocusStartupVm
```

It recognizes the 174 MiB buffer descriptor, the 11 MiB address offset, the
resource IID, null clear value, and initial-state sentinel seen at RVA
`0x1e8684c`. It finds the enclosing allocation with `VirtualQuery`, opens that
whole range as a D3D12 heap, maps Xbox flag `0x20000` away, and adds Windows'
required cross-adapter flag. The `0xffffffff` initial-state sentinel maps to
`COMMON` for this buffer. Unsupported descriptors return `E_NOTIMPL`; this is
not a general Xbox resource implementation. The Windows resource's GPU virtual
address differs from the Xbox address, and command-list address translation is
not implemented, so a successful creation alone will not demonstrate rendering.

An opt-in descriptor-heap diagnostic retries only the observed shader-visible
CBV/SRV/UAV heap request of 1,245,184 descriptors, and only after Windows
returns `E_INVALIDARG`:

```powershell
.\compat\run-probe.ps1 -NoopXboxCommandListExtensions -NoopXboxDeviceSlot278 `
    -UseUnifiedXmemReservation -SkipObservedXmemPlaceholderSplits `
    -EnableObservedXmemBufferResource -ClampObservedOversizedDescriptorHeap `
    -FocusStartupVm
```

The retry requests a 1,000,000-entry native heap and reports that physical size
through `GetDesc`. This is a startup experiment, not a complete Xbox heap
implementation; descriptor indices beyond the native heap remain unsupported.

The next diagnostic can continue past the single observed descriptor-handle
assertion at game RVA `0x1cf336c`:

```powershell
.\compat\run-probe.ps1 -NoopXboxDeviceSlot278 `
    -UseUnifiedXmemReservation -SkipObservedXmemPlaceholderSplits `
    -EnableObservedXmemBufferResource -ClampObservedOversizedDescriptorHeap `
    -FocusStartupVm -ContinueObservedDescriptorHeapMismatch
```

This option is off by default and only continues that first-chance `INT3` when
the target byte and stopped instruction pointer match the observed site. It is
for tracing later initialization only; it does not fix descriptor handles or
establish that rendering works. When `G:` is occupied by the existing network
share, `run-with-temporary-g-drive.ps1` preserves it on `T:` for the duration
of the probe and restores the original `G:` mapping in `finally`.

The latest startup trace shows that Xbox device slot `+0x230` reaches Windows
device slot 70 through the generic same-index thunk. Windows SDK slot 70 is
`AddToStateObject`, but the observed Xbox call passes startup records; D3D12
then treats one record as a COM state object and faults. The opt-in
`-NoopXboxDeviceSlot70` diagnostic skips that unknown operation and returns
`S_OK` so startup can be observed further. This does not implement the Xbox
operation and remains disabled by default; a later failure may reflect the
skipped work.

One additional, opt-in memory experiment handles only the exact observed
`XMemVirtualAlloc(NULL, 0x0b900000, 0x42000, 7, PAGE_NOACCESS)` request:

```powershell
.\compat\run-probe.ps1 -NoopXboxCommandListExtensions -NoopXboxDeviceSlot278 -AllowObservedXmemVaReservation
```

This translates that one call to a Windows `MEM_RESERVE` reservation with
`PAGE_NOACCESS`. It does not interpret Xbox attribute `7` or the extra `0x40000`
bit, and it supplies no committed pages, physical backing, GPU mapping, or
coherency. The environment gate is off by default and other `attributes=7`
requests still fail closed. This only tests whether startup gets past the
address-space reservation call.

To trace the virtual-memory setup and following device method without changing
their return values, use the focused breakpoint preset:

```powershell
.\compat\run-probe.ps1 -FocusStartupVm -NoopXboxCommandListExtensions -NoopXboxDeviceSlot278 -AllowObservedXmemVaReservation
```

This records arguments and return registers around the XMem and Windows memory
calls in the startup helper, then records the device slot `+0x428` call's raw
arguments, 0x40-byte configuration, IID, and output storage before the original
indirect call. A post-call HRESULT is available only if that call returns; the
current null slot faults as the original probe observed. It also records the
game's existing false-return checks. It replaces the broad default
breakpoint list for that run and stays under the debugger's 64-breakpoint
limit. The probe is passive: original calls, branches, and exceptions run.

The runner temporarily places the probe DLLs beside the executable, restores or
removes them in `finally`, and records hashes, logs, and cleanup status under
`compat/runs`. It refuses to start if another game instance is running. A probe
exit caused by an exception is diagnostic only; no exception is skipped.

## Current observed boundary

The DirectStorage self-test passes file and memory reads, queue submission,
completion status, events, and close-before-submit behavior. The game requires
the `G:` volume: without it, the path helper rejects `G:/appdata0.rpf` and the
game reaches its intentional `INT3` at executable RVA `0x2237178`. Temporarily
mapping `G:` to the game directory lets startup pass that boundary and issue
DirectStorage `OpenFile` requests for `appdata0.rpf`, `common.rpf`, `movies.rpf`,
`shaders.rpf`, and other archives. Those log entries establish that requests
were issued, not that all files were read or parsed successfully.

With the mapping in place, the game creates a native D3D12 device, several
command queues, and a command list. In run `20261125-143146-f24ed2a6`, the
command-list output pointer matches the object used by the later failing call.
At executable RVA `0x2478bcd`, its vtable slot `+0x48` points into
`D3D12Core.dll`; that call returns `E_FAIL` (`0x80004005`), and the game's own
check stops at `INT3` RVA `0x2478bd4`. The slot and HRESULT are consistent with
`ID3D12GraphicsCommandList::Close`, but the upstream cause has not been
established.

The same run hit all six prepared graphics breakpoints. The title first calls
command-list offsets `+0x420` and `+0x418`; both targets resolve inside
`D3D12Core.dll` and return `RAX=0xB`. This value is not evidence of success:
static inspection shows `+0x420` checks its second argument against `8`, while
the title passes `0x700000`, and its out-of-range path reports `E_FAIL` through
an internal error helper. The `+0x418` target is a thunk that adjusts `this`
and enters D3D12Core validation/error-reporting code. These findings show that
the native Windows command-list object does not implement the title's expected
semantics at those slots. They may be related to `Close` failing, but that
causal link still needs runtime error messages or deeper tracing.

Run `20261125-143146-f24ed2a6` also created a visible `sgaWindowClass` window
with client size 1924x1061 and title `Americas`. The probe did not capture its
pixels, so this does not establish that the game's splash artwork or animation
was rendered. The run stopped at the game's first-chance breakpoint without
skipping it. It confirmed probe DLL cleanup, removal of the temporary `G:`
mapping, and an unchanged executable SHA-256
(`E95020B2FA4A721DB3DF59FDECF75621730AC559D8835252F6C3B658D5A08993`).

The diagnostic breakpoints record the target addresses, arguments, return
registers, and `Close` result without changing them. They leave the game's
`INT3` in place. Run `20261125-144449-d14417d2` confirmed that the optional
Windows D3D12 debug layer can be enabled and that an `ID3D12InfoQueue1`
callback registers successfully. However, the layer wraps the game's `+0x420`
and `+0x418` command-list slots; the `+0x418` call then causes a first-chance
access violation in `d3d12SDKLayers.dll+0x3697b` before the game's `Close`
breakpoint. No InfoQueue messages were recorded. The previous run without the
debug layer did not hit that access violation and continued to `Close`, so the
debug-layer run is not a valid substitute for the normal graphics path.

Run `20261125-144449-d14417d2` also saved a 1924x1061 BMP at
`debug.log.window.bmp`, but its pixels were uniformly white. The capture method
used the window DC, which did not expose the D3D12 composition. The debugger now
captures the desktop pixels under the visible game client area instead; the
next run must validate whether that shows rendered content. Neither the window
existing nor the current white capture establishes that the splash artwork or
animation was rendered.

Static inspection found a root-level `xbs_splash.png`, a large `movies.rpf`,
and imports from `Bink2Scarlett.dll` including `BinkOpenWithOptions`,
`BinkDoFrame`, and `BinkNextFrame`. The two recent runs loaded
`Bink2Scarlett.dll` and requested `G:\movies.rpf`, but did not log a Bink call
or prove that movie data was read or decoded. The PNG is present as a possible
platform splash asset; its presence does not show that the game's own runtime
displays it.

Before that breakpoint, the Windows Game Runtime reports that the app's display
name and publisher values do not satisfy its `ms-resource:` URI pattern. This is
evidence of missing packaged-app metadata in the loose-exe environment; a causal
link to the `INT3` has not been established.

The `XMemVirtualAlloc` shim currently translates only the exact observed
startup allocation signatures. Xbox 64 KiB and 2 MiB page flags are stripped
where observed, and Xbox graphics protection bits are reduced to ordinary
Windows CPU protections. These calls therefore supply CPU-backed virtual
memory only; they do not emulate Xbox physical pages, GPU aliases, graphics
coherency, or device memory. Unknown signatures still fail explicitly.

The graphics path remains incomplete. Returning a native Windows command list
does not provide a proven implementation of the Xbox-specific vtable slots the
title calls. A compatible graphics layer will also need resource creation,
submission, synchronization, and presentation behavior before a splash can be
shown.

Run `20261125-150529-4680b9c8` enabled the experimental command-list proxy
without the D3D12 debug layer. The game called the proxy's Xbox slots `+0x420`
and `+0x418`; both returned `S_OK`. Its following command-list `Close` call at
slot `+0x48` also returned `S_OK`, and the game passed the HRESULT check that
previously stopped startup. It then called device slot `+0x278` at executable
RVA `0x2478de4`. The title passes `RDX=2`; on current Windows SDKs vtable
index 79 is `ID3D12Device11::CreateSampler2`, whose first argument is treated
as a descriptor pointer by D3D12Core. The core then faults
reading address `0x2` at `D3D12Core.dll+0x1ee7d` with `0xC0000005`. This confirms
an Xbox/Windows device-vtable ABI mismatch; the Xbox meaning of slot `+0x278`
remains unknown.

Run `20261125-151742-587a29a7` enabled the diagnostic no-op for device slot
`+0x278`. It returned `S_OK`, and the game passed that HRESULT check. Startup
then requested `XMemVirtualAlloc(NULL, 0x0b900000, 0x42000, 7, PAGE_NOACCESS)`.
The generic shim rejected this unsupported combination and the game reached a
first-chance breakpoint at executable RVA `0x19f4f58`. The run still did not
record command-queue submission or Present. DLL cleanup succeeded and the game
executable hash was unchanged. The narrowly gated reservation experiment above
is intended to test the next boundary; it does not imply that this allocation's
Xbox physical-memory semantics are implemented.

Run `20261125-152538-7805b68f` enabled that exact reservation experiment. It
successfully reserved the requested 185 MiB as ordinary `MEM_RESERVE` plus
`PAGE_NOACCESS` (returned address `0x1a20000000`). The game then created many
native command lists and called device slot `+0x270` before slot `+0x278`. Its
Windows interpretation is `ID3D12Device10::CreateReservedResource2`, but the
observed Xbox call has `RDX=0`, a calculated integer in `R8D`, and small enum-like
values in `R9D`; D3D12Core raised a first-chance C++ exception at this
Windows/Xbox ABI mismatch. At that time, the run did not record the call's
return value. The runner was updated to record breakpoints immediately before
and after the `+0x270` call (`0x247abd8` and `0x247abde`) without changing its
behavior.

Run `20261125-153815-ceed481d` repeated the probe with those observation
breakpoints. The `+0x270` call again raised a first-chance C++ exception inside
D3D12Core and returned `E_INVALIDARG` (`0x80070057`). The game continued to
device slot `+0x278` (still an explicitly experimental no-op), then completed
the exact 185 MiB virtual-address reservation. It subsequently reached its
first-chance breakpoint at executable RVA `0x19f4f58`; the cause of that
breakpoint remains unidentified. Thus the `+0x270` call is an ABI mismatch, but
this run does not establish it as the startup stop. No physical-page mapping,
`ExecuteCommandLists`, or `Present` was logged. The visible `sgaWindowClass`
window was 1924x1061, but desktop capture failed with error 5, so there is still
no visual evidence of the game's splash. Cleanup succeeded: the temporary
`G:` mapping and compatibility DLLs were removed, and the game executable hash
remained unchanged (`E95020B2FA4A721DB3DF59FDECF75621730AC559D8835252F6C3B658D5A08993`).

Static follow-up corrected the earlier RVA interpretation: the D3D12
initialization path is at executable RVA `0x2478440`, not `0x2477440`.
At `0x2478e22` it calls `0x5c5ff00`; `0x2478e27` tests the returned `AL`,
and zero branches to the shared false-return exit at `0x24787a7`. That exit
clears `ESI` and returns zero, but it is shared by several failure paths, so
its hit alone does not identify the cause. The caller at `0x19f4f54` then
tests `AL` and executes the game's original `INT3` at `0x19f4f58` when the
result is zero. The next probe records values before and after both tests and
at the success, false-exit, and outer-caller paths. All breakpoints are
passive; the game's `INT3` and exceptions remain untouched. The later run
`20261125-172750-933aee85` also captured the raw arguments to the failing
device slot `+0x428` call, as described below.

Run `20261125-172750-933aee85` added a passive dump immediately before the
device slot `+0x428` call. The queue-creation logs again show successful native
queue creation; the recorded `AL=0` is the startup helper's false return, not a
queue-sequence result. At the failing call, `RDX` points 11 MiB into the
185 MiB XMem range and the 0x40-byte configuration contains a size of
`0x0ae00000` (174 MiB). The call passes `R9=0xffffffff`, stack argument 5 as
zero, and IID `696442BE-A72E-4059-BC79-5B5C98040FAD` (`ID3D12Resource`). The
raw descriptor dump also confirms that `+0x04` is not initialized at this call
site, so its observed `0x26ca` value is incidental and must not be interpreted
as a field. The logged reservation base and GPU address put the address 11 MiB
into the 185 MiB range, leaving exactly 174 MiB. The output slot contains an
uninitialized stack value before the call.

The passive probe leaves device slot `+0x428` null. The original indirect call
therefore still faults at address zero; no `ExecuteCommandLists`, `Present`,
Bink decode, or rendered splash was observed. The visible game window was
1924x1061, but desktop capture again failed with error 5. The temporary `G:`
mapping and deployed DLLs were removed, and the executable SHA-256 was
unchanged. A correct implementation still needs to translate the Xbox resource
creation contract and preserve the XMem backing/address relationship; the
observed call cannot be forwarded as a standard Windows `CreatePlacedResource`
call without that translation.

The XMem shim logs successful physical-page allocations and map/unmap calls,
including the logical page-array range, backing-block offset, target address,
and whether the selected pages are contiguous. The focused runtime observation
below confirms the CPU-side virtual layout; the shim still uses ordinary CPU
memory and copies, so this does not establish GPU visibility or provide a valid
D3D12 resource object.

Run `20261125-161519-8c66db65` confirmed that the helper's initial 185 MiB
`XMemVirtualAlloc` request returned a non-null address, but its caller still
received `AL=0` and reached the original `INT3`. The log did not include
breakpoints inside the helper, so it cannot identify which later operation
failed. Static disassembly of executable RVA `0x1e86440` shows why placeholder
handling is now the leading hypothesis: after reserving the region with Xbox
allocation flags `0x42000`, the helper immediately calls `VirtualFree` with
`0x8002` (`MEM_RELEASE | MEM_PRESERVE_PLACEHOLDER`) to split that region. The
opt-in shim at that stage translated the initial request to ordinary
`MEM_RESERVE`, which does not create a Windows placeholder; a failed split
would branch directly to the helper's false-return path. This was a static
inference until the focused runtime probe below.

Windows documents `MEM_RESERVE_PLACEHOLDER` creation through `VirtualAlloc2`
and `MEM_RELEASE | MEM_PRESERVE_PLACEHOLDER` as the placeholder-splitting
operation. The focused probe records the `VirtualFree` returns before changing
the shim. Later XMem calls use additional Xbox-specific flags and still need
separate translation; a successful placeholder split would not establish
working physical or GPU memory.

Run `20261125-164149-151f5425` verified the placeholder hypothesis. The exact
185 MiB request now uses `VirtualAlloc2(MEM_RESERVE | MEM_RESERVE_PLACEHOLDER)`;
the game's subsequent 10 MiB `VirtualFree(..., 0x8002)` returned true, and the
helper passed its next checks. The next exact XMem request replaces that 10 MiB
placeholder (`allocation=0x20406000`, `attributes=0x27`,
`protection=0x1004`). At this point the shim still returned
`ERROR_CALL_NOT_IMPLEMENTED`, so initialization reached the same original
`INT3` without entering physical-page mapping. No `ExecuteCommandLists`,
`Present`, or Bink decode was recorded. The game window existed, but desktop
capture failed with error 5, so this run provides no splash-image evidence.
The temporary `G:` mapping and deployed DLLs were removed, and the executable
hash was unchanged.

The opt-in shim now handles only that exact replacement request by checking
that `VirtualQuery` reports a reserved region with the same base and size, then
calling `VirtualAlloc2(MEM_RESERVE | MEM_REPLACE_PLACEHOLDER)`. It drops the
Xbox `0x20400000` page flag and translates the observed graphics protection to
`PAGE_READWRITE`; it does not commit memory or emulate Xbox physical pages,
GPU aliases, or coherency. `test-placeholder.ps1` runs native controls for
ordinary-reservation versus placeholder splitting and checks four Windows
placeholder-replacement flag combinations without reading or writing the
reserved ranges. It also calls the built XMem shim through the exact observed
reserve, split, and replacement sequence to verify the integration.

Run `20261125-174336-fe911c00` exercised the physical-page logging. The game
reserved 185 MiB at `0x1dd6fa80000`, allocated 2,960 64 KiB pages, and mapped
them into five contiguous virtual segments covering that full range. The
page-array indices wrap in virtual-address order at the 147 MiB point. At the
startup `+0x428` call, `RDX=0x1dd70580000`, exactly 11 MiB after the reservation
base, and the descriptor size is `0x0ae00000`, exactly the 174 MiB remaining.
This corrects the earlier arithmetic error: the address difference is
`0x00b00000`, not `0x00a00000`.

The two additional passive `+0x428` breakpoints at executable RVAs `0x193dff8`
and `0x193e2d4` were not reached before startup hit the original null-slot
access violation at address zero. No `ExecuteCommandLists`, `Present`, Bink
decode, or game-rendered splash was observed. Window capture still failed with
an undifferentiated error 5, which does not identify which capture step failed.
Cleanup succeeded: the temporary `G:` mapping and deployed DLLs were removed,
no game process remained, and the executable SHA-256 was unchanged
(`E95020B2FA4A721DB3DF59FDECF75621730AC559D8835252F6C3B658D5A08993`).

Run `20261125-182651-a54c7aec` used the unified reservation mode and skipped the
four split calls. All five XMem segments committed inside one allocation base,
then the game reached the same null `+0x428` slot because the resource adapter
was still disabled for that run. No presentation or splash was observed, and
cleanup restored all deployed DLLs and removed `G:`.

The standalone `test-xmem-unified.ps1` and `test-xmem-d3d12.ps1` checks now cover
the resource adapter's exact startup shape. A direct call through the proxy's
`+0x428` slot returns `S_OK`; the 174 MiB placed resource maps to the expected
CPU address at offset 11 MiB. Windows assigns it a different GPU virtual address
(`0x5870000` in the self-test), so command-list address translation may still be
needed. This opt-in adapter supports only the observed buffer descriptor,
`0xffffffff` state sentinel, null clear value, and IID; texture and other resource
forms return `E_NOTIMPL`. It has not yet been exercised in the game process.

The two current texture experiments are enabled together with:

```powershell
.\compat\run-with-temporary-g-drive.ps1 -TranslateObservedAllocationFlags `
    -EnableObservedCreateCommittedResource3
```

`-TranslateObservedAllocationFlags` retries only the observed slot `+0xc8`
allocation query after Windows returns `UINT64_MAX`, using a local copy of the
3840x2160 RGBA8 descriptor with flags `0x00300005` translated to `0x5`.
`-EnableObservedCreateCommittedResource3` maps the observed Xbox device slot
`+0x3f8` to Windows `ID3D12Device11` vtable slot 76 (`CreateCommittedResource3`)
instead of invalid native index 127. It forwards the original descriptor first;
only the exact observed heap, UAV layout, clear value, resource IID, and texture
shape can retry with flags `0x5`. `test-xmem-d3d12.ps1` validates both slot
adapters, descriptor immutability, and near-miss rejection.

Run `20261125-221035-7b8d3771` passed the allocation-info assertion and created
the 4K texture through both observed `+0x3f8` calls (`E_INVALIDARG` with Xbox
flags, then `S_OK` with the translated copy). It next stopped at the game's
assertion at RVA `0x247af2d`: the computed range is `0x04000000`, above the
allowed `0x001fffff`. No `ExecuteCommandLists`, `Present`, or Bink decode was
logged, so the game's splash is still not visible. Cleanup restored `G:`,
removed temporary `T:` and probe DLLs, and verified the executable hash was
unchanged. The focused trace now includes passive checks around that assertion.

The focused `20261125-222538-42894c03` trace confirms that the arena callback
registered at RVA `0x247ad64` was not invoked by either `+0x3f8`
`CreateCommittedResource3` call. Its 64 MiB cursor and global base remained
zero at the `0x247af2d` assertion. The callback itself aligns allocations to
64 KiB and advances that cursor, but the current Windows committed-resource
adapter does not participate in that allocator. This is evidence of a missing
allocation bridge; it is not evidence that a standalone heap should mutate the
game's cursor.

The callback thunk at RVA `0x56a2a60` expects an allocation size and attribute
mask plus the live arena descriptor and an internal hook record. The descriptor
is stack-backed, and the hook record's layout and lifetime have not been
verified for calls originating in the D3D12 proxy. The proxy therefore does
not call the thunk directly or move its cursor. `D3D12ConfigureVirtualMemoryX`
currently receives a 32-byte zeroed block with a runtime integer at offset `+4`;
no evidence links that block to the arena callback.

`test-xbox-texture-arena.ps1` builds and runs an independent D3D12 placement
check. On this PC, a 3840x2160 RGBA8 render-target/UAV texture reports
`0x1fe0000` bytes with `0x10000` alignment. Two fit in a native 64 MiB DEFAULT
heap at offsets `0` and `0x1fe0000`, leaving `0x40000`; both
`CreatePlacedResource2` calls succeed. `CreateHeap` with the observed
`ALLOW_DISPLAY` flag returns `E_INVALIDARG`, while the equivalent committed
resource call with translated resource flags succeeds. Wrapping an ordinary
64 MiB `VirtualAlloc` region with `OpenExistingHeapFromAddress` succeeds, but
placing the same texture in that diagnostic heap returns `E_INVALIDARG`.
Therefore a real DEFAULT-heap placement is viable on this host, but the test
does not connect it to the game's callback or prove the Xbox display-heap
semantics. No game run was made for this self-test-only change.

Run `20261125-232203-50a37d2a` recovered from a trace configuration regression:
unified mode now always includes the four placeholder-split call sites and
the launcher rejects breakpoint sets larger than 64. The category `0x80`
registration was present at `0x247ad69`, but neither texture triggered the
dispatcher or the callback in the baseline PC adapter.

Run `20261125-234233-d36979d9` enabled `-EnableObservedTextureArenaHook`.
The first two matching committed resources call the title's exported XMem
dispatcher on the creating thread. Its original callback obtains one aligned
64 MiB CPU range and accounts for two `0x1fe0000`-byte allocations at offsets
`0` and `0x1fe0000`. The original assertion sees `0x40000` bytes remaining
and passes. The CPU range and the Windows textures are separate; this startup
probe does not model shared physical backing or texture recreation. The next
failure was `XboxBvhBuilder` rejecting the root signature serializer result.

Run `20261126-000428-5854c301` also enabled `-EnableObservedBvhPipelineBridge`.
That bridge retries the observed BVH root signature serialization without the
two Xbox-only flags and forwards the observed Xbox compute pipeline entry to
the matching Windows method. The run completed 15 root signatures and 48
compute pipelines before another BVH pipeline creation hit an access violation
inside the NVIDIA driver. Neither run reached presentation. Both restored
the temporary drive mappings and probe DLLs and verified the EXE hash.

```powershell
.\compat\run-with-temporary-g-drive.ps1 -TranslateObservedAllocationFlags `
    -EnableObservedCreateCommittedResource3 -EnableObservedTextureArenaHook `
    -EnableObservedBvhPipelineBridge
```

The independent XCL cross-check was built from upstream commit
`082944135cd2b96288470a595861fa608eee08dc` (`cargo build --release --locked -p xcl`).
Run it with `run-with-xcl.ps1 -XclExe <path to xcl.exe>`. This uses XCL's own
loader and does not change the system's drive mappings. The XCL data root
must be outside the title directory: inside it, the guest file routing
redirects the loader's temporary TLS DLLs and produces error 126.

The first successful XCL run is archived under `runs/20261126-xcl-render-validation`.
It reported 2,455 presents and exited normally at the 180-second limit. Frame
129 shows the title's own `PLAYER1 (A)` prompt. This verifies actual title
rendering on the PC, but the sampled frames do not show the opening animation.
