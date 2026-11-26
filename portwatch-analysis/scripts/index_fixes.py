import json,re,pathlib,collections,glob,os
ROOT=pathlib.Path('ghdata')
meta=json.load(open('repo_meta.json'))
D=json.load(open('portwatch-vi/data/tracker.json'))
group={}
for sec in ['efforts','tools','candidates','ignored']:
 for x in D[sec]:
  if x.get('repo'):group.setdefault(x['repo'].lower(),[]).append(sec+':'+x.get('name',x.get('tier',x.get('status',''))))
terms={
 'fps':5,'frame time':6,'frametime':6,'stutter':5,'optimize':4,'optimisation':4,'optimization':4,'performance':3,'speedup':5,'faster':4,'bottleneck':4,'benchmark':3,
 'crash':5,'device removal':8,'device removed':8,'hang':5,'deadlock':5,'timeout':4,'watchdog':6,'tdr':6,'race condition':6,'use-after-free':6,'uaf':6,'leak':5,'assert':2,'panic':4,'divide by zero':5,
 'ram':4,'vram':7,'memory':3,'allocation':3,'allocator':4,'resident':4,'evict':5,'budget':4,'low memory':8,'8gb':7,'16gb':5,'out of memory':8,'oom':8,'gpu memory':6,'heap':4,'pool':3,
 'thread':3,'multithread':6,'worker':4,'parallel':4,'queue':3,'async':4,'lock':3,'mutex':3,'barrier':3,'fence':3,
 'shader':2,'pipeline':3,'pso':5,'cache':4,'compile':2,'dxil':3,'spirv':3,'spir-v':3,'descriptor':4,'root signature':5,'meshlet':5,'cull':4,
 'texture':2,'stream':3,'bcpack':5,'bc7':4,'bc1':3,'upload':3,'copy':2,'decompress':3,'mip':4,
 'sync':3,'present':3,'swapchain':4,'command list':4,'command queue':5,'submit':3,'flush':3,'gpu':1,
 'nvidia':2,'amd':2,'rdna':3,'dlss':4,'fsr':5,'xess':4,'ray tracing':2,'dxr':3,
}
wordpat=re.compile(r'(?i)\b('+'|'.join(re.escape(t) for t in sorted(terms,key=len,reverse=True))+r')\b')
perfre=re.compile(r'(?i)\b(perf|performance|fps|frame.?time|speed|optimi[sz]|faster|stutter|benchmark|throughput|latency|crash|hang|freeze|deadlock|watchdog|tdr|device removal|device lost|memory|ram|vram|allocation|leak|oom|budget|stream|cache|thread|queue|async|shader|pipeline|pso|descriptor|meshlet|cull|texture|bcpack|mip|sync|present|swapchain|fence|barrier|submit|command list|command queue|dlss|fsr|8 ?gb|16 ?gb)\b')
rows=[]
snips=collections.defaultdict(list)
for key,m in meta.items():
 slug=m['nameWithOwner']; o,r=slug.split('/',1); base=ROOT/f'{o}__{r}'
 rf=base.with_suffix('.readme'); cf=pathlib.Path(str(base)+'.commits.json')
 text=''
 if rf.exists():text=rf.read_text(errors='replace')
 heads=[]
 try:heads=[c['commit']['message'].splitlines()[0] for c in json.loads(cf.read_text())] if cf.exists() else []
 except:pass
 combined=text+'\n'+'\n'.join(heads)
 score=sum(terms[t.lower()]*len(wordpat.findall('')) for t in [])
 # weighted distinct terms, plus occurrence bonus (cap)
 found=collections.Counter(x.lower() for x in wordpat.findall(combined))
 score=sum(terms[t]*min(n,5) for t,n in found.items())
 # snippets: README lines and commit headlines
 for line in text.splitlines()+heads:
  if perfre.search(line) and len(snips[slug])<80:
   snips[slug].append((('README' if line in text.splitlines() else 'COMMIT'),line.strip()[:500]))
 rows.append((score,slug,m.get('diskUsage'),','.join(group.get(key,[]))[:100],m.get('primaryLanguage') and m['primaryLanguage']['name'],len(found),len(heads)))
rows.sort(reverse=True)
json.dump({'snips':snips},open('fix_snippets.json','w'),indent=2,ensure_ascii=False)
open('fix_rank.tsv','w').write('score\trepo\tkb\tgroup\tlang\tdistinct\tcommits\n'+'\n'.join('\t'.join(map(str,x)) for x in rows)+'\n')
print('top 120')
for x in rows[:120]:print('\t'.join(map(str,x)))
