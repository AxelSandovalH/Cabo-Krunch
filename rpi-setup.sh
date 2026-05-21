#!/bin/bash
# ─────────────────────────────────────────────
#  Cabo Krunch — Raspberry Pi 4 Kiosk Setup
#  Ejecutar como usuario pi: bash rpi-setup.sh
# ─────────────────────────────────────────────

set -e

echo ""
echo "  CABO KRUNCH — RPi Kiosk Setup"
echo "  ─────────────────────────────"
echo ""

# ── 1. Sistema ───────────────────────────────
echo "[1/5] Actualizando sistema..."
sudo apt-get update -qq
sudo apt-get install -y -qq chromium-browser unclutter xdotool

# ── 2. Deshabilitar screensaver del sistema ──
echo "[2/5] Deshabilitando screensaver del sistema..."
sudo raspi-config nonint do_blanking 1 2>/dev/null || true

# Deshabilitar DPMS y screen blanking via X11
mkdir -p ~/.config/lxsession/LXDE-pi
XSET_FILE="/etc/X11/xinit/xinitrc.d/90-noscreensaver.sh"
sudo bash -c "cat > $XSET_FILE" << 'XSET'
#!/bin/sh
xset s off
xset s noblank
xset -dpms
XSET
sudo chmod +x $XSET_FILE

# ── 3. Autostart kiosk ───────────────────────
echo "[3/5] Configurando autostart..."
mkdir -p ~/.config/lxsession/LXDE-pi

cat > ~/.config/lxsession/LXDE-pi/autostart << 'AUTOSTART'
@lxpanel --profile LXDE-pi
@pcmanfm --desktop --profile LXDE-pi
@xset s off
@xset s noblank
@xset -dpms
@unclutter -idle 0 -root
@chromium-browser \
  --kiosk \
  --noerrdialogs \
  --disable-infobars \
  --no-first-run \
  --disable-session-crashed-bubble \
  --disable-restore-session-state \
  --disable-translate \
  --disable-features=TranslateUI \
  --check-for-update-interval=604800 \
  https://cabokrunch.com/sistema.html
AUTOSTART

# ── 4. Teclado numérico — mapeo ──────────────
echo "[4/5] Configurando NumLock al inicio..."
# Asegurar que NumLock esté activo al arrancar
sudo apt-get install -y -qq numlockx 2>/dev/null || true

# Agregar numlockx al autostart si está instalado
if command -v numlockx &> /dev/null; then
  echo "@numlockx on" >> ~/.config/lxsession/LXDE-pi/autostart
fi

# ── 5. Ocultar cursor del mouse ──────────────
echo "[5/5] Ocultando cursor..."
# Ya incluido con unclutter arriba

# ── Resumen ──────────────────────────────────
echo ""
echo "  ✓ Configuración completa"
echo ""
echo "  Mapeo del teclado numérico:"
echo "  ┌─────────────────────────────────────┐"
echo "  │  1 → Salchicha de Res    $80        │"
echo "  │  2 → Res + Papa          $85        │"
echo "  │  3 → Mozzarella          $80        │"
echo "  │  4 → Mozz + Papa         $85        │"
echo "  │  5 → Mitad y Mitad       $80        │"
echo "  │  6 → Mitad + Papa        $85        │"
echo "  │  7 → Maracuyá            $30        │"
echo "  │  8 → Naranja             $30        │"
echo "  │  9 → Pepino c/Limón      $30        │"
echo "  │  0 → Jamaica             $30        │"
echo "  │  * → Horchata            $30        │"
echo "  │  / → Tamarindo           $30        │"
echo "  ├─────────────────────────────────────┤"
echo "  │  Enter  → Abrir cobro              │"
echo "  │  1-5    → Billete (en cobro)        │"
echo "  │  +      → Confirmar venta           │"
echo "  │  Bksp   → Quitar último producto    │"
echo "  │  Esc    → Limpiar carrito           │"
echo "  └─────────────────────────────────────┘"
echo ""
echo "  Reinicia el RPi para aplicar cambios:"
echo "  sudo reboot"
echo ""
