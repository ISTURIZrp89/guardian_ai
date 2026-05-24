#!/bin/bash

# ============================================================
#  Guardian AI — Script de descarga de llama.cpp
#  Clona el código fuente de llama.cpp en el directorio correcto
#  para que Android NDK pueda compilarlo.
# ============================================================

LLAMA_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/native/third_party/llama.cpp"

echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║    Guardian AI — Configurar llama.cpp        ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# Verificar si git está instalado
if ! command -v git &> /dev/null; then
  echo "❌ Git no está instalado. Instálalo con: sudo apt install git"
  exit 1
fi

# Clonar o actualizar llama.cpp
if [ -d "$LLAMA_DIR/.git" ]; then
  echo "🔄 Actualizando llama.cpp existente..."
  cd "$LLAMA_DIR"
  git pull --ff-only
else
  echo "📥 Descargando llama.cpp versión b4553 (API estable)..."
  mkdir -p "$(dirname "$LLAMA_DIR")"
  git clone --depth 1 --branch b4553 https://github.com/ggml-org/llama.cpp.git "$LLAMA_DIR"
fi

echo ""
echo "✅ llama.cpp configurado en: $LLAMA_DIR"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo " Próximos pasos:"
echo ""
echo "   1. Instalar Android SDK: ~/guardian_ai/setup_android.sh"
echo "   2. Compilar y ejecutar:  cd ~/guardian_ai && flutter run"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
