"""Gera toda a trilha e os efeitos sonoros do jogo por síntese (sem samples de terceiros).

Uso: python tools/generate_audio.py
Saída: assets/audio/*.wav  (32 kHz, mono, 16 bits; o Godot comprime na importação)

Tudo é original e livre para uso comercial: nada vem de bancos de som.
"""
from pathlib import Path

import numpy as np
from scipy.io import wavfile
from scipy.signal import butter, fftconvolve, lfilter

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "assets" / "audio"
SR = 32000
RNG = np.random.default_rng(7)


# ---------------------------------------------------------------- utilidades

def t_axis(seconds: float) -> np.ndarray:
    return np.arange(int(seconds * SR)) / SR


def note(name: str) -> float:
    names = {"C": 0, "C#": 1, "D": 2, "D#": 3, "E": 4, "F": 5, "F#": 6, "G": 7, "G#": 8, "A": 9, "A#": 10, "B": 11}
    pitch, octave = name[:-1], int(name[-1])
    return 440.0 * 2 ** ((names[pitch] + 12 * (octave - 4) - 9) / 12)


def lowpass(x: np.ndarray, hz: float, order: int = 2) -> np.ndarray:
    b, a = butter(order, hz / (SR / 2), "low")
    return lfilter(b, a, x)


def highpass(x: np.ndarray, hz: float, order: int = 2) -> np.ndarray:
    b, a = butter(order, hz / (SR / 2), "high")
    return lfilter(b, a, x)


def bandpass(x: np.ndarray, lo: float, hi: float) -> np.ndarray:
    b, a = butter(2, [lo / (SR / 2), hi / (SR / 2)], "band")
    return lfilter(b, a, x)


def env(n: int, attack: float, decay: float) -> np.ndarray:
    t = np.arange(n) / SR
    a = np.clip(t / max(attack, 1e-4), 0, 1)
    return a * np.exp(-t / decay)


def fast_reverb(x: np.ndarray, mix: float = 0.25, decay: float = 1.6) -> np.ndarray:
    """Reverb por convolução com ruído decaindo (rápido para faixas longas)."""
    n = int(SR * decay)
    ir = RNG.normal(0, 1, n) * np.exp(-np.arange(n) / SR * (6.9 / decay))
    ir = lowpass(ir, 4500)
    ir /= np.sqrt(np.sum(ir ** 2))
    wet = np.pad(fftconvolve(x, ir), (0, 1))[: len(x) + n]
    dry = np.concatenate([x, np.zeros(n)])
    return dry * (1 - mix) + wet * mix * 0.6


