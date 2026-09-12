#!/bin/bash
# Instala fish shell, fisher, el prompt tide@v6 y fnm (con su hook para fish),
# y configura fish como shell por defecto. Reproduce la configuración actual
# de este equipo (macOS + Homebrew), con soporte para Linux y WSL.
#
# Uso: ./install-fish-shell.sh

detect_os() {
  if [ -f /proc/version ] && grep -qi microsoft /proc/version 2>/dev/null; then
    echo "WSL"
  else
    uname -s
  fi
}

OS="$(detect_os)"
echo "Sistema operativo detectado: $OS"

install_fish() {
  if command -v fish >/dev/null 2>&1; then
    echo "fish ya está instalado ($(fish --version))."
    return
  fi

  echo "Instalando fish..."
  case "$OS" in
    Darwin)
      if ! command -v brew >/dev/null 2>&1; then
        echo "Homebrew no está instalado. Instálalo desde https://brew.sh y vuelve a ejecutar este script."
        exit 1
      fi
      brew install fish
      ;;
    Linux|WSL)
      if command -v apt-get >/dev/null 2>&1; then
        sudo apt-get update
        sudo apt-get install -y fish
      elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y fish
      elif command -v pacman >/dev/null 2>&1; then
        sudo pacman -Sy --noconfirm fish
      elif command -v zypper >/dev/null 2>&1; then
        sudo zypper install -y fish
      elif command -v apk >/dev/null 2>&1; then
        sudo apk add fish
      else
        echo "No se encontró un gestor de paquetes soportado (apt/dnf/pacman/zypper/apk)."
        exit 1
      fi
      ;;
    MINGW*|MSYS*|CYGWIN*)
      echo "Windows nativo detectado (Git Bash/MSYS)."
      echo "fish no soporta Windows nativo ni chsh en este entorno."
      echo "Instala WSL con 'wsl --install' y ejecuta este script dentro de WSL,"
      echo "o usa Scoop ('scoop install fish') solo para tenerlo disponible dentro de esa terminal."
      exit 1
      ;;
    *)
      echo "Sistema operativo no soportado: $OS"
      exit 1
      ;;
  esac
  echo "fish instalado."
}

install_fisher_and_plugins() {
  if fish -c 'functions -q fisher' 2>/dev/null; then
    echo "fisher ya está instalado."
  else
    echo "Instalando fisher..."
    fish -c 'curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher'
  fi

  if fish -c 'functions -q tide' 2>/dev/null; then
    echo "tide ya está instalado."
  else
    echo "Instalando tide (prompt)..."
    fish -c 'fisher install ilancosman/tide@v6'
  fi
}

install_fnm() {
  if command -v fnm >/dev/null 2>&1; then
    echo "fnm ya está instalado."
  else
    echo "Instalando fnm..."
    if [ "$OS" = "Darwin" ] && command -v brew >/dev/null 2>&1; then
      brew install fnm
    else
      curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell
    fi
  fi

  conf_dir="$HOME/.config/fish/conf.d"
  mkdir -p "$conf_dir"
  fnm_conf="$conf_dir/fnm.fish"

  if [ -f "$fnm_conf" ]; then
    echo "$fnm_conf ya existe, se omite."
    return
  fi

  if [ "$OS" = "Darwin" ] && command -v brew >/dev/null 2>&1; then
    fnm_path="$(brew --prefix fnm 2>/dev/null)/bin"
  else
    fnm_path="$HOME/.local/share/fnm"
  fi

  cat > "$fnm_conf" <<EOF

# fnm
set FNM_PATH "$fnm_path"
if [ -d "\$FNM_PATH" ]
  fnm env --shell fish | source
end
EOF
  echo "$fnm_conf creado."
}

current_login_shell() {
  case "$OS" in
    Darwin)
      dscl . -read "$HOME" UserShell 2>/dev/null | awk '{print $2}'
      ;;
    *)
      getent passwd "$(whoami)" 2>/dev/null | cut -d: -f7
      ;;
  esac
}

set_default_shell() {
  fish_path="$(command -v fish)"

  if ! grep -qx "$fish_path" /etc/shells 2>/dev/null; then
    echo "Añadiendo $fish_path a /etc/shells (requiere sudo)..."
    echo "$fish_path" | sudo tee -a /etc/shells >/dev/null
  fi

  if [ "$(current_login_shell)" = "$fish_path" ]; then
    echo "fish ya es el shell por defecto."
  else
    echo "Configurando fish como shell por defecto (te pedirá tu contraseña)..."
    chsh -s "$fish_path"
    echo "Shell por defecto cambiado a fish. Cierra sesión o abre una nueva terminal para que surta efecto."
  fi
}

install_fish
install_fisher_and_plugins
install_fnm
set_default_shell

echo "Instalación y configuración de fish completadas."
