# ============================================
# KEYSTORE SETUP GUIDE - FinTrack Pro
# ============================================

## ⚠️ PENTING: BACA SEBELUM MELANJUTKAN!

Keystore adalah kunci digital untuk menandatangani aplikasi Anda. 
Google Play Store MEMERLUKAN ini untuk verifikasi keaslian aplikasi.

**PERINGATAN:**
- Jika Anda kehilangan keystore, Anda TIDAK AKAN PERNAH bisa update aplikasi!
- Backup keystore di tempat aman (cloud, external drive, dll)
- Jangan commit keystore ke Git!

---

## 📝 LANGKAH 1: BUAT KEYSTORE

### Option A: Menggunakan Command Line (Recommended)

```bash
cd /workspace/android

# Jalankan command berikut:
keytool -genkey -v \
  -keystore fintrack-pro-keystore.jks \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias fintrack-pro \
  -storetype PKCS12
```

**Anda akan diminta memasukkan:**
1. **Keystore password** - Minimal 6 karakter (CATAT INI!)
2. **Nama dan Belakang** - Bisa nama Anda
3. **Nama Organisasi** - Bisa nama Anda atau "Individual"
4. **Kota/Kabupaten** - Kota Anda
5. **Provinsi** - Provinsi Anda
6. **Kode Negara** - ID untuk Indonesia
7. **Konfirmasi** - Ketik 'ya' untuk konfirmasi

### Option B: Menggunakan Android Studio

1. Buka Android Studio
2. Build → Generate Signed Bundle / APK
3. Pilih "Android App Bundle"
4. Klik "Create new..."
5. Isi form dan simpan di `/workspace/android/fintrack-pro-keystore.jks`

---

## 📝 LANGKAH 2: BUAT FILE KEY.PROPERTIES

Buat file baru di `/workspace/android/key.properties`:

```properties
storePassword=<PASSWORD_YANG_ANDA_MASUKKAN_DI_LANGKAH_1>
keyPassword=<PASSWORD_YANG_SAMA_ATAU_BEDA>
keyAlias=fintrack-pro
storeFile=../fintrack-pro-keystore.jks
```

**Ganti `<PASSWORD_...>` dengan password yang Anda buat!**

Contoh:
```properties
storePassword=MySecurePass123!
keyPassword=MySecurePass123!
keyAlias=fintrack-pro
storeFile=../fintrack-pro-keystore.jks
```

---

## 📝 LANGKAH 3: BACKUP KEYSTORE

**WAJIB DILAKUKAN!** Backup keystore ke minimal 2 lokasi:

1. **Cloud Storage:**
   ```bash
   # Upload ke Google Drive / Dropbox / OneDrive
   cp /workspace/android/fintrack-pro-keystore.jks ~/GoogleDrive/Backups/
   ```

2. **External Drive:**
   ```bash
   cp /workspace/android/fintrack-pro-keystore.jks /mnt/usb-drive/
   ```

3. **Password Manager:**
   - Simpan password di LastPass, 1Password, atau Bitwarden
   - Simpan informasi keystore sebagai secure note

---

## 📝 LANGKAH 4: VERIFIKASI SETUP

Jalankan command berikut untuk test build:

```bash
cd /workspace

# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Build release AAB (Android App Bundle)
flutter build appbundle --release
```

Jika berhasil, output akan ada di:
```
/workspace/build/app/outputs/bundle/release/app-release.aab
```

---

## 🔒 KEAMANAN KEYSTORE

### DO's ✅
- [ ] Backup di multiple locations
- [ ] Gunakan password kuat (min 12 karakter)
- [ ] Simpan password di password manager
- [ ] Test restore backup sebelum upload ke Play Store
- [ ] Catat informasi keystore di tempat aman

### DON'Ts ❌
- [ ] JANGAN commit keystore ke Git
- [ ] JANGAN share password ke siapapun
- [ ] JANGAN simpan hanya di 1 tempat
- [ ] JANGAN lupa password (tidak bisa di-reset!)
- [ ] JANGAN gunakan password yang sama dengan akun lain

---

## 🛡️ TAMBAHKAN KE .GITIGNORE

Pastikan file berikut ada di `.gitignore`:

```gitignore
# Keystore files
*.jks
*.keystore
key.properties

# Build outputs
build/
*.aab
*.apk

# IDE
.idea/
.vscode/
*.iml
```

Cek apakah sudah ada di `/workspace/.gitignore`:

---

## 📋 INFORMASI YANG HARUS DICATAT

Simpan informasi ini di tempat AMAN (password manager recommended):

```
=== KEYSTORE INFORMATION ===
App Name: FinTrack Pro
Keystore File: fintrack-pro-keystore.jks
Location: /workspace/android/
Alias: fintrack-pro
Store Type: PKCS12
Key Algorithm: RSA
Key Size: 2048 bits
Validity: 10000 days (~27 years)
Created Date: [TANGGAL PEMBUATAN]

=== PASSWORDS ===
Store Password: [SIMPAN DI PASSWORD MANAGER]
Key Password: [SIMPAN DI PASSWORD MANAGER]

=== BACKUP LOCATIONS ===
1. [LOKASI BACKUP 1]
2. [LOKASI BACKUP 2]
3. [LOKASI BACKUP 3]

=== GOOGLE PLAY CONSOLE ===
Developer Account: [EMAIL ANDA]
App Name: FinTrack Pro - Expense Tracker
Package Name: id.web.nurindra.fintrack_pro
```

---

## 🚨 JIKA KEYSTORE HILANG

Jika Anda kehilangan keystore atau lupa password:

1. **Tidak ada cara untuk recover!**
2. Anda harus:
   - Buat keystore BARU dengan alias BERBEDA
   - Upload sebagai aplikasi BARU di Play Store
   - Aplikasi lama tidak bisa di-update
   - Users harus install ulang dari awal
   - Rating dan review hilang

**MAKA DARI ITU, BACKUP SEKARANG JUGA!**

---

## ✅ CHECKLIST SEBELUM UPLOAD

- [ ] Keystore dibuat dan disimpan di `/workspace/android/fintrack-pro-keystore.jks`
- [ ] File `key.properties` dibuat dengan password yang benar
- [ ] Backup keystore di minimal 2 lokasi berbeda
- [ ] Password disimpan di password manager
- [ ] Test build AAB berhasil
- [ ] File `.gitignore` sudah include keystore files
- [ ] Informasi keystore dicatat di tempat aman

---

## 📞 NEXT STEPS

Setelah setup keystore selesai:

1. Build AAB: `flutter build appbundle --release`
2. Login ke Google Play Console: https://play.google.com/console
3. Create new app
4. Upload AAB file
5. Complete store listing
6. Submit for review

Lihat `PLAYSTORE_READINESS.md` untuk panduan lengkap!

---

**Generated:** $(date)
**App Version:** 1.0.0+1
**Package:** id.web.nurindra.fintrack_pro