def save(name: str, x: np.ndarray, peak_db: float) -> None:
    x = x - np.mean(x)
    x = x / (np.max(np.abs(x)) + 1e-9) * 10 ** (peak_db / 20)
    fade = min(len(x) // 10, int(SR * 0.004))
    if fade:
        x[:fade] *= np.linspace(0, 1, fade)
        x[-fade:] *= np.linspace(1, 0, fade)
    wavfile.write(OUT / f"{name}.wav", SR, (x * 32767).astype(np.int16))
    print(f"{name}.wav  {len(x) / SR:5.2f}s")


# --------------------------------------------------------------- instrumentos

def electric_piano(freq: float, seconds: float, velocity: float = 1.0) -> np.ndarray:
    t = t_axis(seconds)
    body = (np.sin(2 * np.pi * freq * t) + 0.35 * np.sin(2 * np.pi * 2 * freq * t)
            + 0.08 * np.sin(2 * np.pi * 3 * freq * t))
    tine = 0.25 * np.sin(2 * np.pi * 7.0 * freq * t) * np.exp(-t / 0.05)
    tremolo = 1 + 0.06 * np.sin(2 * np.pi * 4.5 * t)
    return (body * env(len(t), 0.004, 1.6) + tine) * tremolo * velocity


def bell(freq: float, seconds: float, velocity: float = 1.0) -> np.ndarray:
    t = t_axis(seconds)
    x = (np.sin(2 * np.pi * freq * t) * env(len(t), 0.002, 0.9)
         + 0.4 * np.sin(2 * np.pi * freq * 2.76 * t) * env(len(t), 0.001, 0.25)
         + 0.15 * np.sin(2 * np.pi * freq * 5.4 * t) * env(len(t), 0.001, 0.08))
    return x * velocity


def marimba(freq: float, seconds: float, velocity: float = 1.0) -> np.ndarray:
    t = t_axis(seconds)
    x = (np.sin(2 * np.pi * freq * t) * env(len(t), 0.002, 0.35)
         + 0.25 * np.sin(2 * np.pi * freq * 4.0 * t) * env(len(t), 0.001, 0.06))
    return x * velocity


def bass(freq: float, seconds: float, velocity: float = 1.0) -> np.ndarray:
    t = t_axis(seconds)
    x = np.sin(2 * np.pi * freq * t) + 0.2 * np.sin(2 * np.pi * 2 * freq * t)
    e = np.clip(t / 0.01, 0, 1) * np.exp(-t / 0.9)
    return lowpass(x * e, 900) * velocity


def kick(seconds: float = 0.35) -> np.ndarray:
    t = t_axis(seconds)
    freq = 45 + 55 * np.exp(-t / 0.04)
    phase = 2 * np.pi * np.cumsum(freq) / SR
    return np.sin(phase) * np.exp(-t / 0.12)


def hat(seconds: float = 0.06) -> np.ndarray:
    n = int(seconds * SR)
    return highpass(RNG.normal(0, 1, n), 7000) * env(n, 0.001, 0.018)


def place(track: np.ndarray, sound: np.ndarray, at: float) -> None:
    i = int(at * SR)
    end = min(len(track), i + len(sound))
    if i < len(track):
        track[i:end] += sound[: end - i]


# ------------------------------------------------------------------- música

CHORDS = [  # 2 compassos cada, voicings em região média (cara de lo-fi)
    ("F2", ["A3", "C4", "E4", "G4"]),      # Fmaj7
    ("E2", ["G3", "B3", "D4", "G4"]),      # Em7
    ("D2", ["F3", "A3", "C4", "E4"]),      # Dm7 (add9)
    ("G2", ["F3", "A3", "C4", "D4"]),      # G9sus
    ("A2", ["G3", "C4", "E4", "G4"]),      # Am7
    ("F2", ["A3", "C4", "E4", "A4"]),      # Fmaj7
    ("D2", ["F3", "A3", "C4", "E4"]),      # Dm7
    ("G2", ["F3", "B3", "D4", "G4"]),      # G7
]
MELODY = [  # (compasso, tempo, nota, duração em tempos) — só na segunda metade
    (8, 0.0, "E5", 1.5), (8, 2.0, "G5", 1.0), (8, 3.0, "A5", 1.0),
    (9, 0.5, "G5", 2.0), (9, 3.0, "E5", 1.0),
    (10, 0.0, "D5", 1.5), (10, 2.0, "E5", 1.0), (10, 3.0, "C5", 1.0),
    (11, 0.5, "D5", 3.0),
    (12, 0.0, "C5", 1.5), (12, 2.0, "E5", 1.0), (12, 3.0, "G5", 1.0),
    (13, 0.5, "A5", 2.0), (13, 3.0, "G5", 1.0),
    (14, 0.0, "F5", 1.0), (14, 1.0, "E5", 1.0), (14, 2.0, "D5", 2.0),
    (15, 0.0, "B4", 1.0), (15, 1.5, "D5", 2.5),
]


def music_theme() -> np.ndarray:
    bpm = 74
    beat = 60 / bpm
    bar = beat * 4
    bars = 16
    length = bar * bars
    keys = np.zeros(int(length * SR) + SR * 4)
    low = np.zeros_like(keys)
    perc = np.zeros_like(keys)
    lead = np.zeros_like(keys)

    for i in range(bars):
        root, voicing = CHORDS[(i // 2) % len(CHORDS)]
        start = i * bar
        swing = 0.04
        for n_i, n in enumerate(voicing):
            strum = n_i * 0.012
            place(keys, electric_piano(note(n), 3.0, 0.55), start + strum)
            place(keys, electric_piano(note(n), 1.6, 0.28), start + beat * 2.5 + swing + strum)
        place(low, bass(note(root), bar * 0.48, 0.9), start)
        place(low, bass(note(root) * (1.5 if i % 2 else 1.0), bar * 0.45, 0.7), start + beat * 2)
        if i >= 2:
            place(perc, kick() * 0.55, start)
            place(perc, kick() * 0.4, start + beat * 2 + beat * 0.5)
        for b in range(8):
            place(perc, hat() * (0.18 if b % 2 else 0.1), start + b * beat / 2 + (swing if b % 2 else 0))

    for bar_i, beat_i, n, dur in MELODY:
        place(lead, bell(note(n), dur * beat + 1.2, 0.45), bar_i * bar + beat_i * beat)
    # repete a melodia uma oitava abaixo e mais baixo, como "eco" na primeira metade
    for bar_i, beat_i, n, dur in MELODY[:9]:
        place(lead, bell(note(n) / 2, dur * beat + 1.0, 0.18), (bar_i - 8 + 4) * bar + beat_i * beat)

    mix = fast_reverb(lowpass(keys, 3500), 0.3)[: len(keys)] * 0.8
    mix += low * 0.9 + lowpass(perc, 6000) * 0.5
    mix += fast_reverb(lead, 0.4)[: len(keys)] * 0.55

    # chiado de vinil bem baixo
    crackle = lowpass(RNG.normal(0, 1, len(mix)), 2500) * 0.004
    clicks = (RNG.random(len(mix)) > 0.99985) * RNG.normal(0, 0.15, len(mix))
    mix += crackle + lowpass(clicks, 4000)

    # loop sem emenda: a cauda depois do fim volta para o começo
    n = int(length * SR)
    looped = mix[:n].copy()
    tail = mix[n:]
    looped[: len(tail)] += tail
    return lowpass(looped, 9000)


# ---------------------------------------------------------------- ambiências

def ambience_day(seconds: float = 16.0) -> np.ndarray:
    n = int(seconds * SR)
    x = lowpass(RNG.normal(0, 1, n), 300) * 0.05          # ruído de casa
    hum = np.sin(2 * np.pi * 120 * t_axis(seconds)) * 0.004  # geladeira
    x += hum
    for k in range(int(seconds)):                          # relógio: tic-tac
        tick = bandpass(RNG.normal(0, 1, int(SR * 0.03)), 2500 if k % 2 else 3200, 6000)
        place(x, tick * env(len(tick), 0.0005, 0.006) * 0.25, k + 0.0)
    return x


def ambience_night(seconds: float = 16.0) -> np.ndarray:
    n = int(seconds * SR)
    x = lowpass(RNG.normal(0, 1, n), 500) * 0.04
    t = 0.3
    while t < seconds - 1:
        freq = RNG.uniform(4200, 5200)
        pulses = RNG.integers(3, 6)
        for p in range(pulses):
            tt = t_axis(0.035)
            chirp = np.sin(2 * np.pi * freq * tt) * np.sin(np.pi * tt / 0.035) * RNG.uniform(0.04, 0.09)
            place(x, chirp, t + p * 0.05)
        t += RNG.uniform(0.25, 0.9)
    return x


# ----------------------------------------------------------------- efeitos

def sfx_hover() -> np.ndarray:
    t = t_axis(0.05)
    return np.sin(2 * np.pi * 2400 * t) * env(len(t), 0.001, 0.012)


def sfx_click() -> np.ndarray:
    t = t_axis(0.12)
    tone = (np.sin(2 * np.pi * 880 * t) + 0.4 * np.sin(2 * np.pi * 1760 * t)) * env(len(t), 0.001, 0.035)
    noise = bandpass(RNG.normal(0, 1, len(t)), 1500, 5000) * env(len(t), 0.0005, 0.006) * 0.4
    return tone + noise


def sfx_open() -> np.ndarray:
    n = int(SR * 0.35)
    t = np.arange(n) / SR
    shape = np.sin(np.pi * t / 0.35) ** 2
    return bandpass(RNG.normal(0, 1, n), 900, 4500) * shape * 0.6


def sfx_two_notes(a: str, b: str, gap: float, inst=marimba, length: float = 0.9) -> np.ndarray:
    x = np.zeros(int(SR * length))
    place(x, inst(note(a), length), 0)
    place(x, inst(note(b), length - gap), gap)
    return fast_reverb(x, 0.25)[: int(SR * (length + 0.4))]


def sfx_sparkle() -> np.ndarray:
    x = np.zeros(int(SR * 1.0))
    for i, n in enumerate(["C6", "E6", "G6", "C7"]):
        place(x, bell(note(n), 0.8, 0.6), i * 0.06)
    return fast_reverb(x, 0.35)[: int(SR * 1.4)]


def sfx_memory() -> np.ndarray:
    x = np.zeros(int(SR * 2.2))
    for n, v, at in (("A4", 0.6, 0.0), ("E5", 0.5, 0.08), ("C#6", 0.3, 0.16)):
        place(x, bell(note(n), 2.0, v), at)
    return fast_reverb(x, 0.45, 2.2)[: int(SR * 3.0)]


def sfx_step(seed: int) -> np.ndarray:
    rng = np.random.default_rng(seed)
    n = int(SR * 0.11)
    t = np.arange(n) / SR
    thump = np.sin(2 * np.pi * (95 + rng.uniform(-10, 10)) * t) * env(n, 0.001, 0.025)
    scuff = lowpass(rng.normal(0, 1, n), rng.uniform(500, 800)) * env(n, 0.001, 0.02) * 0.9
    knock = bandpass(rng.normal(0, 1, n), 1200, 2800) * env(n, 0.0005, 0.004) * 0.25
    return thump + scuff + knock


def sfx_blip() -> np.ndarray:
    t = t_axis(0.03)
    return np.sin(2 * np.pi * 620 * t) * env(len(t), 0.001, 0.01)


def sfx_whoosh_soft() -> np.ndarray:
    n = int(SR * 0.6)
    t = np.arange(n) / SR
    shape = np.sin(np.pi * t / 0.6) ** 3
    return lowpass(RNG.normal(0, 1, n), 1200) * shape


# ------------------------------------------------- cutscene de abertura

def ambience_classroom(seconds: float = 10.0) -> np.ndarray:
    """Sala em silêncio de prova: só o relógio e lápis riscando o papel."""
    n = int(seconds * SR)
    x = lowpass(RNG.normal(0, 1, n), 250) * 0.04
    for k in range(int(seconds)):
        tick = bandpass(RNG.normal(0, 1, int(SR * 0.04)), 1800 if k % 2 else 2600, 6000)
        tone = np.sin(2 * np.pi * (2900 if k % 2 else 3300) * t_axis(0.04))
        place(x, (tick + tone * 0.4) * env(int(SR * 0.04), 0.0005, 0.008) * 0.35, k + 0.0)
    for _ in range(7):
        dur = RNG.uniform(0.4, 1.0)
        tt = t_axis(dur)
        strokes = 0.5 + 0.5 * np.sin(2 * np.pi * RNG.uniform(9, 16) * tt)
        scratch = bandpass(RNG.normal(0, 1, len(tt)), 2500, 7500) * strokes * np.sin(np.pi * tt / dur)
        place(x, scratch * RNG.uniform(0.03, 0.06), RNG.uniform(0.2, seconds - dur - 0.1))
    return x


def ambience_street(seconds: float = 12.0) -> np.ndarray:
    """Fim de tarde na rua: vento, trânsito distante, um carro passando e passarinhos."""
    n = int(seconds * SR)
    t = t_axis(seconds)
    wind_shape = 0.6 + 0.25 * np.sin(2 * np.pi * t / seconds) + 0.15 * np.sin(2 * np.pi * 3 * t / seconds)
    x = lowpass(RNG.normal(0, 1, n), 400) * 0.05 * wind_shape
    x += lowpass(RNG.normal(0, 1, n), 120) * 0.03
    car_t = t_axis(4.0)
    car = bandpass(RNG.normal(0, 1, len(car_t)), 180, 900) * np.sin(np.pi * car_t / 4.0) ** 2 * 0.05
    place(x, car, seconds / 2 - 2.0)
    at = 0.6
    while at < seconds - 1.0:
        for p in range(RNG.integers(2, 5)):
            ct = t_axis(0.07)
            freq = np.linspace(RNG.uniform(2800, 3400), RNG.uniform(4200, 5000), len(ct))
            chirp = np.sin(2 * np.pi * np.cumsum(freq) / SR) * np.sin(np.pi * ct / 0.07)
            place(x, chirp * RNG.uniform(0.02, 0.045), at + p * 0.09)
        at += RNG.uniform(1.4, 3.2)
    return x


def sfx_pop() -> np.ndarray:
    t = t_axis(0.09)
    freq = np.linspace(500, 1150, len(t))
    return np.sin(2 * np.pi * np.cumsum(freq) / SR) * env(len(t), 0.001, 0.03)


def sfx_paper() -> np.ndarray:
    n = int(SR * 0.45)
    t = np.arange(n) / SR
    flutter = 0.7 + 0.3 * np.sin(2 * np.pi * 23 * t)
    return bandpass(RNG.normal(0, 1, n), 1500, 6000) * np.sin(np.pi * t / 0.45) ** 2 * flutter


def sfx_sting() -> np.ndarray:
    """Acorde dissonante (trítono) com reverb: o momento em que a professora acha a cola."""
    x = np.zeros(int(SR * 2.6))
    for n, v in (("D3", 0.6), ("G#3", 0.5), ("D4", 0.35), ("D#5", 0.18)):
        place(x, electric_piano(note(n), 2.5, v), 0.0)
    place(x, bass(note("D2"), 2.0, 0.9), 0.0)
    place(x, kick(0.5) * 0.7, 0.0)
    return fast_reverb(x, 0.45, 2.4)[: int(SR * 3.4)]


def sfx_whispers() -> np.ndarray:
    """Cochichos da turma: sílabas de ruído em várias "vozes" sobrepostas."""
    total = 1.8
    x = np.zeros(int(SR * total))
    for voice in range(4):
        at = RNG.uniform(0.0, 0.3)
        lo, hi = (1800, 5500) if voice % 2 else (500, 1800)
        while at < total - 0.3:
            dur = RNG.uniform(0.07, 0.17)
            st = t_axis(dur)
            syl = bandpass(RNG.normal(0, 1, len(st)), lo, hi) * np.sin(np.pi * st / dur)
            place(x, syl * RNG.uniform(0.3, 0.6), at)
            at += dur + RNG.uniform(0.02, 0.12)
    shape = np.sin(np.pi * np.arange(len(x)) / len(x)) ** 0.7
    return x * shape


def sfx_phone_buzz() -> np.ndarray:
    x = np.zeros(int(SR * 0.8))
    for start in (0.0, 0.38):
        bt = t_axis(0.26)
        buzz = np.sign(np.sin(2 * np.pi * 170 * bt)) * (0.8 + 0.2 * np.sin(2 * np.pi * 31 * bt))
        place(x, lowpass(buzz, 1200) * np.clip(np.sin(np.pi * bt / 0.26) * 3, 0, 1), start)
    return x


def sfx_door() -> np.ndarray:
    x = np.zeros(int(SR * 1.0))
    click_n = int(SR * 0.05)
    click = bandpass(RNG.normal(0, 1, click_n), 2000, 6000) * env(click_n, 0.0005, 0.005)
    click += np.sin(2 * np.pi * 1200 * t_axis(0.05)) * env(click_n, 0.001, 0.02) * 0.5
    place(x, click, 0.0)
    ct = t_axis(0.7)
    freq = np.linspace(180, 260, len(ct)) + RNG.normal(0, 6, len(ct))
    saw = 2 * ((np.cumsum(freq) / SR) % 1.0) - 1
    rough = 0.6 + 0.4 * (lowpass(RNG.normal(0, 1, len(ct)), 25) > 0)
    creak = bandpass(saw * rough, 400, 2500) * np.sin(np.pi * ct / 0.7) * 0.35
    place(x, creak, 0.08)
    return x


# ------------------------------------------- cenas antes/depois das enquetes

def sfx_baby_cry() -> np.ndarray:
    """Dois "uééé" curtos: dente de serra com vibrato, filtrado na região da voz."""
    x = np.zeros(int(SR * 1.5))
    for start, dur, f0 in ((0.0, 0.55, 430), (0.7, 0.65, 470)):
        t = t_axis(dur)
        contour = f0 + 90 * np.sin(np.pi * t / dur) + 12 * np.sin(2 * np.pi * 6.5 * t)
        saw = 2 * ((np.cumsum(contour) / SR) % 1.0) - 1
        voice = bandpass(saw, 700, 3200) + 0.5 * bandpass(saw, 2400, 4200)
        place(x, voice * np.sin(np.pi * t / dur) ** 0.6, start)
    return x


def sfx_clink() -> np.ndarray:
    x = np.zeros(int(SR * 0.6))
    for start, gain in ((0.0, 1.0), (0.17, 0.6)):
        t = t_axis(0.35)
        hit = sum(np.sin(2 * np.pi * f * t) * np.exp(-t / d) for f, d in ((2850, 0.12), (4170, 0.08), (5630, 0.05)))
        place(x, hit * gain, start)
    return x


def sfx_page() -> np.ndarray:
    n = int(SR * 0.3)
    t = np.arange(n) / SR
    shape = np.clip(t / 0.02, 0, 1) * np.exp(-t / 0.09)
    return bandpass(RNG.normal(0, 1, n), 1200, 6500) * shape


def sfx_ping() -> np.ndarray:
    x = np.zeros(int(SR * 0.6))
    place(x, bell(note("E6"), 0.5, 0.7), 0.0)
    place(x, bell(note("B6"), 0.45, 0.5), 0.07)
    return x


# ------------------------------------------------- trilha das cutscenes (v2)

def heartbeat(gain: float = 1.0) -> np.ndarray:
    x = np.zeros(int(SR * 0.6))
    for at, g in ((0.0, 1.0), (0.17, 0.7)):
        t = t_axis(0.25)
        freq = 48 + 30 * np.exp(-t / 0.03)
        thump = np.sin(2 * np.pi * np.cumsum(freq) / SR) * np.exp(-t / 0.07)
        place(x, lowpass(thump, 300) * g, at)
    return x * gain


def music_tension(seconds: float = 8.0) -> np.ndarray:
    """Drone grave + batimento cardíaco + nota aguda tremendo: o chão sumindo."""
    n = int(SR * seconds)
    t = t_axis(seconds)
    saw = sum(np.sin(2 * np.pi * f * k * t) / k for f in (note("D2"), note("D2") * 1.006) for k in range(1, 7))
    drone = lowpass(saw, 420) * (0.75 + 0.25 * np.sin(2 * np.pi * t / seconds))
    alto = np.sin(2 * np.pi * note("G#5") * t) * (0.5 + 0.5 * np.sin(2 * np.pi * 6 * t)) * 0.05
    x = drone * 0.22 + alto
    beat = 60 / 72
    k = 0.0
    while k < seconds - 0.6:
        place(x, heartbeat(0.9), k)
        k += beat
    return fast_reverb(x, 0.3)[:n]


def music_melancholy() -> np.ndarray:
    """Piano elétrico lento em lá menor (Am–F–C–G), para a volta para casa e momentos tristes."""
    bpm = 66
    beat = 60 / bpm
    acordes = [("A2", ["A3", "C4", "E4"]), ("F2", ["F3", "A3", "C4"]), ("C3", ["G3", "C4", "E4"]), ("G2", ["G3", "B3", "D4"])]
    compasso = beat * 4
    total = compasso * len(acordes)
    x = np.zeros(int(SR * (total + 4)))
    for i, (raiz, notas) in enumerate(acordes):
        inicio = i * compasso
        place(x, bass(note(raiz), compasso, 0.6), inicio)
        for j in range(8):  # arpejo em colcheias
            n = notas[[0, 1, 2, 1, 2, 1, 0, 1][j]]
            place(x, electric_piano(note(n) * (2 if j == 4 else 1), 1.6, 0.32), inicio + j * beat / 2)
    melodia = [(0, "E5", 3), (4, "C5", 2), (6, "D5", 2), (8, "E5", 3), (11, "G5", 1), (12, "D5", 4)]
    for b, n, d in melodia:
        place(x, bell(note(n), d * beat + 1.0, 0.25), b * beat)
    mix = fast_reverb(lowpass(x, 5000), 0.45, 2.4)
    n = int(SR * total)
    loop = mix[:n].copy()
    cauda = mix[n:]
    loop[: len(cauda)] += cauda[: n]
    return loop


def sfx_impact() -> np.ndarray:
    x = np.zeros(int(SR * 2.0))
    place(x, kick(0.8) * 1.2, 0.0)
    t = t_axis(1.6)
    rumble = lowpass(RNG.normal(0, 1, len(t)), 180) * np.exp(-t / 0.5) * 0.8
    place(x, rumble, 0.0)
    crack = highpass(RNG.normal(0, 1, int(SR * 0.08)), 3000) * env(int(SR * 0.08), 0.0005, 0.02) * 0.5
    place(x, crack, 0.0)
    place(x, bell(note("D#6"), 1.2, 0.25), 0.0)
    return fast_reverb(x, 0.35, 2.0)[: int(SR * 2.4)]


def sfx_swoosh() -> np.ndarray:
    n = int(SR * 0.35)
    t = np.arange(n) / SR
    shape = (t / 0.35) ** 1.5 * np.exp(-((t - 0.25) / 0.08) ** 2) + np.exp(-((t - 0.22) / 0.06) ** 2)
    sweep = np.zeros(n)
    noise = RNG.normal(0, 1, n)
    for i, lo in enumerate(np.linspace(600, 3000, 6)):
        seg = slice(i * n // 6, (i + 1) * n // 6)
        sweep[seg] = bandpass(noise, lo, lo * 2.2)[seg]
    return sweep * shape


def sfx_warm() -> np.ndarray:
    """Acorde maior se abrindo com sininhos: carinho, alívio."""
    x = np.zeros(int(SR * 3.2))
    for n, v, at in (("C4", 0.35, 0.0), ("E4", 0.3, 0.05), ("G4", 0.3, 0.1), ("D5", 0.2, 0.15)):
        place(x, electric_piano(note(n), 3.0, v), at)
    for i, n in enumerate(["G5", "C6", "E6"]):
        place(x, bell(note(n), 1.5, 0.3), 0.3 + i * 0.12)
    return fast_reverb(x, 0.5, 2.6)[: int(SR * 3.8)]


def main_cutscene_v2() -> None:
    save("music_tensao", music_tension(), -6.0)
    save("music_melancolia", music_melancholy(), -6.0)
    save("impacto", sfx_impact(), -5.0)
    save("swoosh", sfx_swoosh(), -12.0)
    save("batimento", heartbeat(), -8.0)
    save("calor", sfx_warm(), -9.0)


def main_cutscene() -> None:
    save("amb_sala_de_aula", ambience_classroom(), -18.0)
    save("amb_rua", ambience_street(), -16.0)
    save("emote_pop", sfx_pop(), -16.0)
    save("papel", sfx_paper(), -16.0)
    save("sting", sfx_sting(), -7.0)
    save("cochicho", sfx_whispers(), -15.0)
    save("celular", sfx_phone_buzz(), -13.0)
    save("porta", sfx_door(), -11.0)
    save("bebe_chorando", sfx_baby_cry(), -14.0)
    save("talheres", sfx_clink(), -16.0)
    save("pagina", sfx_page(), -15.0)
    save("notificacao", sfx_ping(), -13.0)
    main_cutscene_v2()


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    save("music_tema_casa", music_theme(), -4.0)
    save("amb_casa_dia", ambience_day(), -18.0)
    save("amb_casa_noite", ambience_night(), -14.0)
    save("ui_hover", sfx_hover(), -20.0)
    save("ui_click", sfx_click(), -10.0)
    save("ui_open", sfx_open(), -14.0)
    save("choice_confirm", sfx_two_notes("E5", "A5", 0.09), -8.0)
    save("rep_down", sfx_two_notes("D4", "A#3", 0.14), -9.0)
    save("rep_up", sfx_two_notes("C5", "G5", 0.1, bell), -9.0)
    save("energy_up", sfx_sparkle(), -10.0)
    save("memory", sfx_memory(), -8.0)
    save("objective", sfx_two_notes("G5", "C6", 0.12, bell), -12.0)
    save("text_blip", sfx_blip(), -22.0)
    save("transition", sfx_whoosh_soft(), -16.0)
    for i in range(4):
        save(f"step_{i}", sfx_step(100 + i), -14.0)
    main_cutscene()


if __name__ == "__main__":
    main()
