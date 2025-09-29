# 🚀 SpelSmart - App Store Connect & TestFlight Guide

## 📋 **Förberedelser**

### **Krav:**
- ✅ Apple Developer Program (99$/år)
- ✅ Xcode med ditt Developer Team konfigurerat
- ✅ SpelSmart projektet bygger utan fel

---

## 🎯 **Steg 1: App Store Connect Setup**

### **1.1 Logga in på App Store Connect**
1. Gå till [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
2. Logga in med ditt Apple Developer-konto

### **1.2 Skapa ny app**
1. Klicka **"My Apps"** → **"+"** → **"New App"**
2. Fyll i informationen:
   - **Platforms:** iOS
   - **Name:** SpelSmart
   - **Primary Language:** Swedish
   - **Bundle ID:** `com.ajagames.learnfotball` (eller din egen)
   - **SKU:** `spelsmart-ios-001`

### **1.3 Grundläggande App-information**
```
App Name: SpelSmart
Subtitle: AI-driven Fotbollsträning
Category: Sports
Content Rights: No, it does not contain, show, or access third-party content
Age Rating: 4+ (lämplig för barn)
```

---

## 📱 **Steg 2: Konfigurera Xcode för Release**

### **2.1 Uppdatera projekt-inställningar**

I Xcode, gå till ditt projekt och uppdatera:

**General Tab:**
- **Display Name:** SpelSmart
- **Bundle Identifier:** `com.ajagames.learnfotball`
- **Version:** 1.0.0
- **Build:** 1

**Signing & Capabilities:**
- **Team:** Ditt Apple Developer Team
- **Provisioning Profile:** Automatic
- **Signing Certificate:** Apple Distribution

### **2.2 Lägg till App Icons**

Skapa app-ikoner i följande storlekar och lägg till i `Assets.xcassets`:
- 20x20 pt (40x40, 60x60 pixels)
- 29x29 pt (58x58, 87x87 pixels) 
- 40x40 pt (80x80, 120x120 pixels)
- 60x60 pt (120x120, 180x180 pixels)
- 1024x1024 pixels (App Store)

**Enkel app-ikon design för SpelSmart:**
- Bakgrund: Gradient från limegrön till djupblå
- Symbol: Stiliserad fotboll eller hjärna-ikon
- Text: Inget (bara symbol)

### **2.3 Privacy Info.plist**

Lägg till i `Info.plist` om appen använder specifika funktioner:
```xml
<key>NSUserTrackingUsageDescription</key>
<string>SpelSmart samlar anonymiserad data för att förbättra träningsupplevelsen.</string>
```

---

## 🏗️ **Steg 3: Fastlane Konfiguration (Automatisk Upload)**

### **3.1 Uppdatera Fastfile**

Vårt befintliga Fastfile är redan konfigurerat! Du behöver bara sätta miljövariabler:

```bash
# I terminalen eller i Xcode Build Settings
export ASC_KEY_ID="ditt-key-id"
export ASC_ISSUER_ID="ditt-issuer-id" 
export ASC_API_KEY_P8="din-api-key-content"
```

### **3.2 Skapa API Key för App Store Connect**

1. Gå till [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
2. **Users and Access** → **Keys** → **App Store Connect API**
3. Klicka **"+"** för att skapa ny key
4. **Name:** SpelSmart API Key
5. **Access:** Developer
6. Ladda ner `.p8`-filen (spara säkert!)
7. Notera **Key ID** och **Issuer ID**

---

## 🚀 **Steg 4: Bygg och Ladda upp till TestFlight**

### **4.1 Manuell upload via Xcode**

1. **Välj "Any iOS Device" som destination**
2. **Product** → **Archive**
3. När arkivering är klar, välj **"Distribute App"**
4. Välj **"App Store Connect"**
5. Välj **"Upload"**
6. Följ wizard:
   - **Distribution certificate:** Automatic
   - **App Thinning:** Alla enheter
   - **Upload symbols:** Ja
   - **Manage Version and Build Number:** Ja

### **4.2 Automatisk upload via Fastlane**

```bash
cd ios
fastlane ios ci
```

Detta kommer:
- ✅ Köra tester
- ✅ Bygga release-version
- ✅ Ladda upp till TestFlight automatiskt

---

## 🧪 **Steg 5: TestFlight Setup**

### **5.1 Konfigurera TestFlight**

1. Gå tillbaka till **App Store Connect**
2. **TestFlight** tab
3. Din build bör visas under **"Processing"**
4. Vänta tills status blir **"Ready to Submit"** (5-10 min)

### **5.2 Lägg till Test Information**

```
What to Test:
Testa alla huvudfunktioner i SpelSmart:
- Skapa din avatar och personalisera spelaren
- Spela interaktiva fotbollsscenarier med beslutspunkter  
- Prova XP-systemet och samla badges
- Testa dagliga utmaningar och streak-system
- Kolla din profil och skill radar
- Ge feedback på AI-driven träningsrekommendationer

App Description:
SpelSmart utvecklar barns spelförståelse genom AI-drivna fotbollsscenarier. 
Appen fokuserar på taktiskt tänkande istället för fysisk teknik.
```

### **5.3 Lägg till interna testare**

1. **Internal Testing** → **"+"**
2. Lägg till din egen e-post
3. Lägg till familj/vänner som kan testa

### **5.4 Externa testare (valfritt)**

1. **External Testing** → **"+"**
2. Skapa testgrupp: "SpelSmart Beta Testers"
3. Lägg till upp till 10,000 externa testare
4. **OBS:** Kräver App Review (1-7 dagar)

---

## 📊 **Steg 6: App Store Listing (Förberedelse)**

### **6.1 App Information**

```
Name: SpelSmart
Subtitle: AI-driven Fotbollsträning för Barn
Category: Sports
Secondary Category: Education

Description:
SpelSmart revolutionerar fotbollsträning genom AI-driven spelförståelse. 
Istället för att fokusera på teknisk färdighet, utvecklar appen barns 
taktiska tänkande genom interaktiva matchscenarier.

🧠 HUVUDFUNKTIONER
• Interaktiva fotbollsscenarier med realistiska beslutspunkter
• AI-analys som ger personlig feedback på taktiska val
• Gamification med XP-system, nivåer och badges
• Dagliga utmaningar som håller motivationen uppe
• Skill radar som visar utveckling inom 8 taktiska områden

🎯 MÅLGRUPP
Perfekt för barn 8-14 år som spelar fotboll och vill förbättra sitt 
spelförståelse. Även bra för föräldrar och tränare som vill stödja 
barnens utveckling.

🎮 PEDAGOGISKT FOKUS
Baserat på modern fotbollspedagogik med fokus på:
- Spelöverskåd och scanning
- Positionering och rumsuppfattning
- Beslutsfattande under press
- Kommunikation och lagarbete

Utvecklad i samarbete med licentierade fotbollstränare och 
utbildningsexperter.

Keywords: fotboll, träning, barn, AI, taktik, spelförståelse, sport, utbildning
```

### **6.2 Screenshots (krävs 5 st för iPhone)**

Skapa screenshots som visar:
1. **Huvudmeny** med SpelSmart-branding
2. **Scenario i aktion** med fotbollsplan och beslutspunkter
3. **Profil med skill radar** och progression
4. **Badge-samling** och gamification
5. **Dagliga utmaningar** med streak-system

### **6.3 App Preview Video (valfritt men rekommenderat)**

30-sekunder video som visar:
- Avatar-skapande (3s)
- Interaktivt scenario (15s)
- XP och badges (7s)
- Skill progression (5s)

---

## ⚙️ **Steg 7: Releasehantering**

### **7.1 Version Strategy**

```
1.0.0 - Initial release med kärnfunktioner
1.1.0 - Coach-läge och förbättringar
1.2.0 - Multiplayer-scenarier
2.0.0 - AR-funktioner
```

### **7.2 Build Numbers**

Varje TestFlight-upload behöver unikt build-nummer:
- 1.0.0 (1) - Första TestFlight
- 1.0.0 (2) - Bugfixar
- 1.0.0 (3) - Finala versionen för App Store

---

## 🐛 **Felsökning**

### **Problem: Archive misslyckas**
**Lösning:** 
- Kontrollera att alla certificates är giltiga
- Se till att Provisioning Profile är uppdaterat
- Rensa derived data: Cmd+Shift+K

### **Problem: Upload till App Store Connect misslyckas**
**Lösning:**
- Kontrollera API-nycklar för Fastlane
- Se till att Bundle ID matchar App Store Connect
- Kontrollera att versionnummer är unikt

### **Problem: TestFlight processing fastnar**
**Lösning:**
- Vanligt att det tar 5-15 minuter
- Kontrollera att inga compliance-problem finns
- Vänta och försök igen om >30 min

---

## 📅 **Tidslinje för Release**

### **TestFlight (Samma dag):**
- ✅ Upload build: 10 minuter
- ✅ Processing: 5-15 minuter  
- ✅ Internal testing: Omedelbart
- ⏳ External testing: 1-7 dagar (review)

### **App Store Release:**
- ⏳ App Review: 1-7 dagar
- ✅ Release: Omedelbart efter godkännande

---

## 🎯 **Nästa Steg**

1. **Följ denna guide steg för steg**
2. **Testa grundligt i TestFlight**
3. **Samla feedback från testare**
4. **Förbättra baserat på feedback**
5. **Förbered för offentlig release**

---

## 📞 **Support**

**Apple Developer Support:**
- [developer.apple.com/support](https://developer.apple.com/support)
- App Store Connect Help

**Fastlane Documentation:**
- [docs.fastlane.tools](https://docs.fastlane.tools)

---

**Lycka till med publiceringen! 🚀⚽**