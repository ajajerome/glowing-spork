# glowing-spork
AI driven fotball trainer

## Overview
Learnfotball is a minimal iOS MVP using SwiftUI + SpriteKit. It renders a simple training drill where you drag a player to control interactions with a moving ball and collect cones. The HUD shows score and a countdown timer.

## What’s implemented
- SpriteKit `TrainingScene` with:
  - Ball physics (bounce, friction, damping)
  - Cones that are collected on contact (score increases)
  - Player node you can drag by touch
  - Score and timer HUD
- SwiftUI `ContentView` with:
  - Tabbar med tre flikar: Träna, Avatar, Tränare
  - `TrainingView` visar scen, Start/Reset, frågesheet efter drill
  - `AvatarView` för skapande av avatar (färg, frisyr) + födelsedatum
  - `TrainerEditorView` för att skapa frågeutkast lokalt
- XcodeGen `project.yml` for reproducible project generation
- GitHub Actions CI that can build a simulator artifact and (optionally) upload to TestFlight via Fastlane when secrets are present
- Fastlane lanes: `sim` for simulator build artifact, `ci` for tests + build + TestFlight

## What’s next (suggested)
- Add multiple drills and a drill selector (passing config into `TrainingScene`)
- Basic progression and scoring persistence
- Sound effects and visual feedback
- AI-driven coaching prompts (voice/text) based on performance
- Polish UI and support various device sizes dynamically
 - Åldersstyrd frågebank från CMS, tränarkonton och delning

## Run locally
1) Generate the Xcode project:
```bash
cd ios
xcodegen generate
```
2) Open the generated `.xcodeproj` in Xcode and run on a simulator.

## CI / Artifacts
- GitHub Actions workflow `iOS CI (TestFlight)` builds a simulator app and uploads `simulator_app.zip` as an artifact.
- If TestFlight secrets are configured, the `testflight` job builds and uploads via Fastlane.

## Controls
- Start: begins the 30s drill and launches the ball
- Reset: resets score, timer, ball, and cones
- Drag anywhere: move the player to influence the ball and collect cones

## Gamification & Tränare (MVP)
- Avatar: namn, åldersgrupp, födelsedatum, färger och frisyr (lagras lokalt).
- Ålderslogik: åldersband härleds från födelsedatum och används för frågor.
- Frågor: bundlad `questions.json` filtreras per åldersband; visas efter drill.
- Tränare: skapa egna frågeutkast i appen (lokal lagring), för senare publicering via CMS.

## Tech
- SwiftUI, SpriteKit, XcodeGen, Fastlane, GitHub Actions
