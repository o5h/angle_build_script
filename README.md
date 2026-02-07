# ANGLE build script (Windows)

This repo provides a simple Bash script to download and build ANGLE (OpenGL ES for Windows) using vcpkg, then copy the runtime, import libs, and headers into a local distribution folder.

## What it does

- Clones vcpkg if needed
- Bootstraps vcpkg
- Builds ANGLE for x64-windows
- Copies binaries, libs, and headers into ./angle_dist

## Requirements

- Windows
- Git
- Visual Studio (or Build Tools) with C++ toolchain
- Bash shell (Git Bash or WSL)

Prerequisite Visual Studio Build Tools:

- MSVC Build Tools for x64/x86 (tested onLatest)
- Windows 11 SDK (tested on 10.0.22621.0)

## Usage

From the repo root:

```bash
./instal.sh
```

## Output

Artifacts are placed under:

- ./angle_dist/bin (libEGL.dll, libGLESv2.dll, optional d3dcompiler_47.dll)
- ./angle_dist/lib (libEGL.lib, libGLESv2.lib)
- ./angle_dist/include (KHR/EGL/GLES headers)

## Notes

- The script sets VCPKG_VISUAL_STUDIO_PATH to the default VS Community 2022 path. Adjust if needed.
- If a vcpkg.json is present, the script uses it as a manifest install.
