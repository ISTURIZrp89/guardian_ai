#!/bin/bash

# ============================================================
#  Guardian AI — Lanzador de emulador Android + Flutter
# ============================================================

AVD_NAME="GuardianAI_Pixel6"
ANDROID_HOME="$HOME/Android/Sdk"
export PATH="$PATH:$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools"

echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║     Guardian AI — Android Emulator Run       ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# 1. Iniciar emulador en segundo plano
echo "📱 Iniciando emulador '$AVD_NAME'..."
"$ANDROID_HOME/emulator/emulator" -avd "$AVD_NAME" -no-audio -no-boot-anim &
EMULATOR_PID=$!

# 2. Esperar a que el dispositivo esté listo
echo "⏳ Esperando que el dispositivo arranque (puede tardar ~60 segundos)..."
"$ANDROID_HOME/platform-tools/adb" wait-for-device
sleep 10

# 3. Confirmar que está listo
BOOT_COMPLETE=""
while [ "$BOOT_COMPLETE" != "1" ]; do
  BOOT_COMPLETE=$("$ANDROID_HOME/platform-tools/adb" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')
  sleep 3
  echo "   ... esperando arranque completo"
done

echo "   ✅ Emulador listo."
echo ""

# 4. Ejecutar la app de Flutter
echo "🚀 Lanzando Guardian AI en el emulador..."
cd ~/guardian_ai
flutter run

# 5. Limpieza al salir
wait $EMULATOR_PID
