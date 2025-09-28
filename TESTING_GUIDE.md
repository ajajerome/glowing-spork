# 📱 SpelSmart - Testningsguide för iPhone

## 🚀 Snabbstart (Rekommenderad metod)

### Steg 1: Klona projektet
```bash
git clone https://github.com/ajajerome/glowing-spork.git
cd glowing-spork
```

### Steg 2: Installera XcodeGen (om inte installerat)
```bash
brew install xcodegen
```

### Steg 3: Generera Xcode-projekt
```bash
cd ios
xcodegen generate
```

### Steg 4: Öppna i Xcode
```bash
open Learnfotball.xcodeproj
```

---

## 📋 Manuell Xcode-setup (om XcodeGen inte fungerar)

### Steg 1: Skapa nytt iOS-projekt i Xcode
1. Öppna Xcode
2. Välj "Create a new Xcode project"
3. Välj "iOS" → "App"
4. Projektnamn: **SpelSmart**
5. Bundle ID: `com.ajagames.learnfotball`
6. Language: **Swift**
7. Interface: **SwiftUI**

### Steg 2: Kopiera källkoden
Kopiera alla filer från `ios/Sources/` till ditt nya Xcode-projekt:

**Modeller:**
- `Models/Avatar.swift`
- `Models/Drill.swift`
- `Models/GameScenario.swift`
- `Models/Gamification.swift`
- `Models/Question.swift`
- `Models/Telemetry.swift`
- `Models/TrainerContent.swift`

**Services:**
- `Services/AIRecommendationEngine.swift`
- `Services/AvatarStore.swift`
- `Services/ContentValidator.swift`
- `Services/DailyChallengeService.swift`
- `Services/DrillService.swift`
- `Services/ProgressStore.swift`
- `Services/QuestionService.swift`
- `Services/ResearchService.swift`
- `Services/ScenarioService.swift`
- `Services/TacticalAnalyzer.swift`

**Vyer:**
- `Views/AvatarView.swift`
- `Views/DailyChallengeView.swift`
- `Views/DrillSelectorView.swift`
- `Views/ProfileView.swift`
- `Views/QuestionView.swift`
- `Views/RecommendationsView.swift`
- `Views/ScenarioGameView.swift`
- `Views/SkillRadarChart.swift`
- `Views/SummaryView.swift`
- `Views/TacticalPitchScene.swift`
- `Views/TrainerEditorView.swift`
- `Views/TrainingView.swift`
- `Views/XPAnimationView.swift`

**Övrigt:**
- `TrainingScene.swift`
- `Utilities/UIColor+Hex.swift`

### Steg 3: Lägg till JSON-resurser
Kopiera alla `.json`-filer från `ios/Resources/` till ditt projekt:
- `drills.json`
- `questions.json`
- `sources.json`

**Viktigt:** Se till att filerna läggs till i "Bundle Resources" i Build Phases.

### Steg 4: Ersätt ContentView och App
Ersätt standardfilerna med våra:
- `ContentView.swift`
- `App.swift`

---

## ⚙️ Konfiguration för testning

### Steg 1: Uppdatera Team och Bundle ID
1. Välj ditt projekt i Navigator
2. Under "Signing & Capabilities":
   - **Team:** Välj ditt Apple Developer Team
   - **Bundle Identifier:** `com.ajagames.learnfotball` (eller din egen)

### Steg 2: Anslut din iPhone
1. Anslut iPhone med USB-kabel
2. Lås upp telefonen
3. Välj din iPhone som destination i Xcode

### Steg 3: Första körningen
1. Tryck **Cmd+R** eller klicka "Play"-knappen
2. Om du får "Developer not trusted":
   - Gå till **Inställningar** → **Allmänt** → **VPN och enhetshantering**
   - Välj din utvecklarprofil
   - Tryck **Lita på [Ditt namn]**

---

## 🎮 Vad du kan testa

### ✅ Huvudfunktioner
- **SpelSmart-scenarier:** Interaktiva fotbollssituationer med beslutspunkter
- **Gamification:** XP-system, nivåer, badges
- **Dagliga utmaningar:** Streak-system och specialmål
- **Profil:** Skill radar och framstegsspårning
- **Avatar:** Personalisering och anpassning

### ✅ AI-funktioner
- **Intelligent feedback** på taktiska beslut
- **Personliga rekommendationer** baserat på prestationer
- **Adaptiv svårighetsgrad** som anpassar sig efter din utveckling

### ✅ Visuella effekter
- **XP-animationer** när du får poäng
- **Level-up celebrationer** med partiklar
- **Badge-notifikationer** för nya prestationer
- **Smooth animationer** på fotbollsplanen

---

## 🐛 Felsökning

### Problem: "Build failed"
**Lösning:** Kontrollera att alla filer är korrekt tillagda och att det inte finns några syntaxfel.

### Problem: "JSON file not found"
**Lösning:** Se till att `.json`-filerna finns i Bundle Resources i Build Phases.

### Problem: "Developer not trusted"
**Lösning:** Gå till iPhone-inställningar och lita på utvecklarprofilen.

### Problem: App kraschar vid start
**Lösning:** Kolla Console i Xcode för felmeddelanden och kontrollera att alla dependencies är korrekt konfigurerade.

---

## 📊 Testscenarios att prova

### 🎯 Scenario 1: Första intrycket
1. Öppna appen första gången
2. Skapa din avatar
3. Prova första SpelSmart-scenariot
4. Kolla din profil och se XP/nivå

### 🎯 Scenario 2: Daglig utmaning
1. Gå till "Utmaningar"-fliken
2. Starta dagens utmaning
3. Försök få "Utmärkt" bedömning
4. Se bonus XP och eventuell badge

### 🎯 Scenario 3: Progression
1. Spela flera scenarier
2. Kolla skill radar i profilen
3. Se hur olika beslut påverkar olika färdigheter
4. Prova att låsa upp nya badges

### 🎯 Scenario 4: AI-feedback
1. Gör olika typer av beslut i scenarier
2. Läs den detaljerade feedbacken
3. Testa både bra och dåliga val
4. Se hur AI:n anpassar rekommendationer

---

## 🚀 Nästa steg efter testning

När du har testat grundfunktionerna, kan vi:
1. **Förbättra baserat på feedback**
2. **Lägga till fler scenarier**
3. **Implementera multiplayer**
4. **Förbereda för App Store**

---

## 📞 Support

Om du stöter på problem:
1. Kolla Console i Xcode för felmeddelanden
2. Ta skärmdumpar av eventuella fel
3. Beskriv vad du gjorde när problemet uppstod

**Lycka till med testningen! 🎉⚽**