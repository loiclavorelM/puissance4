import json, os, wave, sys
OUTDIR = sys.argv[3] if len(sys.argv) > 3 else '.'
os.makedirs(OUTDIR, exist_ok=True)
from piper import PiperVoice, SynthesisConfig
voice = PiperVoice.load(sys.argv[1])
cfg = SynthesisConfig(length_scale=float(sys.argv[2]))
for s in json.load(open('script.json')):
    with wave.open(os.path.join(OUTDIR, f"vo_{s['id']}.wav"), 'wb') as w:
        voice.synthesize_wav(s['vo'], w, syn_config=cfg)
    with wave.open(os.path.join(OUTDIR, f"vo_{s['id']}.wav")) as w:
        print(s['id'], round(w.getnframes()/w.getframerate(), 2))
