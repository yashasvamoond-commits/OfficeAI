# OfficeCLI Library for Android

A small installable Android reference companion for the upstream [OfficeCLI](https://github.com/iOfficeAI/OfficeCLI) project. It provides an offline-friendly overview and links to the full source archive and desktop CLI releases.

**This is not an Android port of the OfficeCLI engine.** The upstream project is a .NET desktop command-line application; document editing and rendering are not implemented by this Android companion.

## Build

The build script expects a Java runtime, Node.js/npm, a local Android packaging utility (`@postar/apktool-node`), and a checkout of the upstream repository. It compiles the app from the included smali/HTML sources, then signs the result with a throwaway key unless a keystore is specified.

```sh
npm ci --prefix android-app
ANDROID_TOOLS_DIR="$PWD/android-app" \\
  ./android-app/scripts/build.sh /path/to/OfficeCLI /tmp/OfficeCLI-Library.apk
```

GitHub Actions builds an APK on manual dispatch. The downloadable APK is published as a GitHub Release asset.
