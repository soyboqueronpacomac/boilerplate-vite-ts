# Uso:
#   Opción A (autoload permanente): copia este archivo a ~/.config/fish/functions/create-astro.fish
#   Opción B (sesión actual + guardar): source create-astro.fish ; funcsave create-astro
# Luego ejecuta: create-astro

function create-astro --description 'Crea un proyecto base de Astro + TypeScript'
    set -l base_dir "/Volumes/JMicro 1TB/ProyectosAi/Github"

    read -P "Nombre de la carpeta: " nombre

    if not cd $base_dir
        echo "No se pudo acceder a '$base_dir'."
        return 1
    end

    if test -d $nombre
        echo "La carpeta '$nombre' ya existe."
    else
        mkdir -p $nombre
        echo "Carpeta '$nombre' creada."
    end

    if not cd $nombre
        return 1
    end
    echo "Dentro de la carpeta '$nombre'."

    if test -f package.json
        echo "package.json ya existe, se omite pnpm init."
    else
        pnpm init --init-type module
    end
    echo "Configuración inicial completada."

    set -l paquetes
    for paquete in astro typescript
        if test -d "node_modules/$paquete"
            echo "El paquete '$paquete' ya está instalado."
        else
            set -a paquetes $paquete
        end
    end

    if test (count $paquetes) -gt 0
        pnpm add $paquetes
    end
    echo "Instalación de paquetes completada."

    if test -f astro.config.mjs
        echo "astro.config.mjs ya existe."
    else
        touch astro.config.mjs
        echo "astro.config.mjs creado."
    end
    echo "Configuración de Astro completada."

    if test -f tsconfig.json
        echo "tsconfig.json ya existe."
    else
        pnpm exec tsc --init
    end
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

    echo 'allowBuilds:
  esbuild: true
  sharp: true
minimumReleaseAgeExclude:
  - astro' > pnpm-workspace.yaml

    pnpm pkg set scripts.dev="astro dev"
    pnpm pkg set scripts.build="astro build"
    pnpm pkg set scripts.preview="astro preview"
    pnpm pkg set scripts.astro="astro"
    echo "Scripts añadidos a package.json."

    echo 'import { defineConfig } from \'astro/config\';

export default defineConfig({
  server: { port: 3000, open: "/", host: true}
});' > astro.config.mjs

    echo '{
  "extends": "astro/tsconfigs/strict",
  "include": [".astro/type.d.ts", "**/*"],
  "exclude": ["node_modules", "dist"],
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "@/*": ["src/*"]
    }
  }

}' > tsconfig.json

    code .
end
