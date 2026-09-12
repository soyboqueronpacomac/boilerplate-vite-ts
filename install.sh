#!/bin/bash

base_dir="/Volumes/JMicro 1TB/ProyectosAi/Github"

read -p "Nombre de la carpeta: " nombre

cd "$base_dir" || { echo "No se pudo acceder a '$base_dir'."; exit 1; }

if [ -d "$nombre" ]; then
  echo "La carpeta '$nombre' ya existe."
else
  mkdir -p "$nombre"
  echo "Carpeta '$nombre' creada."
fi
cd "$nombre"
echo "Dentro de la carpeta '$nombre'."

if [ -f "package.json" ]; then
  echo "package.json ya existe, se omite pnpm init."
else
  pnpm init --init-type module
fi

paquetes=""
for paquete in vite typescript lightningcss @types/node; do
  if [ -d "node_modules/$paquete" ]; then
    echo "$paquete ya está instalado, se omite."
  else
    paquetes="$paquetes $paquete"
  fi
done

if [ -n "$paquetes" ]; then
  pnpm add -D $paquetes
fi

if [ -f "tsconfig.json" ]; then
  echo "tsconfig.json ya existe, se omite tsc --init."
else
  pnpm exec tsc --init
fi

if [ -f "vite.config.ts" ] || [ -f "vite.config.js" ]; then
  echo "vite.config ya existe, se omite."
else
  cat > vite.config.ts <<'EOF'
import path from 'node:path'
import { defineConfig } from 'vite'

const folderName = path.basename(path.resolve('.'))

export default defineConfig(({ mode }) => {
    const prod = mode === 'production'

    return {
        root: 'src',
        base: prod ? `/${folderName }/` : '/',
        node: prod ? 'production' : 'development', 
        publicDir: '../public',
        plugins: [],
        server: { 
            port: 3000,
            open: true
        },
        build: {
            outDir: '../dist'
        },
        css: {
           transformer: 'lightningcss', 
        }
    }
})
EOF
  echo "vite.config.ts creado."
fi

paquetes=""
for paquete in gh-pages; do
  if [ -d "node_modules/$paquete" ]; then
    echo "$paquete ya está instalado, se omite."
  else
    paquetes="$paquetes $paquete"
  fi
done

if [ -n "$paquetes" ]; then
  pnpm add -D $paquetes
fi

mkdir -p src
echo "Carpeta 'src' creada."
mkdir -p public
echo "Carpeta 'public' creada."

pnpm pkg set scripts.dev="vite"
pnpm pkg set scripts.build="vite build"
pnpm pkg set scripts.preview="vite preview"
pnpm pkg set scripts.deploy="gh-pages -d dist"
echo "Scripts añadidos a package.json."
touch src/index.html
echo "Archivo 'src/index.html' creado."
mkdir -p src/{assets,components,styles,modules}
echo "Subcarpetas 'assets', 'components', 'styles' y 'modules' creadas dentro de 'src'."
touch src/styles/global.css
echo "Archivo 'src/styles/global.css' creado."
touch src/main.ts
echo "Archivo 'src/main.ts' creado."

code .
