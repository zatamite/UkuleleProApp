# UkulelePro — Project Brief & Development Strategy
**Version:** 1.0  
**Language:** Swift (iOS First)  
**Target Platform:** iPhone → iPad → macOS → Android (future)  
**Prepared For:** Antigravity IDE → Xcode IDE Handoff  

---

## 1. Project Vision

**UkulelePro** is a native mobile application that serves as an all-in-one musician's companion for ukulele players. It combines three core capabilities into a single, polished experience:

1. **Real-time chromatic tuner** for Baritone and Tenor ukulele
2. **Live chord detection** — listening to audio and identifying chords as they are played
3. **Song performance companion** — displaying lyrics and graphical chord diagrams synchronized to detected or pre-loaded chord changes in real time

The visual identity of the app centers around **graphical chord fretboard diagrams** (not tab notation) rendered natively in SwiftUI — similar to what you would find in a printed fake book or chord dictionary.

---

## 2. Supported Instruments & Tunings

| Instrument | String Tuning (Low → High) | Notes |
|---|---|---|
| Tenor Ukulele | G – C – E – A | Standard; Low-G option supported |
| Tenor Ukulele (Low-G) | G – C – E – A | G string one octave lower |
| Baritone Ukulele | D – G – B – E | Same as top 4 strings of guitar |

The active tuning profile is user-selectable and affects both the tuner reference pitches and the chord voicing database served to the diagram renderer.

---

## 3. Feature Modules

### 3.1 — Chromatic Tuner
- Real-time pitch detection via microphone
- Displays nearest note name, cents deviation, and octave
- Visual needle / arc indicator (flat ◀ | in tune ✓ | sharp ▶)
- Supports both tuning profiles simultaneously (switch via tab or picker)
- Target accuracy: ±1 cent

### 3.2 — Chord Detection Engine
- Listens to live audio from microphone
- Analyzes chroma vectors in real time (FFT → 12-bin pitch class energy)
- Pattern-matches against chord template library
- Displays detected chord name + graphical diagram
- Confidence threshold filter (suppresses noise / ambiguous detections)
- Chord detection history shown as a scrolling timeline

### 3.3 — Song / Lyric Companion
- Two modes: **Live Listen Mode** and **Pre-loaded Song Mode**
- Displays lyrics line by line with chord diagram annotations above the relevant syllable/word
- Chord diagrams animate in real time as changes are detected or triggered
- Song data stored as structured JSON (lyrics + timestamps + chord names)
- Simple song library with search, favorites, and import

