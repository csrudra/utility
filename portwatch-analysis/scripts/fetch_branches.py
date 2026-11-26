import json,subprocess,urllib.parse,concurrent.futures,pathlib
meta=json.load(open('repo_meta.json'))
D=json.load(open('portwatch-vi/data/tracker.json'))
keys=set()
for sec in ['efforts','tools','candidates']:
 for x in D[sec]:
  if x.get('repo'):keys.add(x['repo'].lower())
# add selected ignored perf forks
for s in ['LowBacon/HybridGt','Itsbatt/victory-unified','vitutu1/victory-perf','zsy-miao/victory-perf','Beaver6513/ztrx-lowvram','edsuuu/VI-BR-PORT','Joaco9020/mangrove','Pavl3000/victory-speed','Prime1997/xcl-compat-fixes','wardevsa/victory-pc-layer','mravatins/victory-nv','Lilpez/xcl-ztrx','WarmMilkCodes/crimson-layer','ifBars/VICauseway','ezbyDev/victory-amd','myokex/victory-amd','ZSlayerHQ/victory-world-runtime','ad3lre/victory-nvidia-8gb','proneonn/Vertex']:
 keys.add(s.lower())
slugs=[meta[k]['nameWithOwner'] for k in keys if k in meta]
def job(s):
 o,r=s.split('/',1)
 p=subprocess.run(['gh','api',f'/repos/{urllib.parse.quote(o)}/{urllib.parse.quote(r)}/branches?per_page=100','--jq','.[].name'],capture_output=True,text=True)
 return s,(p.stdout.splitlines() if p.returncode==0 else ['ERROR:'+p.stderr.strip()[:100]])
res={}
with concurrent.futures.ThreadPoolExecutor(max_workers=10) as ex:
 for s,b in ex.map(job,slugs):res[s]=b
json.dump(res,open('branches.json','w'),indent=2)
for s,b in sorted(res.items()):
 interesting=[x for x in b if any(k in x.lower() for k in ['perf','fps','fast','speed','nvidia','amd','8gb','vram','mem','crash','fix','bench','ray','main','master','ccs','rx'])]
 if interesting:print(f'{s:65} {", ".join(interesting[:12])}')
