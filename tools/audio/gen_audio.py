#!/usr/bin/env python3
"""Genera por código la música, las voces y los efectos de Bug de Familia. Sin servicios externos ni muestras.

Uso: python3 tools/audio/gen_audio.py [carpeta_del_proyecto] [--solo-sfx]
Necesita numpy, scipy y ffmpeg con libvorbis. La semilla de cada pista es su número.
"""
import json
import os
import subprocess
import sys
from multiprocessing import Pool

import numpy as np
from scipy.signal import butter, lfilter

SR = 22050
_ARGS = [a for a in sys.argv[1:] if a.startswith("--")]
_PATHS = [a for a in sys.argv[1:] if not a.startswith("--")]
ROOT = _PATHS[0] if _PATHS else "."
SFX_ONLY = "--solo-sfx" in _ARGS
SCALES = {
    "frigio_dom": [0, 1, 4, 5, 7, 8, 10],
    "dorico": [0, 2, 3, 5, 7, 9, 10],
    "pentatonica": [0, 3, 5, 7, 10],
    "hijaz": [0, 1, 4, 5, 7, 9, 10],
    "menor_arm": [0, 2, 3, 5, 7, 8, 11],
    "mixolidio": [0, 2, 4, 5, 7, 9, 10],
    "pelog": [0, 1, 3, 7, 8],
    "hexatonica": [0, 2, 4, 7, 9, 10],
}
STATES = {
    "dia": dict(count=30, bpm=(70, 94), scales=["dorico", "pentatonica", "mixolidio", "hexatonica"], intensity=0.3, drums=0.35),
    "noche": dict(count=20, bpm=(52, 70), scales=["dorico", "pelog", "pentatonica", "hijaz"], intensity=0.2, drums=0.0),
    "tension": dict(count=18, bpm=(84, 112), scales=["frigio_dom", "hijaz", "menor_arm", "pelog"], intensity=0.6, drums=0.5),
    "combate": dict(count=17, bpm=(130, 164), scales=["frigio_dom", "menor_arm", "hijaz"], intensity=1.0, drums=1.0),
    "festival": dict(count=15, bpm=(108, 134), scales=["mixolidio", "hexatonica", "pentatonica"], intensity=0.7, drums=0.9),
}
ZONES = ["bosque", "barrio_jubilado", "barrio_mohocrata", "tierra_de_nadie"]
ZONE_LEAD = {"bosque": "flauta", "barrio_jubilado": "acordeon", "barrio_mohocrata": "marimba", "tierra_de_nadie": "laud"}
RHYTHMS = [
    [1, 0, 0, 1, 0, 0, 1, 0],
    [1, 0, 1, 1, 0, 1, 0, 0],
    [1, 0, 0, 1, 0, 1, 0, 1, 0, 0, 1, 0],
    [1, 1, 0, 1, 0, 0, 1, 0, 1, 0, 0, 0],
    [1, 0, 0, 0, 1, 0, 1, 0],
]


def hz(midi):
    return 440.0 * 2.0 ** ((midi - 69) / 12.0)


def pluck(freq, seconds, rng, damp=0.996):
    n = int(seconds * SR)
    period = max(2, int(SR / freq))
    burst = rng.uniform(-1, 1, period)
    out = np.zeros(n)
    x = np.zeros(n)
    x[: min(period, n)] = burst[: min(period, n)]
    # Karplus-Strong como filtro recursivo.
    a = np.zeros(period + 2)
    a[0] = 1.0
    a[period] = -0.5 * damp
    a[period + 1] = -0.5 * damp
    out = lfilter([1.0], a, x)
    return out * np.minimum(1.0, (n - np.arange(n)) / (0.02 * SR))


def marimba(freq, seconds, rng):
    t = np.arange(int(seconds * SR)) / SR
    return np.exp(-t * 7) * (np.sin(2 * np.pi * freq * t) + 0.35 * np.sin(2 * np.pi * freq * 3.93 * t) * np.exp(-t * 18))


def flauta(freq, seconds, rng):
    t = np.arange(int(seconds * SR)) / SR
    vibrato = 1 + 0.006 * np.sin(2 * np.pi * rng.uniform(4.5, 6) * t)
    phase = 2 * np.pi * np.cumsum(freq * vibrato) / SR
    breath = lowpass(rng.normal(0, 1, t.size), 3000) * 0.06
    env = np.minimum(1, t / 0.06) * np.minimum(1, (seconds - t) / 0.08)
    return env * (np.sin(phase) + 0.25 * np.sin(2 * phase) + breath)


