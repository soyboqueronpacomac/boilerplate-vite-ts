#!/bin/bash

# Instala install.sh como comando global 'create-vite-ts'

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
origen="$script_dir/install.sh"
destino="/opt/homebrew/bin/create-vite-ts"

chmod +x "$origen"

if [ -e "$destino" ] || [ -L "$destino" ]; then
  echo "'$destino' ya existe, se sobrescribe el enlace."
  rm -f "$destino"
fi

ln -s "$origen" "$destino"
echo "Comando 'create-vite-ts' instalado. Ya puedes ejecutarlo desde cualquier carpeta."
