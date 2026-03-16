# Firebase Android Setup – Fixing DEVELOPER_ERROR

If you see `ConnectionResult=DEVELOPER_ERROR` or `Unknown calling package name` in Android logs, your app's SHA-1 certificate fingerprint is not registered in Firebase.

## Quick fix

### 1. Get your SHA-1 fingerprint

From the project root:

```bash
./scripts/get_android_sha1.sh
```

Or with Gradle:

```bash
cd android && ./gradlew signingReport
```

Or with keytool (debug build):

```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

Copy the **SHA-1** value (and **SHA-256** if available).

### 2. Add the fingerprint to Firebase

1. Open [Firebase Console](https://console.firebase.google.com)
2. Select project **parsa-financial-parser-br-2**
3. Go to **Project settings** (gear icon)
4. In **Your apps**, select the Android app (`com.parsa.app`)
5. Click **Add fingerprint**
6. Paste the SHA-1 (and SHA-256 if you have it)
7. Save

### 3. Add release SHA-1 (for production builds)

For release builds, add the SHA-1 of your release keystore:

```bash
keytool -list -v -keystore /path/to/your/keystore.jks -alias your_key_alias
```

Add that SHA-1 to Firebase as well.

## Why this happens

Firebase uses the app signing certificate to verify that requests come from your app. If the SHA-1 of the keystore you use to sign the app is not in Firebase, you get `DEVELOPER_ERROR`.

## Related errors

- **ManagedChannelImpl: Failed to resolve name** – Often occurs until SHA-1 is added
- **GoogleApiManager: Failed to get service from broker** – Same root cause
- **NativeCrypto SSL errors** – Usually unrelated; often from ngrok or connection teardown