def acordeon(freq, seconds, rng):
    t = np.arange(int(seconds * SR)) / SR
    wave = sum(((2 * ((f * t) % 1) - 1) for f in (freq, freq * 1.004, freq * 0.996))) / 3
    env = np.minimum(1, t / 0.03) * np.minimum(1, (seconds - t) / 0.05)
    return lowpass(wave, 2200) * env


def laud(freq, seconds, rng):
    return pluck(freq, seconds, rng, 0.994) + 0.4 * pluck(freq * 2.003, seconds, rng, 0.99)


LEADS = {"flauta": flauta, "acordeon": acordeon, "marimba": marimba, "laud": laud}


def lowpass(x, cutoff):
    b, a = butter(2, cutoff / (SR / 2))
    return lfilter(b, a, x)


def tom(freq, rng):
    n = int(0.35 * SR)
    t = np.arange(n) / SR
    phase = 2 * np.pi * np.cumsum(freq * (1 + 1.2 * np.exp(-t * 30))) / SR
    return np.sin(phase) * np.exp(-t * 11) + rng.normal(0, 1, n) * np.exp(-t * 60) * 0.25


def shaker(rng):
    n = int(0.07 * SR)
    t = np.arange(n) / SR
    noise = rng.normal(0, 1, n)
    return (noise - lowpass(noise, 4000)) * np.exp(-t * 55) * 0.5


def clap(rng):
    n = int(0.14 * SR)
    t = np.arange(n) / SR
    noise = rng.normal(0, 1, n)
    return (noise - lowpass(noise, 900)) * np.exp(-t * 30) * 0.6


def drone(freq, total, rng):
    t = np.arange(total) / SR
    wobble = 0.6 + 0.4 * np.sin(2 * np.pi * rng.uniform(0.05, 0.15) * t + rng.uniform(0, 6))
    wave = np.sin(2 * np.pi * freq * t) + 0.5 * np.sin(2 * np.pi * freq * 1.5 * t) + 0.3 * np.sin(2 * np.pi * freq * 2.003 * t)
    return wave * wobble


def place(mix, sound, at, gain):
    start = int(at)
    if start >= mix.size:
        return
    end = min(mix.size, start + sound.size)
    mix[start:end] += sound[: end - start] * gain


def motif(rng, scale, length):
    degree = rng.integers(0, len(scale))
    notes = []
    for _ in range(length):
        degree = int(np.clip(degree + rng.choice([-2, -1, -1, 0, 1, 1, 2, 3]), -4, len(scale) + 5))
        octave, step = divmod(degree, len(scale))
        notes.append(scale[step] + 12 * octave if rng.random() > 0.18 else None)
    return notes


def track(entry):
    index = entry["n"]
    state = STATES[entry["state"]]
    rng = np.random.default_rng(index * 7919 + 11)
    scale = SCALES[entry["scale"]]
    bpm = entry["bpm"]
    step = 60.0 / bpm / 2.0
    seconds = entry["duration"]
    total = int(seconds * SR)
    mix = np.zeros(total)
    key = int(rng.integers(45, 57))
    lead = LEADS[ZONE_LEAD[entry["zone"]]]
    a = motif(rng, scale, 16)
    b = motif(rng, scale, 16)
    form = [a, b, a, list(reversed(b))] if rng.random() < 0.5 else [a, a, b, a]
    if entry["state"] != "combate":
        mix += drone(hz(key - 12), total, rng) * (0.12 + 0.08 * state["intensity"])
    rhythm = RHYTHMS[int(rng.integers(0, len(RHYTHMS)))]
    bass_pattern = RHYTHMS[int(rng.integers(0, len(RHYTHMS)))]
    pos = 0
    bar = 0
    while pos * step < seconds:
        notes = form[bar % len(form)]
        for i, note in enumerate(notes):
            at = (pos + i) * step * SR
            density = 0.55 + 0.45 * state["intensity"]
            if note is not None and rng.random() < density:
                length = step * (2.2 if entry["state"] in ("noche", "dia") else 1.3)
                gain = 0.42 + rng.uniform(-0.06, 0.06)
                place(mix, lead(hz(key + 12 + note), length, rng), at, gain)
            if bass_pattern[i % len(bass_pattern)] and state["intensity"] >= 0.3:
                root = scale[0 if bar % 2 == 0 else min(3, len(scale) - 1)]
                place(mix, pluck(hz(key - 12 + root), step * 3, rng, 0.992), at, 0.4)
            if state["drums"] > 0:
                if rhythm[i % len(rhythm)] and rng.random() < state["drums"]:
                    place(mix, tom(int(rng.choice([95, 120, 150])), rng), at, 0.5)
                if i % 2 == 1 and rng.random() < state["drums"] * 0.8:
                    place(mix, shaker(rng), at, 0.5)
                if entry["state"] == "festival" and i % 4 == 2:
                    place(mix, clap(rng), at, 0.45)
        pos += len(notes)
        bar += 1
    mix = lowpass(mix, 7500)
    fade = np.minimum(1.0, np.arange(total) / (0.3 * SR)) * np.minimum(1.0, (total - np.arange(total)) / (1.8 * SR))
    mix *= fade
    peak = float(np.max(np.abs(mix)))
    mix = mix / peak * 0.72
    return write(mix, os.path.join(ROOT, "audio/music", entry["file"]), "1")


