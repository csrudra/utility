import json,os,subprocess,time,urllib.request,urllib.parse,concurrent.futures,pathlib,re
ROOT=pathlib.Path('/tmp/pw/ghdata'); ROOT.mkdir(exist_ok=True)
slugs=json.load(open('/tmp/pw/repo_meta.json'))
pairs=sorted((v['nameWithOwner'].split('/',1)[0],v['nameWithOwner'].split('/',1)[1]) for v in slugs.values())
token=subprocess.check_output(['gh','auth','token'],text=True).strip()
HEAD={'Authorization':f'Bearer {token}','User-Agent':'Arena-PortWatch-analysis','Accept':'application/vnd.github+json'}
def api(path,raw=False):
 url='https://api.github.com'+path
 h=HEAD.copy()
 if raw:h['Accept']='application/vnd.github.raw'
 req=urllib.request.Request(url,headers=h)
 for attempt in range(4):
  try:
   with urllib.request.urlopen(req,timeout=30) as r:
    data=r.read()
    return (200,data,dict(r.headers))
  except urllib.error.HTTPError as e:
   if e.code in (403,429) and 'Retry-After' in e.headers:
    time.sleep(min(int(e.headers.get('Retry-After','1')),10)); continue
   return (e.code,e.read(),dict(e.headers))
  except Exception as e:
   if attempt==3:return (0,str(e).encode(),{})
   time.sleep(1+attempt)
 return (0,b'',{})
def fname(o,r,suffix): return ROOT/f'{o}__{r}{suffix}'
def job(p):
 o,r=p
 base=f'/repos/{urllib.parse.quote(o)}/{urllib.parse.quote(r)}'
 out={}
 # README raw
 code,data,h=api(base+'/readme',raw=True)
 if code==200:
  fname(o,r,'.readme').write_bytes(data)
  out['readme']=len(data)
 else: out['readme']=code
 # recent commits metadata
 code,data,h=api(base+'/commits?per_page=100')
 if code==200:
  commits=json.loads(data)
  fname(o,r,'.commits.json').write_bytes(data)
  out['commits']=len(commits)
  out['last']=commits[0]['commit']['author']['date'] if commits else None
  out['truncated']=('Link' in h and 'rel="next"' in h.get('Link',''))
 else: out['commits']=code
 return o+'/'+r,out
results={}
with concurrent.futures.ThreadPoolExecutor(max_workers=10) as ex:
 for i,(slug,out) in enumerate(ex.map(job,pairs),1):
  results[slug]=out
  if i%100==0: print('done',i,flush=True)
json.dump(results,open(ROOT/'fetch_index.json','w'),indent=2)
print('total',len(results),'readme ok',sum(v.get('readme')==200 or isinstance(v.get('readme'),int) and v.get('readme')>199 for v in results.values()),'commits ok',sum(isinstance(v.get('commits'),int) and v.get('commits')>=0 for v in results.values()))
