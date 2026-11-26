import json,subprocess,urllib.parse,concurrent.futures,re,pathlib
meta=json.load(open('repo_meta.json'))
branches=json.load(open('branches.json'))
targets=[]
for slug,bs in branches.items():
 default=meta.get(slug.lower(),{}).get('defaultBranchRef',{}).get('name','main') or 'main'
 for b in bs:
  if b==default or b.startswith('ERROR'):continue
  if any(k in b.lower() for k in ['perf','fps','speed','fast','fix','nvidia','amd','vram','mem','crash','rx','integration','batch','low','bench','8gb','compat']):
   targets.append((slug,default,b))
# Add known branches explicitly
for x in [('xcl-dev/xcl','main','nvidia-dev'),('xcl-dev/xcl','main','amd-dev'),('JozefDeTremmerie/CCS03','main','ccs03'),('JozefDeTremmerie/CCS03','main','perf/next'),('Belobug/VIctory-Belobug-AMD','main','rx9070xt')]:
 if x not in targets:targets.append(x)
seen=set();T=[]
for x in targets:
 if x in seen:continue
 seen.add(x);T.append(x)
print('comparisons',len(T))
def job(t):
 slug,base,head=t;o,r=slug.split('/',1)
 path=f'/repos/{urllib.parse.quote(o)}/{urllib.parse.quote(r)}/compare/{urllib.parse.quote(base,safe="")}...{urllib.parse.quote(head,safe="")}'
 p=subprocess.run(['gh','api',path,'--jq','{status:.status,ahead_by:.ahead_by,commits:[.commits[]|{sha:.sha,message:.commit.message}],files:[.files[]?.filename]}'],capture_output=True,text=True)
 if p.returncode:return t,{'error':p.stderr.strip()[:200]}
 try:return t,json.loads(p.stdout)
 except:return t,{'error':'parse'}
res={}
with concurrent.futures.ThreadPoolExecutor(max_workers=8) as ex:
 for t,d in ex.map(job,T):res['|'.join(t)]=d
json.dump(res,open('branch_compares.json','w'),indent=2)
pat=re.compile(r'(?i)(perf|fps|frame|speed|fast|optimi|crash|hang|device|watchdog|memory|vram|ram|oom|leak|thread|cache|pipeline|pso|descriptor|texture|stream|sync|barrier|fence|wave|nvidia|amd|bv[h|h]|copy|upload|budget|allocation|pool|fault|guard|race|deadlock|timeout|stutter|stub|warm)')
for k,d in sorted(res.items()):
 if 'error' in d:continue
 msgs=[c['message'].splitlines()[0] for c in d.get('commits',[])]
 hits=[m for m in msgs if pat.search(m)]
 if hits:
  print(f'\n### {k} ahead={d.get("ahead_by")} status={d.get("status")} relevant={len(hits)}/{len(msgs)}')
  for m in hits[:25]:print(' -',m[:220])