def write(samples, path, quality):
    pcm = (np.clip(samples, -1, 1) * 32767).astype(np.int16).tobytes()
    command = ["ffmpeg", "-y", "-loglevel", "error", "-f", "s16le", "-ar", str(SR), "-ac", "1", "-i", "-",
               "-c:a", "libvorbis", "-q:a", quality, path]
    subprocess.run(command, input=pcm, check=True)
    return float(np.max(np.abs(samples)))


VOWELS = {"a": (800, 1200), "e": (450, 1900), "i": (280, 2300), "o": (480, 850), "u": (320, 800), "y": (300, 1750), "ö": (420, 1500)}


def syllable(f0, vowel, consonant, seconds, contour, rng):
    n = int(seconds * SR)
    t = np.arange(n) / SR
    pitch = f0 * (1 + contour * (t / seconds - 0.5))
    phase = np.cumsum(pitch) / SR
    glottal = 2 * (phase % 1) - 1
    f1, f2 = VOWELS[vowel]
    out = bandpass(glottal, f1, 90) + 0.6 * bandpass(glottal, f2, 130) + 0.2 * bandpass(glottal, 2800, 220)
    env = np.minimum(1, t / 0.012) * np.minimum(1, (seconds - t) / 0.03)
    out = out * env
    if consonant == "s":
        noise = rng.normal(0, 1, n)
        out += (noise - lowpass(noise, 4000)) * np.exp(-t * 45) * 0.5
    elif consonant == "t":
        out += rng.normal(0, 1, n) * np.exp(-t * 160) * 0.8
    elif consonant == "r":
        out *= 0.75 + 0.25 * np.sign(np.sin(2 * np.pi * 28 * t))
    elif consonant == "m":
        out = lowpass(out, 500 + 3000 * np.minimum(1, t[-1] / 0.1))
    return out


def bandpass(x, center, width):
    low = max(40.0, center - width) / (SR / 2)
    high = min(SR / 2 - 100, center + width) / (SR / 2)
    b, a = butter(2, [low, high], btype="band")
    return lfilter(b, a, x)


def voice_profile(index):
    rng = np.random.default_rng(index * 104729 + 3)
    names = list(VOWELS)
    vowels = list(rng.choice(names, size=int(rng.integers(3, 6)), replace=False))
    consonants = list(rng.choice(["s", "t", "r", "m", ""], size=int(rng.integers(2, 5)), replace=False))
    return dict(id="perfil_%02d" % index, vowels=[str(v) for v in vowels], consonants=[str(c) for c in consonants],
                speed=float(rng.uniform(0.075, 0.17)), contour=float(rng.uniform(-0.35, 0.45)),
                f0=float(rng.uniform(95, 230)), syllables=int(rng.integers(5, 12)))


def voice(job):
    profile, take = job
    rng = np.random.default_rng(hash_text(profile["id"]) + take)
    parts = []
    for _ in range(profile["syllables"]):
        seconds = profile["speed"] * rng.uniform(0.8, 1.35)
        parts.append(syllable(profile["f0"] * rng.uniform(0.9, 1.15), str(rng.choice(profile["vowels"])),
                              str(rng.choice(profile["consonants"])), seconds, profile["contour"], rng))
        if rng.random() < 0.15:
            parts.append(np.zeros(int(0.06 * SR)))
    audio = np.concatenate(parts)
    audio = audio / max(float(np.max(np.abs(audio))), 1e-6) * 0.8
    return write(audio, os.path.join(ROOT, "audio/voices", "%s_%d.ogg" % (profile["id"], take)), "2")


