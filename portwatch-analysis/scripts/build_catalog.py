import json,pathlib,re,csv,collections,hashlib
ROOT=pathlib.Path('ghdata')
meta=json.load(open('repo_meta.json'))
D=json.load(open('portwatch-vi/data/tracker.json'))
group={};gpu={}
for sec in ['efforts','tools','candidates','ignored']:
 for x in D[sec]:
  r=x.get('repo')
  if not r:continue
  k=r.lower();group.setdefault(k,[]).append(sec+(':'+x.get('tier','') if sec=='efforts' else ''))
  if x.get('gpu'):gpu[k]=','.join(x['gpu'])
cats={
 'fps': re.compile(r'(?i)\b(fps|frame.?time|fpsbox|performance|perf|speed|faster|slow(er)?|optimi[sz]|stutter|hitch|bottleneck|benchmark|throughput|latency|warm(ing)?|pipeline worker|thread|parallel|AVX2|hash|cache|batch|coalesc|join(ed|ing)?|queue|async|relay|thin|worker pool|reuse|lookup|index|fast|copy plain|card step|gpu timing|framelog|meter|submit)\b'),
 'crash': re.compile(r'(?i)\b(crash|hang|freeze|deadlock|device (loss|removal|removed)|TDR|watchdog|timeout|fault|exception|panic|invalid|refus|overflow|out.of.bounds|use.after.free|UAF|race|sync|fence|barrier|guard|lifetime|wait|device|removal|faults|debug layer|DRED|crashed|dropped|drop|skip|black|flicker|stall|abort|loop|bounds|clamp|validator|validation|device lost)\b'),
 'ram': re.compile(r'(?i)\b(memory|RAM|VRAM|allocation|allocator|heap|pool|budget|OOM|out of memory|resident|evict|page|mapping|mapped|commit|snapshot|copy.?back|texture|mip|BCPack|stream|upload|staging|detile|tiled|placed|budget|pressure|video memory|shared memory|private memory|paging)\b'),
}
fixverb=re.compile(r'(?i)\b(fix|fixed|repair|avoid|prevent|reduce|cut|save|skip|reuse|cache|defer|delay|move|move|batch|join|coalesc|spread|parallel|thread|warm|precompile|prebuild|index|hash|guard|bound|clamp|crop|cap|trim|evict|release|free|flush|handle|recover|restore|resolve|merge|rewrite|remove|off|on|default|measure|report|log|track|split|defer|isolate|retain|keep|switch|fallback|retry|alternate|limit|increase|decrease|widen|shrink|optimi[sz]|speed|faster|slower|stutter|crash|hang|freeze|loss|deadlock|timeout|watchdog|fault|panic|invalid|refus|overflow|leak|race|OOM|out of memory|device removal)\b')
num=re.compile(r'(?:\d+(?:[.,]\d+)?\s*(?:ms|fps|GB|MB|KiB|%|frames?|draws?|threads?|times?)|\d+\s*(?:->|→|to)\s*\d+)')
rows=[];seen=set()
for f in ROOT.glob('*.commits_all.json'):
 key=f.name[:-len('.commits_all.json')].replace('__','/',1).lower()
 # filename encoding may have underscores; resolve by matching meta slug from stems
 stem=f.name[:-len('.commits_all.json')]
 slug=None
 for k,v in meta.items():
  o,r=v['nameWithOwner'].split('/',1)
  if f'{o}__{r}'==stem:slug=v['nameWithOwner'];break
 if not slug:continue
 try:cs=json.loads(f.read_text())
 except:continue
 for c in cs:
  msg=c.get('commit',{}).get('message','').splitlines()[0].strip()
  if not msg:continue
  labels=[name for name,p in cats.items() if p.search(msg)]
  if not labels:continue
  # Include if a fix verb, numeric measurement, or strong crash/perf term
  strong=re.search(r'(?i)\b(fix|crash|hang|freeze|deadlock|device removal|watchdog|out of memory|OOM|use.after.free|overflow|out.of.bounds|optimi[sz]|speedup|faster|memory|VRAM|FPS|frame.?time|stutter)\b',msg)
  if not (strong or (fixverb.search(msg) and num.search(msg))):continue
  sha=c.get('sha','')
  if (slug,sha) in seen:continue
  seen.add((slug,sha))
  date=c.get('commit',{}).get('author',{}).get('date','')
  rows.append({
   'repo':slug,'group':';'.join(group.get(slug.lower(),['unlisted'])),
   'gpu_hint':gpu.get(slug.lower(),''),'sha':sha,'date':date,
   'categories':';'.join(labels),'message':msg,
   'url':f'https://github.com/{slug}/commit/{sha}'
  })
rows.sort(key=lambda r:(r['repo'].lower(),r['date']),reverse=False)
with open('portwatch_fix_catalog.csv','w',newline='',encoding='utf-8') as g:
 w=csv.DictWriter(g,fieldnames=['repo','group','gpu_hint','sha','date','categories','message','url']);w.writeheader();w.writerows(rows)
# unique by repo-independent normalized message
uniq=collections.defaultdict(list)
for r in rows:
 norm=re.sub(r'(?i)\b(?:[0-9a-f]{7,40})\b','HASH',r['message'])
 norm=re.sub(r'\s+',' ',norm).strip().lower()
 norm=re.sub(r'[^a-z0-9 %µ\-./:;=_]+','',norm)
 uniq[norm].append(r)
urows=[]
for norm,items in uniq.items():
 # category union
 catsu=sorted({c for x in items for c in x['categories'].split(';')})
 reps=sorted(items,key=lambda x:x['date'],reverse=True)
 urows.append({'count':len(items),'categories':';'.join(catsu),'representative':reps[0]['message'],'repos':';'.join(sorted({x['repo'] for x in items})),'latest_date':reps[0]['date'],'sha':reps[0]['sha'],'url':reps[0]['url']})
urows.sort(key=lambda x:(-x['count'],x['categories']))
with open('portwatch_unique_fixes.tsv','w',newline='',encoding='utf-8') as g:
 w=csv.DictWriter(g,fieldnames=['count','categories','representative','repos','latest_date','sha','url'],delimiter='\t');w.writeheader();w.writerows(urows)
print('matching commits',len(rows),'unique messages',len(urows),'repos',len({r['repo'] for r in rows}))
print('\nTop duplicated fix messages:')
for u in urows[:30]:print(u['count'],u['categories'],u['representative'][:180])
