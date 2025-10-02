# 🍎 Apple ID Login Guide för TestFlight

## 🎯 **Varför Apple ID Login?**

API Keys har varit problematiska i CI/CD. Apple ID + App-Specific Password är en mer direkt metod som ofta fungerar bättre.

---

## 🔑 **Steg 1: Skapa App-Specific Password**

### **1.1 Gå till Apple ID-inställningar:**
1. Öppna [appleid.apple.com](https://appleid.apple.com)
2. Logga in med ditt Apple Developer-konto

### **1.2 Skapa App-Specific Password:**
1. Under **"Security"** sektion
2. Klicka **"App-Specific Passwords"**
3. Klicka **"+"** eller **"Generate Password"**
4. **Label:** `TaktikTräning GitHub Actions`
5. Klicka **"Create"**

### **1.3 Spara lösenordet:**
Apple visar lösenordet EN GÅNG - spara det säkert!
```
Exempel: abcd-efgh-ijkl-mnop
```

---

## 🚀 **Steg 2: Kör Apple ID Login Workflow**

### **2.1 Starta workflow:**
1. Gå till [GitHub Actions](https://github.com/ajajerome/glowing-spork/actions)
2. Klicka **"🍎 Apple ID Login TestFlight"**
3. Klicka **"Run workflow"**

### **2.2 Fyll i uppgifter:**
- **Apple ID email:** din-email@example.com
- **App-specific password:** abcd-efgh-ijkl-mnop
- Klicka **"Run workflow"**

---

## ⚙️ **Vad som händer i workflow:**

### **🔐 Authentication:**
1. **Sparar app-specific password** i macOS Keychain
2. **Testar inloggning** med `xcrun altool --list-apps`
3. **Verifierar** att authentication fungerar

### **🏗️ Build Process:**
1. **XcodeGen** genererar TaktikTräning.xcodeproj
2. **xcodebuild archive** med Apple ID authentication
3. **xcodebuild export** till IPA
4. **xcrun altool upload** till TestFlight

### **🧹 Cleanup:**
1. **Tar bort lösenord** från Keychain
2. **Rensar build-filer**

---

## 🎯 **Fördelar med Apple ID Login:**

### **✅ Enklare än API Keys:**
- Inga komplicerade .p8-filer
- Direkt Apple ID + lösenord
- Samma som du använder manuellt

### **✅ Mer tillförlitligt:**
- xcrun altool är Apples officiella verktyg
- Mindre risk för authentication-fel
- Fungerar som manuell upload

### **✅ Bättre felmeddelanden:**
- Tydligare output från xcrun altool
- Enklare att felsöka
- Direkt feedback från Apple

---

## 🔒 **Säkerhet:**

### **App-Specific Password är säkert:**
- ✅ **Inte ditt riktiga lösenord** - bara för appar
- ✅ **Kan återkallas** när som helst
- ✅ **Begränsade behörigheter** - bara App Store
- ✅ **Sparas säkert** i macOS Keychain under workflow

### **Workflow-säkerhet:**
- ✅ **Lösenord syns inte** i GitHub logs (maskerat)
- ✅ **Sparas temporärt** i Keychain under build
- ✅ **Rensas automatiskt** efter workflow
- ✅ **Ingen permanent lagring**

---

## 🐛 **Felsökning:**

### **Problem: "Invalid credentials"**
**Lösning:** 
- Kontrollera att Apple ID är korrekt
- Kontrollera att app-specific password är rätt
- Skapa nytt app-specific password

### **Problem: "Two-factor authentication required"**
**Lösning:**
- App-specific password hoppar över 2FA
- Kontrollera att du använder app-specific password, inte vanligt lösenord

### **Problem: "No apps found"**
**Lösning:**
- Kontrollera att Apple ID har tillgång till rätt Developer Team
- Kontrollera att TaktikTräning-appen finns i App Store Connect

---

## 🎉 **Resultat:**

Efter framgångsrik körning:
- ✅ **TaktikTräning** dyker upp i TestFlight
- ✅ **Alla SpelSmart-funktioner** fungerar
- ✅ **Installera på iPhone** och testa

---

**Apple ID Login är ofta mer tillförlitligt än API Keys för CI/CD! 🍎🚀**