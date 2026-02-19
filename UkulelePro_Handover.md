# Handover: UkuleleProApp (Chord Detector & Tuner)

**Current State**: `Phase 18 Complete` (Master Chord DB Implemented).
**Critical Issue**: **"One-and-done" Lockup**. The engine detects the *first* strum perfectly (e.g. Dmaj7), but fails to re-trigger on subsequent strums. It seems to get stuck.

## Architecture Overview
The app is a dedicated **Baritone Ukulele Tuner & Chord Identifier**.
-   **Pure SwiftUI**: `ContentView` holds `TunerView` (AudioKit-based) and `ChordDetectionView` (Custom Engine).
-   **Cleaned Project**: All `SongCompanion` features (Lyrics, Library) were **deleted**. The app is strictly 2 tabs.

## The Chord Engine (`ChordEngine.swift`)
-   **Architecture**: "Live Strum Latch" (Flux-Based).
-   **Input**: Monitors `AudioManager.shared.$amplitude`.
-   **Trigger**: `handleFlux(_:)` checks if `delta > 0.03` (Flux) and `amp > 0.1`.
-   **Analysis**:
    -   Waits `0.1s` (`latchDelay`) for the sound to bloom.
    -   Captures **8192 sample snapshot** via `AudioManager.getLastSamples()`.
    -   Performs **High-Res FFT** (vDSP) & **Additive Harmonic Chroma**.
    -   Matches against `generateAllTemplates()` (Algorithmic DB: Maj, Min, Dim, Aug, Sus, 7ths, etc).

## The Bug: "Latch Loop / No Re-trigger"
-   **Symptoms**: User strums once -> Correct Result. User strums again -> No response.
-   **Suspected Cause**:
    -   `previousAmp` might be tracking the *envelope* continuously. If the guitar sustains (decays slowly) and the user re-strums softly, `delta` might not exceed `fluxThreshold` (0.03).
    -   OR `lastTriggerTime` lock might be preventing re-entry if the clock drifts?
    -   **Most Likely**: The `analysisTask` is being cancelled/overwritten in a way that prevents the *new* capture from firing if it happens too close to the old one?
    -   **Lifecycle**: `start()`/`stop()` were added to `ChordDetectionViewModel`. Ensure `stop()` didn't accidentally get called.

## Recent Changes (To Be Verified)
1.  **Algorithmic Templates**: `ChordEngine.swift` now generates ~150+ templates programmatically with **Negative Weights** (Anti-Weights) for precision.
2.  **Flux/Latency Tuning**: `fluxThreshold` = 0.03, `latchDelay` = 0.1s.
3.  **Ghost Clearing**: UI clears to `"--"` immediately on trigger.

## Next Steps for Claude
1.  **Debug the Flux Logic**: print/log the `delta` values in `handleFlux`. Is the re-strum actually crossing `0.03`?
2.  **Verify Lifecycle**: Ensure the engine isn't "Stopping" prematurely.
3.  **Restore Responsiveness**: If Flux is too flaky, consider a "Dip & Spike" detector (wait for amp to drop before re-arming).

Good luck. It's a solid codebase, just needs that final "feel" tweak.
