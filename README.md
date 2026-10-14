# Nyan Clock

A tiny desktop clock for macOS and Windows 11: Nyan Cat with the date and time (`YYYY/MM/DD(Mon) HH:mm`) next to it.

- Drag anywhere on the clock to move it. The position is restored on next launch.
- Right-click the clock (or click the menu bar / tray icon) for settings:
  - **Always on Top** — keep the clock above other windows.
  - **Show Menu Bar Icon** (macOS) / **Show Tray Icon** (Windows) — show or hide the icon.
  - **Quit Nyan Clock**

| Directory | Platform | Stack |
|---|---|---|
| [`macos/`](macos) | macOS 13 or later. Runs without a Dock icon. | Swift + AppKit |
| [`windows/`](windows) | Windows 11 (x64). Runs without a taskbar button. | Tauri 2 + Rust |

## Install

### macOS

1. Download `NyanClock-x.y.z-macos.zip` from [Releases](../../releases) and unzip it.
2. Move `NyanClock.app` to `/Applications`.
3. The app is ad-hoc signed and not notarized, so remove the quarantine flag before the first launch:

   ```sh
   xattr -dr com.apple.quarantine /Applications/NyanClock.app
   ```

To start at login, add it in System Settings → General → Login Items.

### Windows

1. Download `NyanClock-x.y.z-windows-x64.exe` from [Releases](../../releases) and put it anywhere (it is a single portable exe).
2. Run it. The exe is not code-signed, so SmartScreen may warn: click **More info** → **Run anyway**.

Uses the WebView2 runtime that ships with Windows 11. To start at sign-in, put a shortcut to the exe in `shell:startup`.

## Build

### macOS

```sh
macos/build.sh                # macos/build/NyanClock.app (universal: arm64 + x86_64)
open macos/build/NyanClock.app
```

Set `VERSION=1.2.3` to stamp a version into `Info.plist`.

### Windows

Requires [Rust](https://rustup.rs/) (MSVC toolchain).

```sh
cd windows
cargo build --release         # target/release/NyanClock.exe
```

Set `TAURI_CONFIG='{"version":"1.2.3"}'` to stamp a version into the exe.

## Release

Run the **Release** workflow (Actions → Release → Run workflow) on `main` and choose `patch`, `minor` or `major`.
It increments the latest `vX.Y.Z` tag (starting from `v0.0.0`), builds both apps, and publishes a GitHub release with the zipped macOS app and the Windows exe.

## Credits

Nyan Cat artwork by Chris Torres ([nyan.cat](https://www.nyan.cat/)). The image is taken from Wikipedia and is not covered by this repository's license.
