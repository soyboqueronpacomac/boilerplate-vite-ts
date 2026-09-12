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
echo "Configuración inicial completada."

paquetes=""
for paquete in  astro typescript; do
  if [ -d "node_modules/$paquete" ]; then
    echo "El paquete '$paquete' ya está instalado."
  else
    paquetes="$paquetes $paquete"
  fi
done

if [ -n "$paquetes" ]; then
  pnpm add $paquetes
fi
echo "Instalación de paquetes completada."

if [ -f "astro.config.mjs" ]; then
  echo "astro.config.mjs ya existe."
else
  touch astro.config.mjs
  echo "astro.config.mjs creado."
fi
echo "Configuración de Astro completada."

if [ -f "tsconfig.json" ]; then
  echo "tsconfig.json ya existe."
else
  pnpm exec tsc --init
fi
echo "Configuración de TypeScript completada."

mkdir -p src/pages
mkdir -p src/components
mkdir -p src/layouts
mkdir -p src/styles
mkdir -p public
mkdir -p public/assets
mkdir -p public/images
mkdir -p public/fonts
touch src/pages/index.astro
echo "Estructura de carpetas y archivos inicial creada."

cat > pnpm-workspace.yaml <<EOL
allowBuilds:
  esbuild: true
  sharp: true
minimumReleaseAgeExclude:
  - astro
EOL

pnpm pkg set scripts.dev="astro dev"
pnpm pkg set scripts.build="astro build"
pnpm pkg set scripts.preview="astro preview"
pnpm pkg set scripts.astro="astro"
echo "Scripts añadidos a package.json."
touch astro.config.mjs
cat > astro.config.mjs <<EOL
import { defineConfig } from 'astro/config';

export default defineConfig({
  server: { port: 3000, open: "/", host: true}
});
EOL

touch tsconfig.json
cat > tsconfig.json <<EOL
{
  "extends": "astro/tsconfigs/strict",
  "include": [".astro/type.d.ts", "**/*"],
  "exclude": ["node_modules", "dist"],
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "@/*": ["src/*"]
    }
  }

}
EOL
code .