def hash_text(text):
    return sum((i + 1) * ord(c) for i, c in enumerate(text))


def _sfx_step(seed, duration, low, high, gain):
    rng = np.random.default_rng(seed)
    n = int(duration * SR)
    t = np.arange(n) / SR
    noise = rng.normal(0, 1, n)
    thump = np.sin(2 * np.pi * rng.uniform(low, high) * t) * np.exp(-t * rng.uniform(35, 55))
    body = lowpass(noise, rng.uniform(500, 1200)) * np.exp(-t * rng.uniform(22, 38))
    click = (noise - lowpass(noise, 2500)) * np.exp(-t * rng.uniform(70, 120)) * 0.25
    audio = thump * 0.7 + body * 0.35 + click
    audio = audio / max(float(np.max(np.abs(audio))), 1e-6) * gain
    path = os.path.join(ROOT, "audio/sfx", "paso_%02d.ogg" % seed)
    write(audio, path, "3")
    return dict(file="res://audio/sfx/paso_%02d.ogg" % seed, kind="step", duration=round(duration, 3))


def build_sfx():
    os.makedirs(os.path.join(ROOT, "audio/sfx"), exist_ok=True)
    entries = []
    for i in range(1, 7):
        duration = 0.16 + (i % 3) * 0.03
        low = 55.0 + i * 7.0
        high = 110.0 + i * 11.0
        entries.append(_sfx_step(i, duration, low, high, 0.55))
    return entries


def _load_library():
    path = os.path.join(ROOT, "data/audio/library.json")
    if os.path.isfile(path):
        with open(path, "r", encoding="utf8") as src:
            return json.load(src)
    return dict(origin="tools/audio/gen_audio.py, Claude, sin servicios externos", tracks=[], voices=[], takes=3)


def main():
    sfx = build_sfx()
    if SFX_ONLY:
        data = _load_library()
        data["sfx"] = sfx
        data["origin"] = "tools/audio/gen_audio.py, Claude, sin servicios externos"
        with open(os.path.join(ROOT, "data/audio/library.json"), "w", encoding="utf8", newline="\n") as out:
            json.dump(data, out, ensure_ascii=False, indent=1)
            out.write("\n")
        print("sfx", len(sfx))
        return
    rng = np.random.default_rng(2026)
    entries = []
    n = 0
    for state, spec in STATES.items():
        for i in range(spec["count"]):
            n += 1
            zone = ZONES[i % len(ZONES)] if state in ("dia", "noche") else "cualquiera"
            lead_zone = zone if zone != "cualquiera" else ZONES[i % len(ZONES)]
            entries.append(dict(n=n, file="pista_%03d.ogg" % n, state=state, zone=lead_zone if zone != "cualquiera" else lead_zone,
                                any_zone=zone == "cualquiera", intensity=spec["intensity"],
                                bpm=int(rng.integers(*spec["bpm"])), scale=str(rng.choice(spec["scales"])),
                                duration=float(rng.uniform(34.0, 46.0)), layers=4 if spec["drums"] else 3,
                                crossfade=2.5 if state != "combate" else 1.0))
    with Pool(2) as pool:
        peaks = pool.map(track, entries, chunksize=5)
        profiles = [voice_profile(i) for i in range(1, 41)]
        voice_peaks = pool.map(voice, [(p, t) for p in profiles for t in range(3)], chunksize=10)
    data = dict(origin="tools/audio/gen_audio.py, Claude, sin servicios externos",
                tracks=[dict(file="res://audio/music/" + e["file"], state=e["state"], zone=e["zone"],
                             any_zone=e["any_zone"], intensity=e["intensity"], bpm=e["bpm"], scale=e["scale"],
                             duration=round(e["duration"], 2), layers=e["layers"], crossfade=e["crossfade"]) for e in entries],
                voices=[p["id"] for p in profiles], takes=3, sfx=sfx)
    with open(os.path.join(ROOT, "data/audio/library.json"), "w", encoding="utf8", newline="\n") as out:
        json.dump(data, out, ensure_ascii=False, indent=1)
        out.write("\n")
    print("pistas", len(entries), "pico máx", max(peaks), "voces", len(voice_peaks), "pico", max(voice_peaks), "sfx", len(sfx))


if __name__ == "__main__":
    main()
