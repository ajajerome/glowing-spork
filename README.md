# ⚽ SpelSmart - AI-driven Fotbollsträning

**SpelSmart** är en innovativ iOS-app som utvecklar barns spelförståelse genom interaktiva fotbollsscenarier och AI-driven gamification.

## 🎯 Huvudfunktioner

### 🧠 **Interaktiva Scenarier**
- Realistiska matchsituationer på intelligent fotbollsplan
- Taktiska beslutspunkter med omedelbar feedback
- Anfall, försvar, omställningar och uppspelssituationer

### 🎮 **Gamification System**
- XP-system med exponentiell progression
- Player Ranks från "Nybörjare" till "Legend"
- Badge-system med 7 kategorier och 5 seltenhetsnivåer
- Skill Radar för 8 taktiska färdigheter

### 🔥 **Dagliga Utmaningar**
- Specialiserade scenarier med bonus XP
- Streak-system för konsekvent träning
- Unika belöningar och exklusiva badges

### 🤖 **AI-driven Analys**
- Kontextmedveten feedback på beslut
- Personliga träningsrekommendationer
- Adaptiv svårighetsgrad baserat på prestationer
- Detaljerade matchrapporter

## 🎨 Design

- **Färgpalett:** Limegrön (#A8E063) och Djupblå (#1E3C72)
- **Typografi:** Baloo 2 (rubriker), Inter (brödtext)
- **Layout:** Kortbaserad, swipevänlig design
- **Animationer:** Mikroanimationer för engagement

## 🏗️ Teknisk Stack

- **Plattform:** iOS 16.0+
- **Framework:** SwiftUI + SpriteKit
- **Språk:** Swift 5.0
- **AI/ML:** Lokal intelligens för rekommendationer
- **Data:** JSON-baserat innehållssystem

## 📱 Installation & Testning

Se [TESTING_GUIDE.md](TESTING_GUIDE.md) för detaljerad guide om hur du testar appen på din iPhone.

### Snabbstart:
```bash
git clone https://github.com/ajajerome/glowing-spork.git
cd glowing-spork/ios
xcodegen generate
open Learnfotball.xcodeproj
```

## 🎮 Användning

1. **Skapa Avatar:** Personalisera din spelare
2. **Spela Scenarier:** Fatta taktiska beslut i realistiska situationer  
3. **Samla XP & Badges:** Utveckla dina färdigheter
4. **Dagliga Utmaningar:** Håll din streak vid liv
5. **Följ Progression:** Se din utveckling i skill radar

## 📊 Målgrupp

- **Primär:** Barn 8-14 år som spelar fotboll
- **Sekundär:** Tränare och föräldrar som vill stödja utveckling
- **Fokus:** Spelförståelse och taktiskt tänkande

## 🛣️ Roadmap

- [x] Interaktiva scenarier med beslutspunkter
- [x] Komplett gamification-system
- [x] AI-driven feedback och rekommendationer
- [x] Dagliga utmaningar
- [ ] Coach-läge för tränare/föräldrar
- [ ] Multiplayer-scenarier
- [ ] AR-funktioner för verklig träning
- [ ] Säsongssystem med ranking

## 🤝 Bidrag

Projektet är under aktiv utveckling. Feedback och förslag är välkomna!

## 📄 Licens

Detta projekt utvecklas för utbildningssyfte med fokus på barns fotbollsutveckling.

---

**Utvecklat med ❤️ för nästa generation fotbollsspelare**

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
- GitHub Actions workflow (`.github/workflows/ios.yml`) körs på push och dagligen 05:00 UTC.
- Simulator‑build laddas upp som artifact (`simulator_app.zip`).
- Med TestFlight‑hemligheter bygger och publicerar `testflight` via Fastlane.
- Fastlane bump: buildnummer sätts automatiskt utifrån tidsstämpel i `ci`.
## Publicering – hemligheter (GitHub Actions)
- `ASC_ISSUER_ID`, `ASC_KEY_ID`, `ASC_API_KEY_P8`
- `TEAM_ID`, `BUNDLE_ID`
- `SIGNING_CERT_P12`, `SIGNING_CERT_PASSWORD`, `PROVISIONING_PROFILE`


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
