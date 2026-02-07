#!/bin/bash

# -----------------------------------------------------------------------------
# Script to download and build ANGLE (OpenGL ES for Windows) using vcpkg
# -----------------------------------------------------------------------------

# Directory settings
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
VCPKG_DIR="$SCRIPT_DIR/vcpkg"
OUTPUT_DIR="$SCRIPT_DIR/angle_dist"
MANIFEST_FILE="$SCRIPT_DIR/vcpkg.json"

echo "=========================================="
echo "   ANGLE Downloader & Builder (Win64)     "
echo "=========================================="

# 1. Check for Visual Studio Build Tools (Basic check)
if ! command -v cl &> /dev/null && [ ! -f "C:/Program Files (x86)/Microsoft Visual Studio/Installer/vswhere.exe" ]; then
    echo "WARNING: Visual Studio C++ compiler not detected in standard paths."
    echo "Make sure you have Visual Studio installed, or the build will fail."
    echo "Proceeding anyway..."
fi

# Ensure vcpkg can find Visual Studio
export VCPKG_VISUAL_STUDIO_PATH="C:/Program Files/Microsoft Visual Studio/18/Community"

# 2. Clone vcpkg if it doesn't exist
if [ ! -d "$VCPKG_DIR" ]; then
    echo "[1/4] Cloning vcpkg repository..."
    git clone https://github.com/microsoft/vcpkg.git "$VCPKG_DIR"
else
    echo "[1/4] vcpkg already cloned. Skipping."
fi

# 3. Bootstrap vcpkg
echo "[2/4] Bootstrapping vcpkg..."
if [ ! -f "$VCPKG_DIR/vcpkg.exe" ]; then
    if [ ! -x "$VCPKG_DIR/bootstrap-vcpkg.sh" ]; then
        chmod +x "$VCPKG_DIR/bootstrap-vcpkg.sh"
    fi
    "$VCPKG_DIR/bootstrap-vcpkg.sh" -disableMetrics
else
    echo "      vcpkg executable already exists."
fi

# 4. Install ANGLE (x64-windows)
echo "[3/4] Building ANGLE (This may take 5-10 minutes)..."
MAX_RETRIES=3
attempt=1
while [ $attempt -le $MAX_RETRIES ]; do
    echo "Attempt $attempt of $MAX_RETRIES"
    if [ -f "$MANIFEST_FILE" ]; then
        "$VCPKG_DIR/vcpkg.exe" install --triplet=x64-windows --x-manifest-root="$SCRIPT_DIR" && break
    else
        "$VCPKG_DIR/vcpkg.exe" install angle --triplet=x64-windows && break
    fi
    if [ $attempt -eq $MAX_RETRIES ]; then
        echo "ERROR: vcpkg install failed after $MAX_RETRIES attempts."
        exit 1
    fi
    attempt=$((attempt + 1))
    echo "Retrying in 5 seconds..."
    sleep 5
done

# 5. Copy artifacts to output folder
echo "[4/4] Copying binaries to $OUTPUT_DIR..."

# Create directories
mkdir -p "$OUTPUT_DIR/bin"
mkdir -p "$OUTPUT_DIR/lib"
mkdir -p "$OUTPUT_DIR/include"

# Copy DLLs (Runtime)
cp "$VCPKG_DIR/installed/x64-windows/bin/libEGL.dll" "$OUTPUT_DIR/bin/"
cp "$VCPKG_DIR/installed/x64-windows/bin/libGLESv2.dll" "$OUTPUT_DIR/bin/"
# Optional: Copy d3dcompiler if present (needed for some configurations)
if [ -f "$VCPKG_DIR/installed/x64-windows/bin/d3dcompiler_47.dll" ]; then
    cp "$VCPKG_DIR/installed/x64-windows/bin/d3dcompiler_47.dll" "$OUTPUT_DIR/bin/"
fi

# Copy Libs (Linker)
cp "$VCPKG_DIR/installed/x64-windows/lib/libEGL.lib" "$OUTPUT_DIR/lib/"
cp "$VCPKG_DIR/installed/x64-windows/lib/libGLESv2.lib" "$OUTPUT_DIR/lib/"

# Copy Headers (Compiler)
# ANGLE headers are usually inside include/KHR, include/EGL, include/GLES*
cp -r "$VCPKG_DIR/installed/x64-windows/include/"* "$OUTPUT_DIR/include/"

echo ""
echo "=========================================="
echo "SUCCESS!"
echo "=========================================="
echo "Binaries are located in: $OUTPUT_DIR"
echo " - Runtime: ./angle_dist/bin (libEGL.dll, libGLESv2.dll)"
echo " - Linker:  ./angle_dist/lib"
echo " - Headers: ./angle_dist/include"
