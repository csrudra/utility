import json,os,subprocess,time,urllib.request,urllib.parse,concurrent.futures,pathlib
ROOT=pathlib.Path('ghdata')
idx=json.load(open(ROOT/'fetch_index.json'))
token=subprocess.check_output(['gh','auth','token'],text=True).strip()
HEAD={'Authorization':f'Bearer {token}','User-Agent':'Arena-PortWatch-analysis','Accept':'application/vnd.github+json'}
def api(path):
 req=urllib.request.Request('https://api.github.com'+path,headers=HEAD)
 for attempt in range(4):
  try:
   with urllib.request.urlopen(req,timeout=30) as r:return r.read(),dict(r.headers)
  except urllib.error.HTTPError as e:
   if e.code in (403,429) and 'Retry-After' in e.headers:
    time.sleep(min(int(e.headers.get('Retry-After','1')),10));continue
   return b'[]',dict(e.headers)
  except Exception:
   if attempt==3:return b'[]',{}
   time.sleep(1+attempt)
 return b'[]',{}
def job(slug):
 o,r=slug.split('/',1); base=f'/repos/{urllib.parse.quote(o)}/{urllib.parse.quote(r)}'
 p=ROOT/f'{o}__{r}.commits.json'
 try: allc=json.loads(p.read_text()) if p.exists() else []
 except:allc=[]
 # preserve page1; fetch later pages until short or max10
 for page in range(2,11):
  data,h=api(base+f'/commits?per_page=100&page={page}&since=2026-11-15T00:00:00Z')
  try:arr=json.loads(data)
  except:arr=[]
  if not isinstance(arr,list) or not arr:break
  # avoid duplicates by sha
  seen={c['sha'] for c in allc}
  allc.extend(c for c in arr if c.get('sha') not in seen)
  if len(arr)<100:break
 # filter to since date and sort
 allc=[c for c in allc if c.get('commit',{}).get('author',{}).get('date','')>='2026-11-15']
 allc.sort(key=lambda c:c.get('commit',{}).get('author',{}).get('date',''),reverse=True)
 (ROOT/f'{o}__{r}.commits_all.json').write_text(json.dumps(allc))
 return slug,len(allc)
slugs=list(idx.keys())
# copy page1 for non-truncated too
for s in slugs:
 o,r=s.split('/',1);p=ROOT/f'{o}__{r}.commits.json';q=ROOT/f'{o}__{r}.commits_all.json'
 if p.exists() and not q.exists():
  try:arr=json.loads(p.read_text());q.write_text(json.dumps([c for c in arr if c.get('commit',{}).get('author',{}).get('date','')>='2026-11-15']))
  except:pass
todo=[s for s in slugs if idx[s].get('truncated')]
res={}
with concurrent.futures.ThreadPoolExecutor(max_workers=8) as ex:
 for i,(s,n) in enumerate(ex.map(job,todo),1):
  res[s]=n
  if i%50==0:print('done',i,flush=True)
json.dump(res,open(ROOT/'all_commits_index.json','w'),indent=2)
print('truncated repos processed',len(res),'total commits in those',sum(res.values()))