### 3.4 — Chord Dictionary
- Full reference library of all chord voicings for both tunings
- Organized by root (C, C#, D … B) and chord type
- Graphical fretboard diagram for every entry
- Chord types covered (per root, ×12 = total library):

| Family | Types |
|---|---|
| Triads | major, minor, augmented, diminished |
| Sevenths | dom7, maj7, min7, dim7, half-dim7 (m7b5), minMaj7 |
| Extended | 9, maj9, min9, add9, 11, maj11, 13, maj13 |
| Suspended | sus2, sus4, 7sus4 |
| Altered | 7b5, 7#5, 7b9, 7#9, 7#11 |
| Added | add9, add11, 6, m6, 6/9 |

**Estimated total:** ~360 chord shapes per tuning, ~720 total entries across both tunings.

---

## 4. Technical Architecture

### 4.1 High-Level Stack

```
┌─────────────────────────────────────────────┐
│               SwiftUI Layer                 │
│  TunerView | ChordView | LyricView | DictView│
└────────────────────┬────────────────────────┘
                     │
┌────────────────────▼────────────────────────┐
│           App Logic / ViewModels            │
│  TunerViewModel | ChordDetectionViewModel   │
│  SongSessionViewModel | LibraryViewModel    │
└──────┬─────────────────────────┬────────────┘
       │                         │
┌──────▼──────┐         ┌────────▼────────────┐
│  AudioKit 5 │         │   ChordEngine.swift │
│  (AudioEngine│        │   (Pure Swift DSP)  │
│  PitchTap   │        │   vDSP + Accelerate │
│  FFTTap)    │         │   ChromaVector      │
└─────────────┘         │   ChordMatcher      │
                        └────────────────────-┘
                                 │
                        ┌────────▼──────────┐
                        │  ChordDatabase.json│
                        │  (Tenor + Baritone)│
                        └───────────────────┘
```

### 4.2 Audio Pipeline Detail

```
Microphone Input
     │
     ▼
AudioEngine (AudioKit) — low-latency buffer capture
     │
     ├──▶ PitchTap ──▶ YIN Algorithm ──▶ TunerViewModel (Hz → Note → Cents)
     │
     └──▶ FFTTap ──▶ Magnitude Spectrum
                         │
                         ▼
                    Hann Windowing (vDSP)
                         │
                         ▼
                    Frequency Binning → 12 Pitch Classes
                         │
                         ▼
                    Chroma Vector [C,C#,D,D#,E,F,F#,G,G#,A,A#,B]
                         │
                         ▼
                    Cosine Similarity vs Chord Templates
                         │
                         ▼
                    Top-N Match → ChordDetectionViewModel
```

### 4.3 Module Breakdown

#### ChordEngine.swift
The core DSP module, written in pure Swift using Apple's `Accelerate` / `vDSP` framework. No external dependency for this step. Responsibilities:

- Buffer windowing (Hann)
- FFT via `vDSP.FFT`
- Frequency-to-pitch-class binning (equal temperament, A4=440Hz)
- Chroma vector normalization
- Template matching (cosine similarity)
- Output: `ChordDetectionResult(chordName: String, confidence: Float, chromaVector: [Float])`

#### ChordDiagramView.swift (SwiftUI Canvas)
Renders a guitar/uke fretboard diagram from a `ChordShape` model:

```swift
struct ChordShape: Codable {
    let name: String          // "Cmaj7"
    let tuning: Tuning        // .tenor | .baritone
    let frets: [Int?]         // nil = muted X, 0 = open O, n = fret number
    let fingers: [Int?]       // finger numbers 1-4
    let barre: BarreShape?    // optional { fret: Int, fromString: Int, toString: Int }
    let startFret: Int        // for high-up shapes (shows fret number label)
}
```

Diagram elements drawn via SwiftUI `Canvas`:
- Nut (thick top line if `startFret == 1`)
- Fret lines (4 frets displayed by default)
- String lines (4 strings)
- Filled circles for finger positions
- Barre arc / rectangle for barre chords
- "O" above open strings, "X" above muted strings
- Fret number label if `startFret > 1`

#### ChordDatabase.json
Pre-built JSON file bundled with the app. Schema:

```json
{
  "tenor": {
    "C": {
      "major": { "frets": [0,0,0,3], "fingers": [null,null,null,3], "barre": null, "startFret": 1 },
      "minor": { "frets": [0,3,3,3], "fingers": [null,1,2,3], "barre": null, "startFret": 1 },
      ...
    },
    ...
  },
  "baritone": { ... }
}
```

Generation strategy: Write a Swift command-line tool (`ChordGen`) that applies music theory rules to programmatically generate voicings for each tuning, then hand-verify edge cases.

#### SongLibrary
Song data format:

```json
{
  "title": "Somewhere Over the Rainbow",
  "tuning": "tenor",
  "bpm": 76,
  "sections": [
    {
      "lyrics": "Somewhere over the rainbow",
      "chords": [
        { "chord": "C", "wordIndex": 0, "beatOffset": 0.0 },
        { "chord": "Em", "wordIndex": 2, "beatOffset": 2.0 }
      ]
    }
  ]
}
```

---

## 5. Toolchain & Dependencies

### 5.1 Primary Dependencies

| Dependency | Version | Source | Purpose |
|---|---|---|---|
| **AudioKit** | 5.x | Swift Package Manager | Audio engine, PitchTap, FFTTap |
| **Accelerate (vDSP)** | System | Apple SDK (built-in) | FFT, DSP math |
| **AVFoundation** | System | Apple SDK (built-in) | Microphone access, session management |
| **Speech** | System | Apple SDK (built-in) | Optional live lyric transcription |
| **SwiftUI** | System | Apple SDK (built-in) | All UI including chord diagrams |
| **Combine** | System | Apple SDK (built-in) | Reactive data binding |

### 5.2 Optional / Future Dependencies

| Dependency | Purpose | When |
|---|---|---|
| **Essentia** (C++ via ObjC bridge) | Higher-accuracy chord detection | Phase 2 if needed |
| **MusicKit** | Apple Music integration, lyrics API | Phase 2 |
| **CloudKit** | iCloud song library sync | Phase 2 |
| **Kotlin Multiplatform Mobile (KMM)** | Cross-platform logic layer | Android port phase |

### 5.3 Xcode Project Settings

```
iOS Deployment Target:    iOS 16.0+
Swift Version:            5.9+
Supported Devices:        iPhone (primary), iPad (adaptive layout)
Capabilities Required:
  - Microphone Usage (NSMicrophoneUsageDescription)
  - Speech Recognition (NSSpeechRecognitionUsageDescription)
Bundle Identifier:        com.[studio].ukulepro
SwiftUI Previews:         Enabled
Package Manager:          Swift Package Manager (no CocoaPods)
```

### 5.4 Info.plist Keys Required

```xml
<key>NSMicrophoneUsageDescription</key>
<string>UkulelePro needs microphone access to tune your ukulele and detect chords.</string>

<key>NSSpeechRecognitionUsageDescription</key>
<string>UkulelePro uses speech recognition to transcribe lyrics in real time.</string>
```

---

## 6. Project Structure (Xcode)

```
UkulelePro/
├── App/
│   ├── UkuleleProApp.swift
│   └── ContentView.swift
├── Features/
│   ├── Tuner/
│   │   ├── TunerView.swift
│   │   └── TunerViewModel.swift
│   ├── ChordDetection/
│   │   ├── ChordDetectionView.swift
│   │   ├── ChordDetectionViewModel.swift
│   │   └── ChordEngine.swift          ← Core DSP logic
│   ├── SongCompanion/
│   │   ├── SongCompanionView.swift
│   │   ├── SongCompanionViewModel.swift
│   │   └── LyricLineView.swift
│   └── ChordDictionary/
│       ├── ChordDictionaryView.swift
│       └── ChordSearchViewModel.swift
├── Shared/
│   ├── Views/
│   │   └── ChordDiagramView.swift     ← Reusable diagram renderer
│   ├── Models/
│   │   ├── ChordShape.swift
│   │   ├── Song.swift
│   │   ├── Tuning.swift
│   │   └── ChordDetectionResult.swift
│   ├── Audio/
│   │   └── AudioSessionManager.swift
│   └── Data/
│       ├── ChordDatabase.swift        ← Loads and queries JSON
│       └── SongLibrary.swift
├── Resources/
│   ├── ChordDatabase.json
│   └── SampleSongs/
│       └── *.json
└── Tools/
    └── ChordGen/                      ← CLI tool for chord generation
        └── main.swift
```

---

## 7. Development Phases

### Phase 1 — Foundation (Weeks 1–3)
- [ ] Xcode project scaffold with SwiftUI tabs
- [ ] AudioKit integration and microphone pipeline
- [ ] Tuner: pitch detection → display (both tunings)
- [ ] `ChordDiagramView` renderer in SwiftUI Canvas (hardcoded test chord)
- [ ] Basic `ChordDatabase.json` (C, G, Am, F for both tunings as proof of concept)

### Phase 2 — Chord Engine (Weeks 4–6)
- [ ] `ChordEngine.swift`: FFT → chroma vector → template matching
- [ ] Real-time chord detection display with confidence score
- [ ] Full `ChordDatabase.json` generation via `ChordGen` tool (all ~720 shapes)
- [ ] Chord Dictionary view: browse, search, filter by tuning

### Phase 3 — Song Companion (Weeks 7–9)
- [ ] Song JSON schema + parser
- [ ] Pre-loaded song mode: lyrics + chord diagram timeline
- [ ] Live mode: detected chords update diagram in real time alongside lyrics
- [ ] 5–10 built-in sample songs

### Phase 4 — Polish & Extras (Weeks 10–12)
- [ ] App icon, launch screen, design system (colors, typography)
- [ ] Onboarding flow (tuning selection, permissions)
- [ ] Song import (user-created JSON or simple text import)
- [ ] Optional: Speech recognition lyric capture
- [ ] TestFlight beta

### Phase 5 — Cross-Platform Prep (Future)
- [ ] Extract `ChordEngine`, `ChordDatabase`, and `Song` models into a Kotlin Multiplatform module
- [ ] Android app shell consuming KMM business logic
- [ ] SwiftUI → Jetpack Compose UI port

---

## 8. Known Technical Challenges & Mitigation

| Challenge | Risk | Mitigation |
|---|---|---|
| Polyphonic chord detection accuracy | Medium-High | Use chroma-based detection with confidence thresholding; suppress low-confidence outputs; optionally integrate Essentia later |
| Distinguishing enharmonic chords (e.g. Dm7 vs F6) | High | Accept ambiguity with a "best match" UX — show top 2 candidates |
| Background noise affecting detection | Medium | Apply noise gating (amplitude threshold) before analysis; only process frames above a dB floor |
| Real-time lyric transcription accuracy | High | Default to pre-loaded song mode first; live transcription is a Phase 4+ enhancement |
| Generating all 720 chord shapes correctly | Medium | Use the `ChordGen` CLI tool + music theory validation; allow community correction via feedback |
| AudioKit API changes | Low | Pin AudioKit version in SPM; monitor release notes |

---

## 9. Architecture Principles & Coding Standards

- **MVVM** throughout — Views own no business logic
- **Combine** for all reactive bindings between Audio layer and ViewModels
- **@MainActor** on all ViewModels (audio callbacks post to main queue)
- **Swift Concurrency (async/await)** for database loading and file I/O
- No third-party UI libraries — SwiftUI only, keep the app lean
- `ChordEngine` must be fully **unit testable** with synthetic chroma vectors
- All chord data **externalized in JSON** — never hardcoded in Swift

---

## 10. Cross-Platform Portability Notes

When writing Swift code, apply these conventions to make future porting to Android/Kotlin easier:

- Keep DSP math in pure functions with no SwiftUI dependency
- `ChordEngine` should be a stateless transform: `[Float] → ChordDetectionResult`
- All model types (`ChordShape`, `Song`, `ChordDetectionResult`) should be simple value types — no platform APIs in models
- Consider tagging cross-platform-safe files with `// PORTABLE` comment
- When Android port begins, use **Kotlin Multiplatform Mobile (KMM)** to share models + ChordEngine logic; rewrite UI natively in Jetpack Compose

---

## 11. Summary — What We Are Building

> A native iPhone app that can **tune** a baritone or tenor ukulele, **listen** to someone playing and identify the chords in real time, and **display** the lyrics of a song alongside beautiful graphical chord diagrams that update live as the music plays — serving as an intelligent, visual cheat-sheet for ukulele players of all skill levels.

**The three pillars:**
- 🎵 **Tuner** — precise, clean, fast
- 🎸 **Chord Detector** — DSP-powered, real time
- 📖 **Song Companion** — lyrics + diagrams, synchronized

**The secret weapon:**
A hand-crafted, comprehensive chord voicing database for both tunings covering every common chord type — rendered as beautiful, scalable, graphical fretboard diagrams using nothing but SwiftUI's Canvas API.

---

*Document prepared for handoff to Antigravity IDE. All module names, file paths, and JSON schemas are intended as concrete implementation targets, not suggestions.*
