#!/bin/bash

# ============================================================
#  Guardian AI — Setup Android SDK + Emulador
#  Instala todas las herramientas necesarias para Android
# ============================================================

set -e

echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║     Guardian AI — Android Setup Script       ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# ── Variables ──────────────────────────────────────────────
ANDROID_HOME="$HOME/Android/Sdk"
CMDLINE_TOOLS_VERSION="11076708"
CMDLINE_TOOLS_ZIP="commandlinetools-linux-${CMDLINE_TOOLS_VERSION}_latest.zip"
CMDLINE_TOOLS_URL="https://dl.google.com/android/repository/${CMDLINE_TOOLS_ZIP}"
AVD_NAME="GuardianAI_Pixel6"
SYSTEM_IMAGE="system-images;android-34;google_apis;x86_64"

# ── 1. Dependencias del sistema ─────────────────────────────
echo "📦 Instalando dependencias del sistema..."
sudo apt-get update -qq
sudo apt-get install -y -qq \
  openjdk-17-jdk \
  unzip \
  wget \
  curl \
  libgl1 \
  libpulse0 \
  libvirt-daemon-system \
  qemu-kvm \
  cpu-checker > /dev/null 2>&1
echo "   ✅ Dependencias instaladas."

# ── 2. KVM (Virtualización para el emulador) ────────────────
echo ""
echo "⚙️  Configurando KVM (virtualización)..."
if groups "$USER" | grep -q kvm; then
  echo "   ℹ️  Ya estás en el grupo kvm."
else
  sudo adduser "$USER" kvm
  echo "   ✅ Usuario añadido al grupo kvm."
fi

# ── 3. Descargar Android Command Line Tools ─────────────────
echo ""
echo "📥 Descargando Android Command Line Tools..."
mkdir -p "$ANDROID_HOME/cmdline-tools"
cd /tmp

if [ ! -f "$CMDLINE_TOOLS_ZIP" ]; then
  wget -q --show-progress "$CMDLINE_TOOLS_URL"
fi

unzip -q -o "$CMDLINE_TOOLS_ZIP" -d "$ANDROID_HOME/cmdline-tools"
# Renombrar a 'latest' para que Flutter lo reconozca
if [ -d "$ANDROID_HOME/cmdline-tools/cmdline-tools" ]; then
  mv "$ANDROID_HOME/cmdline-tools/cmdline-tools" "$ANDROID_HOME/cmdline-tools/latest"
fi
echo "   ✅ Command Line Tools instalados."

# ── 4. Variables de entorno ─────────────────────────────────
echo ""
echo "🔧 Configurando variables de entorno..."
BASHRC="$HOME/.bashrc"

if ! grep -q "ANDROID_HOME" "$BASHRC"; then
  cat >> "$BASHRC" <<EOF

# Android SDK
export ANDROID_HOME="$ANDROID_HOME"
export PATH="\$PATH:\$ANDROID_HOME/cmdline-tools/latest/bin"
export PATH="\$PATH:\$ANDROID_HOME/platform-tools"
export PATH="\$PATH:\$ANDROID_HOME/emulator"
EOF
fi
export ANDROID_HOME="$ANDROID_HOME"
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator"
echo "   ✅ Variables configuradas."

# ── 5. Aceptar licencias e instalar paquetes ────────────────
echo ""
echo "📦 Instalando Android SDK, Platform-Tools y Emulador..."
echo "   (Esto puede tomar varios minutos)"
yes | sdkmanager --licenses > /dev/null 2>&1 || true
sdkmanager \
  "platform-tools" \
  "platforms;android-34" \
  "build-tools;34.0.0" \
  "emulator" \
  "$SYSTEM_IMAGE"
echo "   ✅ SDK instalado."

# ── 6. Crear AVD (Dispositivo Virtual) ─────────────────────
echo ""
echo "📱 Creando emulador Pixel 6 (Android 14)..."
echo "no" | avdmanager create avd \
  --name "$AVD_NAME" \
  --package "$SYSTEM_IMAGE" \
  --device "pixel_6" \
  --force > /dev/null 2>&1
echo "   ✅ Emulador '$AVD_NAME' creado."

# ── 7. Configurar Flutter para usar Android SDK ─────────────
echo ""
echo "🎯 Configurando Flutter..."
cd ~/guardian_ai
flutter config --android-sdk "$ANDROID_HOME" > /dev/null 2>&1
yes | flutter doctor --android-licenses > /dev/null 2>&1 || true
echo "   ✅ Flutter configurado."

# ── 8. Instrucciones finales ────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "✅ ¡Instalación completada!"
echo ""
echo "   Para iniciar el emulador, ejecuta:"
echo "   👉  ~/guardian_ai/run_android.sh"
echo ""
echo "   Recarga tu terminal con:"
echo "   👉  source ~/.bashrc"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
