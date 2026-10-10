# Nyan Clock

A tiny desktop clock for macOS: Nyan Cat with a digital clock (`HH:mm`) next to it.

- Drag anywhere on the clock to move it. The position is restored on next launch.
- Right-click the clock (or click the menu bar icon) for settings:
  - **Always on Top** — keep the clock above other windows.
  - **Show Menu Bar Icon** — show or hide the menu bar icon.
  - **Quit Nyan Clock**

Requires macOS 13 or later. Runs without a Dock icon.

## Install

1. Download `NyanClock-x.y.z.zip` from [Releases](../../releases) and unzip it.
2. Move `NyanClock.app` to `/Applications`.
3. The app is ad-hoc signed and not notarized, so remove the quarantine flag before the first launch:

   ```sh
   xattr -dr com.apple.quarantine /Applications/NyanClock.app
   ```

To start at login, add it in System Settings → General → Login Items.

## Build

```sh
./build.sh                # build/NyanClock.app (universal: arm64 + x86_64)
open build/NyanClock.app
```

Set `VERSION=1.2.3` to stamp a version into `Info.plist`.

## Release

Run the **Release** workflow (Actions → Release → Run workflow) on `main` and choose `patch`, `minor` or `major`.
It increments the latest `vX.Y.Z` tag (starting from `v0.0.0`), builds the app, and publishes a GitHub release with the zipped app.

## Credits

Nyan Cat artwork by Chris Torres ([nyan.cat](https://www.nyan.cat/)). The image is taken from Wikipedia and is not covered by this repository's license.
