# Uso:
#   Opción A (autoload permanente): copia este archivo a ~/.config/fish/functions/create-vite-ts.fish
#   Opción B (sesión actual + guardar): source create-vite-ts.fish ; funcsave create-vite-ts
# Luego ejecuta: create-vite-ts

function create-vite-ts --description 'Crea un proyecto base de Vite + TypeScript'
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

    set -l paquetes
    for paquete in vite typescript lightningcss @types/node
        if test -d "node_modules/$paquete"
            echo "$paquete ya está instalado, se omite."
        else
            set -a paquetes $paquete
        end
    end

    if test (count $paquetes) -gt 0
        pnpm add -D $paquetes
    end

    if test -f tsconfig.json
        echo "tsconfig.json ya existe, se omite tsc --init."
    else
        pnpm exec tsc --init
    end

    if test -f vite.config.ts; or test -f vite.config.js
        echo "vite.config ya existe, se omite."
    else
        echo 'import path from \'node:path\'
import { defineConfig } from \'vite\'

const folderName = path.basename(path.resolve(\'.\'))

export default defineConfig(({ mode }) => {
    const prod = mode === \'production\'

    return {
        root: \'src\',
        base: prod ? `/${folderName }/` : \'/\',
        node: prod ? \'production\' : \'development\',
        publicDir: \'../public\',
        plugins: [],
        server: {
            port: 3000,
            open: true
        },
        build: {
            outDir: \'../dist\'
        },
        css: {
           transformer: \'lightningcss\',
        }
    }
})' > vite.config.ts
        echo "vite.config.ts creado."
    end

    set -l paquetes2
    for paquete in gh-pages
        if test -d "node_modules/$paquete"
            echo "$paquete ya está instalado, se omite."
        else
            set -a paquetes2 $paquete
        end
    end

    if test (count $paquetes2) -gt 0
        pnpm add -D $paquetes2
    end

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
end
