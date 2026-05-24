#!/bin/bash

# ============================================================
#  Guardian AI — Script de desarrollo móvil (LAN)
#  Ejecuta la app en la red local para poder verla en el móvil
# ============================================================

PORT=8080
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║         Guardian AI — Mobile Dev         ║"
echo "╚══════════════════════════════════════════╝"
echo ""

# 1. Detectar IP local automáticamente
LOCAL_IP=$(hostname -I | awk '{print $1}')

if [ -z "$LOCAL_IP" ]; then
  echo "❌ No se pudo detectar la IP local. Verifica tu conexión Wi-Fi."
  exit 1
fi

echo "🌐 IP Local detectada: $LOCAL_IP"
echo "📱 URL para tu móvil: http://$LOCAL_IP:$PORT"
echo ""

# 2. Abrir el puerto en el firewall (UFW) si está activo
if command -v ufw &> /dev/null; then
  UFW_STATUS=$(sudo ufw status | head -1)
  if [[ "$UFW_STATUS" == *"active"* ]]; then
    echo "🔓 Abriendo puerto $PORT en UFW..."
    sudo ufw allow $PORT/tcp > /dev/null 2>&1
    echo "   ✅ Puerto $PORT abierto."
  else
    echo "ℹ️  UFW no está activo. No se necesita abrir puertos."
  fi
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " Abre este link en el navegador de tu móvil:"
echo ""
echo "   👉  http://$LOCAL_IP:$PORT"
echo ""
echo " (Tu móvil debe estar en la misma red Wi-Fi)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 3. Entrar a la carpeta del proyecto y lanzar Flutter
cd "$PROJECT_DIR"

echo "🚀 Iniciando Flutter en modo web LAN..."
echo ""
flutter run -d chrome \
  --web-hostname 0.0.0.0 \
  --web-port $PORT
