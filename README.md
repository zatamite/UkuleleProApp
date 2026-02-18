# UkulelePro 🎸

A native iOS app for **Baritone Ukulele** players. Real-time chord detection and precision tuning — no subscription, no cloud, all on-device.

---

## Features

### 🎵 Live Chord Detector
- **Strum any chord** and the app identifies it in real time
- Detects **150+ chord types** across all 12 keys:
  - Triads: Major, Minor, Diminished, Augmented
  - Suspended: Sus2, Sus4
  - Sevenths: Dominant 7, Major 7, Minor 7, Diminished 7, Half-Diminished (m7b5)
  - Extended: 6th, Minor 6th, Add9
- Designed for **songwriters** — play a bizarre chord you invented and find out what it's called
- Instant visual feedback: display clears on each new strum so you always know it's listening

### 🎛️ Precision Tuner
- Chromatic tuner with **analog gauge** and **strobe display**
- Tuned for **Baritone Ukulele** (D-G-B-E) by default
- Supports multiple tunings

---

## How It Works: The Math

### 1. Amplitude Flux Detection (Strum Onset)

The app doesn't analyze audio continuously — that would be slow and inaccurate. Instead it listens for **strums** using **spectral flux**:

```
Δ(t) = A(t) - A(t-1)
```

Where `A(t)` is the current amplitude envelope. When `Δ(t) > 0.03` AND `A(t) > 0.1`, a strum is detected. This catches the sharp **attack transient** of a strum while ignoring the slow **sustain/decay**, preventing the engine from re-triggering while a chord rings out.

A **200ms cooldown** prevents double-triggers from a single strum.

### 2. High-Resolution FFT Snapshot

When a strum is detected, the engine waits **100ms** (the "latch delay") for the chord to fully bloom, then captures **8,192 audio samples** (~170ms at 48kHz).

A **Fast Fourier Transform** (FFT) converts this time-domain snapshot into the frequency domain:

```
X[k] = Σ x[n] · e^(-i·2π·k·n/N)   for k = 0..N/2
```

A **Hanning window** is applied before the FFT to reduce spectral leakage at bin edges:

```
w[n] = 0.5 · (1 - cos(2π·n / (N-1)))
```

With N=8192, each FFT bin has a resolution of:

```
Δf = sampleRate / N = 48000 / 8192 ≈ 5.86 Hz/bin
```

This is fine enough to distinguish adjacent semitones even in the bass register.

### 3. Chroma Vector

The FFT magnitudes are mapped into a **12-element Chroma Vector** — one slot per musical pitch class (C, C#, D, ... B), collapsing all octaves:

```
noteIndex = round(12 · log₂(f / 440) + 69) mod 12
chroma[noteIndex] += magnitude[bin]
```

Only bins in the **60Hz–1000Hz** range are considered (the musical range of a baritone ukulele). The result is normalized so the loudest note = 1.0.

### 4. Template Matching with Anti-Weights

Each chord type is defined as a **12-element template vector** with:
- `+1.0` for notes that **must** be present
- `-0.5` for notes that **must not** be present (anti-weights)
- `0.0` for don't-care positions

Templates are generated algorithmically for all 12 roots × 14 chord types = **168 templates**.

Similarity is computed using a **modified cosine similarity**:

```
score = (Σ template[i] · chroma[i]) / (√Σ template[i]² · √Σ chroma[i]²)
```

The key insight: **only positive template weights contribute to the denominator** (`normA`). This means anti-weights act as pure penalties — if a "forbidden" note is present, the dot product decreases, but a perfect match (no forbidden notes) still scores 1.0.

The chord with the highest score above **0.6** is displayed.

### Why Anti-Weights Matter

Without anti-weights, a **G Major** (G-B-D) and **Gm** (G-Bb-D) would score similarly against a Gm input because both share G and D. The anti-weight on the Major 3rd (B) in the Gm template penalizes any energy at B, cleanly separating the two.

---

## Architecture

```
AudioManager (AudioKit)
    │
    ├── $amplitude  ──→  ChordEngine.handleFlux()
    │                         │
    │                    Flux > threshold?
    │                         │
    │                    triggerAnalysis() [100ms delay]
    │                         │
    └── getLastSamples() ──→  computeFFT()
                                   │
                              calculateAdditiveChroma()
                                   │
                              Template Matching (168 templates)
                                   │
                              @Published detectedChord
                                   │
                         ChordDetectionView (SwiftUI)
```

**Key files:**
- `ChordEngine.swift` — All DSP logic (FFT, chroma, matching)
- `AudioManager.swift` — AudioKit wrapper, amplitude publisher, sample buffer
- `ChordTemplate.swift` — Template model with modified cosine similarity
- `ChordDetectionView.swift` — SwiftUI display
- `TunerView.swift` / `TunerViewModel.swift` — Chromatic tuner

---

## Tech Stack

| Component | Technology |
|---|---|
| Audio Capture | AudioKit |
| FFT | Apple Accelerate (vDSP) |
| UI | SwiftUI |
| Reactive Data | Combine |
| Language | Swift 5.9+ |
| Platform | iOS 16+ |

---

## Known Limitations / Future Work

- Confidence threshold (0.6) may occasionally misidentify chords in noisy environments
- Extended chords (9ths, 11ths, 13ths) not yet in the template database
- Enharmonic equivalents shown as sharps only (e.g. `A#` not `Bb`)
- No MIDI output (yet)

---

## License

MIT
