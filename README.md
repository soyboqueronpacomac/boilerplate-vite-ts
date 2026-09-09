# boilerplate-vite-ts

Scaffolding automatizado para crear proyectos con **Vite + TypeScript**, listos para desarrollo, build, preview y despliegue en GitHub Pages.

## Qué hace `install.sh`

Al ejecutarlo, el script:

1. Pregunta el nombre de la carpeta del proyecto y la crea (si no existe ya).
2. Ejecuta `pnpm init --init-type module` (si no hay `package.json`).
3. Instala como dependencias de desarrollo `vite`, `typescript`, `lightningcss` y `@types/node` (solo las que falten).
4. Genera `tsconfig.json` con `tsc --init` (si no existe).
5. Genera `vite.config.ts` (si no existe `vite.config.ts` ni `vite.config.js`), configurado con:
   - `root: 'src'`
   - `publicDir: '../public'`
   - `build.outDir: '../dist'`
   - `base` dinámico según el nombre de la carpeta (para GitHub Pages en producción)
   - `css.transformer: 'lightningcss'`
6. Instala `gh-pages` como dependencia de desarrollo (si no está instalada).
7. Crea la estructura de carpetas: `src/`, `public/`, `src/assets/`, `src/components/`, `src/styles/`, `src/modules/`.
8. Crea los archivos base: `src/index.html`, `src/styles/global.css`, `src/main.ts`.
9. Añade a `package.json` los scripts:
   - `dev`: `vite`
   - `build`: `vite build`
   - `preview`: `vite preview`
   - `deploy`: `gh-pages -d dist`
10. Abre el proyecto en VS Code (`code .`).

Todos los pasos son **idempotentes**: si algo ya existe (carpeta, `package.json`, dependencias, `tsconfig.json`, `vite.config`), el script lo detecta y lo omite en lugar de sobrescribirlo.

## Uso

```bash
./install.sh
```

Se te pedirá el nombre de la carpeta del nuevo proyecto.

### Requisitos

- [pnpm](https://pnpm.io/) instalado.
- [VS Code](https://code.visualstudio.com/) con el comando `code` disponible en el `PATH` (opcional, solo para el último paso).

## Instalar como comando global

`setup.sh` crea un enlace simbólico de `install.sh` en `/opt/homebrew/bin/create-vite-ts`, para poder ejecutarlo desde cualquier carpeta con:

```bash
./setup.sh
```

Después, desde cualquier ubicación:

```bash
create-vite-ts
```

Como es un symlink, cualquier cambio futuro en `install.sh` se refleja automáticamente en el comando global.
