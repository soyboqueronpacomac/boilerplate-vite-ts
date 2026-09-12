# boilerplate-vite-ts

Scaffolding automatizado para crear proyectos con **Vite + TypeScript** o **Astro**, listos para desarrollo, build, preview y despliegue en GitHub Pages. Incluye también un script para instalar y configurar **fish shell** con el mismo setup que este equipo.

## Scripts incluidos

| Script                 | Qué hace                                                              |
| ----------------------- | ---------------------------------------------------------------------- |
| `install.sh`            | Crea un proyecto Vite + TypeScript desde cero.                        |
| `astro.sh`               | Crea un proyecto Astro + TypeScript desde cero.                       |
| `create-vite-ts.fish`    | Función fish equivalente a `install.sh` (comando `create-vite-ts`).   |
| `create-astro.fish`      | Función fish equivalente a `astro.sh` (comando `create-astro`).       |
| `install-fish-shell.sh`  | Instala fish, fisher, tide y fnm, y lo configura como shell por defecto. |
| `setup.sh`               | Publica `install.sh` como comando global `create-vite-ts` (para bash/zsh). |

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

### Uso

```bash
./install.sh
```

Se te pedirá el nombre de la carpeta del nuevo proyecto.

## Qué hace `astro.sh`

Al ejecutarlo, el script:

1. Pregunta el nombre de la carpeta del proyecto y la crea (si no existe ya).
2. Ejecuta `pnpm init --init-type module` (si no hay `package.json`).
3. Instala `astro` y `typescript` (solo los que falten).
4. Genera `astro.config.mjs` (si no existe), con el servidor de desarrollo en el puerto `3000` y `host: true`.
5. Genera `tsconfig.json` extendiendo `astro/tsconfigs/strict`, con el alias `@/*` apuntando a `src/*`.
6. Crea la estructura de carpetas: `src/pages/`, `src/components/`, `src/layouts/`, `src/styles/`, `public/`, `public/assets/`, `public/images/`, `public/fonts/`.
7. Crea `src/pages/index.astro`.
8. Genera `pnpm-workspace.yaml` con `allowBuilds` (aprueba los build scripts de `esbuild` y `sharp`) y `minimumReleaseAgeExclude` para `astro`.
9. Añade a `package.json` los scripts:
   - `dev`: `astro dev`
   - `build`: `astro build`
   - `preview`: `astro preview`
   - `astro`: `astro`
10. Abre el proyecto en VS Code (`code .`).

Igual que `install.sh`, todos los pasos son **idempotentes**.

### Uso

```bash
./astro.sh
```

## Funciones de fish: `create-vite-ts` y `create-astro`

`create-vite-ts.fish` y `create-astro.fish` son la versión nativa en **fish shell** de `install.sh` y `astro.sh` respectivamente (mismos pasos, misma lógica idempotente, pero con sintaxis de fish en vez de bash).

Ya están instaladas como funciones con autoload en `~/.config/fish/functions/`, así que en cualquier terminal de fish puedes ejecutar directamente:

```fish
create-vite-ts
create-astro
```

Para instalarlas en otro equipo con fish, copia ambos archivos a su `~/.config/fish/functions/`:

```fish
cp create-vite-ts.fish create-astro.fish ~/.config/fish/functions/
```

## `install-fish-shell.sh`: instalar y configurar fish

Instala fish shell y replica la configuración de este equipo en cualquier sistema operativo (macOS, Linux o WSL):

1. Detecta el sistema operativo y usa el gestor de paquetes correspondiente (`brew`, `apt`, `dnf`, `pacman`, `zypper` o `apk`) para instalar **fish**.
2. Instala **fisher** (gestor de plugins de fish).
3. Instala el prompt **tide@v6** vía fisher.
4. Instala **fnm** y crea `~/.config/fish/conf.d/fnm.fish` con el hook para que fish lo cargue automáticamente.
5. Añade fish a `/etc/shells` (si falta) y lo configura como shell por defecto con `chsh`.

Todos los pasos son idempotentes. En Windows nativo (sin WSL) el script avisa que no es compatible y sugiere instalar WSL.

### Uso

```bash
./install-fish-shell.sh
```

## Requisitos

- [pnpm](https://pnpm.io/) instalado.
- [VS Code](https://code.visualstudio.com/) con el comando `code` disponible en el `PATH` (opcional, solo para el último paso de `install.sh`/`astro.sh`).

## Instalar como comando global (bash/zsh)

`setup.sh` crea un enlace simbólico de `install.sh` en `/opt/homebrew/bin/create-vite-ts`, para poder ejecutarlo desde cualquier carpeta con:

```bash
./setup.sh
```

Después, desde cualquier ubicación:

```bash
create-vite-ts
```

Como es un symlink, cualquier cambio futuro en `install.sh` se refleja automáticamente en el comando global.

> Si usas **fish** como shell, no necesitas `setup.sh`: la función `create-vite-ts` (ver sección anterior) ya está disponible como comando global vía autoload, y en fish las funciones tienen prioridad sobre los comandos del `PATH` con el mismo nombre.
