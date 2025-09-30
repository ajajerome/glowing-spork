# 🐧 SpelSmart - Deployment från Linux

Eftersom iOS-utveckling kräver macOS, här är dina alternativ för att deploya SpelSmart från Linux:

## 🎯 **Alternativ 1: GitHub Actions (Rekommenderat - Gratis)**

### **Setup (5 minuter):**

1. **Skapa App Store Connect API Key:**
   - Gå till [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
   - **Users and Access** → **Keys** → **App Store Connect API**
   - Skapa ny nyckel och ladda ner `.p8`-filen

2. **Lägg till GitHub Secrets:**
   - Gå till ditt GitHub repo: `https://github.com/ajajerome/glowing-spork`
   - **Settings** → **Secrets and variables** → **Actions**
   - Lägg till dessa secrets:
   
   ```
   ASC_KEY_ID: din-key-id (från App Store Connect)
   ASC_ISSUER_ID: din-issuer-id (från App Store Connect)
   ASC_API_KEY_P8: innehållet-från-p8-filen (öppna .p8 i texteditor)
   ```

3. **Trigga deployment:**
   - Gå till **Actions** tab i GitHub
   - Välj **"🚀 Deploy to TestFlight"**
   - Klicka **"Run workflow"**
   - Välj **"beta"** för TestFlight eller **"release"** för App Store

### **Vad som händer:**
- ✅ GitHub bygger appen på macOS
- ✅ Automatisk upload till TestFlight
- ✅ Du får notifiering när det är klart
- ✅ Testare kan ladda ner från TestFlight

---

## 🌥️ **Alternativ 2: Cloud Mac Services**

### **MacStadium (Professionell):**
- **Kostnad:** ~$99/månad
- **Setup:** 1-2 timmar
- **Fördelar:** Full macOS-miljö, snabb
- **Länk:** [macstadium.com](https://macstadium.com)

### **MacinCloud (Budget):**
- **Kostnad:** ~$30/månad
- **Setup:** 30 minuter
- **Fördelar:** Billigare, bra för enstaka projekt
- **Länk:** [macincloud.com](https://macincloud.com)

### **AWS EC2 Mac (Enterprise):**
- **Kostnad:** ~$1.08/timme (minimum 24h)
- **Setup:** 2-4 timmar
- **Fördelar:** Skalbar, integrerad med AWS
- **Länk:** [aws.amazon.com/ec2/instance-types/mac](https://aws.amazon.com/ec2/instance-types/mac/)

---

## 💻 **Alternativ 3: Låna/Köp Mac**

### **Billiga alternativ:**
- **Mac Mini M1 (begagnad):** ~8000-12000 kr
- **MacBook Air M1 (begagnad):** ~12000-16000 kr
- **Låna från vän/kollega:** Gratis 😊

### **Vad du behöver:**
- macOS 12+ (Monterey eller senare)
- Xcode 14+
- Apple Developer Account (har du redan)

---

## 🚀 **Rekommendation: GitHub Actions**

**Fördelar:**
- ✅ **Gratis** (2000 minuter/månad på GitHub)
- ✅ **Automatiskt** - bara push kod och trigga
- ✅ **Professionellt** - samma som stora företag använder
- ✅ **Säkert** - inga credentials på din dator
- ✅ **Skalbart** - fungerar för hela teamet

**Nackdelar:**
- ⏳ Tar 10-15 minuter per build
- 🔄 Mindre kontroll över processen

---

## 📋 **Steg-för-steg: GitHub Actions Setup**

### **1. App Store Connect API Setup:**

```bash
# På din Linux-dator, öppna webbläsaren:
# 1. Gå till appstoreconnect.apple.com
# 2. Users and Access → Keys → App Store Connect API
# 3. Klicka "+" för ny nyckel
# 4. Name: "SpelSmart GitHub Actions"
# 5. Access: Developer
# 6. Ladda ner .p8-filen
# 7. Notera Key ID och Issuer ID
```

### **2. GitHub Secrets Setup:**

```bash
# Gå till GitHub repo i webbläsaren:
# https://github.com/ajajerome/glowing-spork/settings/secrets/actions

# Lägg till dessa 3 secrets:
ASC_KEY_ID=2X9R4HXF34          # Från App Store Connect
ASC_ISSUER_ID=57246542-96fe-1a63-e053-0824d011072a  # Från App Store Connect
ASC_API_KEY_P8=-----BEGIN PRIVATE KEY-----
MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQg...
-----END PRIVATE KEY-----      # Innehållet från .p8-filen
```

### **3. Skapa App i App Store Connect:**

```bash
# I webbläsaren:
# 1. appstoreconnect.apple.com → My Apps → "+"
# 2. Name: SpelSmart
# 3. Primary Language: Swedish
# 4. Bundle ID: com.ajagames.learnfotball
# 5. SKU: spelsmart-ios-001
```

### **4. Trigga första deployment:**

```bash
# I GitHub repo:
# 1. Gå till "Actions" tab
# 2. Välj "🚀 Deploy to TestFlight"
# 3. Klicka "Run workflow"
# 4. Välj "beta"
# 5. Klicka "Run workflow"
```

### **5. Vänta och övervaka:**

- ⏱️ **Build tid:** 10-15 minuter
- 📧 **Notifiering:** GitHub skickar email när klart
- 📱 **TestFlight:** Appen dyker upp automatiskt

---

## 🐛 **Felsökning GitHub Actions**

### **Problem: "Build failed"**
```bash
# Lösning:
# 1. Gå till Actions tab i GitHub
# 2. Klicka på den misslyckade körningen
# 3. Läs felmeddelandet
# 4. Vanliga problem:
#    - Fel Bundle ID
#    - Fel API keys
#    - Kod-fel (syntax)
```

### **Problem: "Upload to TestFlight failed"**
```bash
# Lösning:
# 1. Kontrollera att appen finns i App Store Connect
# 2. Kontrollera API key permissions
# 3. Kontrollera Bundle ID matchar
```

### **Problem: "Secrets not found"**
```bash
# Lösning:
# 1. Gå till repo Settings → Secrets and variables → Actions
# 2. Kontrollera att alla 3 secrets finns:
#    - ASC_KEY_ID
#    - ASC_ISSUER_ID  
#    - ASC_API_KEY_P8
# 3. Kontrollera att värdena är korrekta
```

---

## 📊 **Kostnadsjämförelse**

| Alternativ | Kostnad/månad | Setup-tid | Flexibilitet |
|------------|---------------|-----------|--------------|
| GitHub Actions | Gratis* | 5 min | Låg |
| MacinCloud | $30 | 30 min | Medium |
| MacStadium | $99 | 2h | Hög |
| Mac Mini (köp) | $0** | 1h | Hög |

*Gratis upp till 2000 minuter/månad
**Efter engångskostnad ~10000 kr

---

## 🎯 **Min rekommendation:**

**För SpelSmart:** Använd **GitHub Actions**
- Perfekt för ett enda projekt
- Professionell CI/CD pipeline
- Ingen extra kostnad
- Lär dig moderna deployment-metoder

**För framtiden:** Om du planerar fler iOS-appar, investera i en **begagnad Mac Mini M1**.

---

## 📞 **Support**

**GitHub Actions problem:**
- Kolla Actions-loggar i GitHub
- GitHub Community Forum
- Stack Overflow

**App Store Connect problem:**
- Apple Developer Support
- App Store Connect Help

---

**Lycka till! Med GitHub Actions kan du deploya SpelSmart till TestFlight direkt från Linux! 🚀🐧**