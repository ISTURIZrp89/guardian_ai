#!/usr/bin/env bash
set -e

FLUTTER_DIR="$HOME/flutter"
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOCAL_BIN="$HOME/.local/bin"

echo "=============================="
echo "  GUARDIAN AI - LAUNCHER"
echo "=============================="

# --- Flutter SDK ---
if [ ! -d "$FLUTTER_DIR" ]; then
    echo "[1/3] Descargando Flutter SDK..."
    cd /tmp
    curl -#LO https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.27.4-stable.tar.xz
    echo "[2/3] Extrayendo..."
    tar -xf flutter_linux_3.27.4-stable.tar.xz -C "$HOME"
    rm flutter_linux_3.27.4-stable.tar.xz
else
    echo "[1/3] Flutter SDK encontrado en $FLUTTER_DIR"
fi

export PATH="$PATH:$FLUTTER_DIR/bin:$LOCAL_BIN"

# --- Ninja (needed for Linux/Android builds) ---
if ! which ninja &>/dev/null; then
    echo "[!] Instalando ninja..."
    mkdir -p "$LOCAL_BIN"
    curl -sL https://github.com/ninja-build/ninja/releases/download/v1.12.1/ninja-linux.zip -o /tmp/ninja.zip
    unzip -o /tmp/ninja.zip -d "$LOCAL_BIN" && chmod +x "$LOCAL_BIN/ninja"
    rm /tmp/ninja.zip
fi

# --- clang++ wrapper (needed for Linux builds without clang) ---
if ! which clang++ &>/dev/null && which g++ &>/dev/null; then
    echo "[!] Creando wrapper clang++ -> g++..."
    mkdir -p "$LOCAL_BIN"
    cat > "$LOCAL_BIN/clang++" << 'WRAP'
#!/usr/bin/env bash
exec g++ "$@"
WRAP
    chmod +x "$LOCAL_BIN/clang++"
fi

export PATH="$LOCAL_BIN:$PATH"

echo "[2/3] Instalando dependencias..."
cd "$PROJECT_DIR"
flutter pub get

echo ""
echo "======================================"
echo "  SELECCIONA DESTINO"
echo "======================================"
echo ""
echo "  Plataforma       Estado"
echo "  --------         ------"
echo "  1) Chrome (web)  ✓ LISTO"
echo "  2) Linux         ✗ requiere: pkg-config + libgtk-3-dev (sudo apt install)"
echo "  3) Android       ✗ requiere: Android SDK instalado"
echo ""
read -rp "Opción [1-3] (default 1): " opt

case "${opt:-1}" in
    1) flutter run -d chrome ;;
    2)
        echo ""
        echo "======================================"
        echo "  Para Linux, instala dependencias:"
        echo "======================================"
        echo "  sudo apt install clang ninja-build"
        echo "  sudo apt install pkg-config libgtk-3-dev"
        echo "  sudo apt install liblzma-dev libstdc++-15-dev"
        echo ""
        echo "  Luego ejecuta: flutter run -d linux"
        echo ""
        exit 1
        ;;
    3)
        echo ""
        echo "======================================"
        echo "  Para Android, instala Android SDK:"
        echo "======================================"
        echo "  Visita: https://flutter.dev/to/linux-android-setup"
        echo ""
        echo "  Luego ejecuta: flutter run"
        echo ""
        exit 1
        ;;
    *) flutter run -d chrome ;;
esac
