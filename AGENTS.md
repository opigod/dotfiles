# AGENTS.md — complete map of this dotfiles repo

**Read this before searching the repo.** It is intentionally exhaustive: every
tracked file, what it controls, where it is deployed, line anchors for large
files, cross-file invariants, and the traps that waste agent time.

Verified against the live machine on **2026-11-19**. If reality disagrees with
this file, trust the live system and update this document.

---

## 0. What this repo is

- Personal Linux dotfiles for user `opi` at `/home/opi/dotfiles`.
- Target: **CachyOS** (Arch-based rolling), **Wayland**, **Hyprland 0.57.2**,
  **DMS 2.1.2** (Dux Modular Shell, package `dux-shell`), **fish 4.9.3**,
  **Ghostty 1.4.0** (default terminal), **Alacritty 0.17.0**, **AstroNvim v6**,
  **Zed 1.27.0**, **OpenCode 2.3.2**.
- The previous **KineticWE + Noctalia** session is still installed and its
  configs remain tracked as a legacy fallback (see §4.12–4.13). The current
  session is Hyprland + DMS; do not assume KineticWE files are live.
- Git remote: `https://github.com/opigod/dotfiles.git`, branch `main`.
- Config-only repo: **no build system, no tests, no CI.** The only package
  manifest is the private local OpenCode TUI plugin in
  `opencode/plugins/current-session-cost/`; it is loaded directly from TSX and
  has no build step.
- About 44 MB on disk, mostly the binary Bibata cursor theme (28 MB) and the
  ignored DMS plugin cache (`dms/plugins/`, ~5 MB). Never bulk-read or `cat`
  files under `Bibata-Modern-Ice/cursors/`; they are Xcursor binaries.

### Current working-tree state (important)

At the time of writing there are uncommitted changes:

- New config directories symlinked by this session: `hypr/`, `dms/`,
  `alacritty/`, `fish/`, `autostart/`, `xsettingsd/`, `environment.d/`,
  `mimeapps.list`.
- Generated themes already present but untracked: `ghostty/themes/`,
  `zed-stuff/zed/themes/`.
- User changes carried over: `kineticwe/kglobalshortcutsrc` and
  `kineticwe/kineticwe.kwe`; `opencode/opencode.json` (adds
  `disabled_providers: ["unrestricted"]`).
- Updated in this session: `AGENTS.md`, `README.md`, `install.sh`,
  `.gitignore`, `ghostty/config` (comment + `background-blur = true`).

Do not revert, stash, or reformat any of these unless the user explicitly asks.

---

## 1. Rules and conventions for agents

1. **Check `git status` before editing.** Do not discard user work.
2. **Never commit secrets.** Secret-bearing paths on this machine:
   `~/.config/dms/plugin_settings.json` (Wallhaven API key),
   `~/.config/opencode/service.json` (OpenCode service password), and the
   legacy `~/.local/state/noctalia-kwe/settings.toml` (plugin API keys). Never
   copy them into the repo, print them, diff them, or quote secret values. The
   repo's `dms/plugin_settings.json` is gitignored but still carries the live
   Wallhaven key: never stage it, and never paste its contents into chat.
3. **Most directories here are symlinked into live config.** Editing a repo
   file changes the running desktop immediately. There is no deploy step for
   `hypr/`, `dms/`, `alacritty/`, `fish/`, `autostart/`, `xsettingsd/`,
   `ghostty/`, `nvim/`, `zed-stuff/zed/`, `zed-stuff/vesper-blur/`, or the
   OpenCode links in §3.1.
4. **Generated files are overwritten.** DMS/Matugen writes
   `hypr/dms/{colors,input,layout,outputs,windowrules}.lua`,
   `hypr/dms/binds.lua`, `alacritty/dank-theme.toml`,
   `ghostty/themes/dankcolors`, and `zed-stuff/zed/themes/dank-zed-theme.json`.
   Prefer the DMS GUI / `dms` CLI workflow, or warn that the next theme or
   settings change may overwrite hand edits. KineticWE `.kwe` files and
   `kineticwe/decoration.colors` are likewise generated.
5. **Do not run `git clean`.** It would delete the ignored live symlink
   `kineticwe/kdeglobals` and the ignored DMS runtime files.
6. **Do not invent install/build commands.** This repo has none, and the
   OpenCode plugin is loaded from TSX without a build step. Safe checks are in
   §8.
7. **Keep formats:** JSON (DMS settings/lockfile, Ghostty theme), JSONC (Zed
   settings/keymap: comments and trailing commas are valid), TOML (Alacritty,
   Noctalia export, LSFG), KConfig/INI-like (`.kwe`, `kdeglobals`,
   `kglobalshortcutsrc`), Lua (Hyprland, AstroNvim), TSX (OpenCode TUI plugin),
   fish (fish config/functions).
8. **Hyprland Lua style:** match the existing files — tabs for indentation,
   double-quoted strings, one `hl.config`/`hl.bind` call per statement. Do not
   reformat DMS-generated files. **AstroNvim Lua style:** StyLua with 120
   columns, 2 spaces, Unix endings, double quotes, no call parentheses.
9. **Nvim plugin files are opt-in.** Most files under `nvim/lua/plugins/`
   start with `if true then return {} end` and are therefore disabled. Remove
   that guard only when the task requires activating that example.
10. **`install.sh` is idempotent.** Use `./install.sh --dry-run --yes` to see
    what would change; never run it with `--force` without the user's consent,
    because it moves live configs aside.

---

## 2. Complete repository tree

```
/home/opi/dotfiles/
├── AGENTS.md                       # this file (gitignored but tracked)
├── README.md                       # install/deploy docs, DMS/Hyprland notes
├── install.sh                      # idempotent installer (links + copies)
├── .gitignore                      # secrets, DMS runtime state, generated files
├── .githooks/
│   └── pre-commit                 # tracked hook: rejects staged credentials
├── Bibata-Modern-Ice/              # XCursor theme "Bibata-Modern-Ice"
│   ├── index.theme
│   ├── cursor.theme
│   └── cursors/                   # 145 entries (56 files + 89 alias symlinks)
├── hypr/                           # Hyprland + DMS config (live)
│   ├── hyprland.lua                # 91 lines, hand-edited base config
│   ├── dms/
│   │   ├── binds.lua               # 203 lines, generated stock DMS keybinds
│   │   ├── binds-user.lua          # 6 lines, user keybind overrides
│   │   ├── colors.lua              # 42 lines, generated Matugen colors
│   │   ├── cursor.lua              # 1 line, generated placeholder
│   │   ├── input.lua               # 16 lines, generated input settings
│   │   ├── layout.lua              # 34 lines, generated gaps/blur/layer rules
│   │   ├── outputs.lua             # 4 lines, generated monitor config
│   │   └── windowrules.lua         # 8 lines, generated DMS window rules
│   └── .dms-backups/               # ignored DMS backups of replaced configs
├── dms/                            # DMS shell settings (live)
│   ├── settings.json               # 390 lines, GUI-written shell settings
│   ├── plugins.lock.json           # 14 lines, pinned plugin commits
│   ├── plugin_settings.json        # IGNORED, contains Wallhaven API key
│   ├── plugins/                    # IGNORED, downloaded plugin cache + .repos
│   ├── .firstlaunch                # IGNORED runtime marker
│   └── .changelog-2.1              # IGNORED runtime marker
├── alacritty/
│   ├── alacritty.toml              # 87 lines, Nord palette, 100x30
│   └── dank-theme.toml             # 31 lines, generated DMS palette
├── fish/
│   ├── config.fish                 # 23 lines, CachyOS defaults + pyenv/bun/editor
│   ├── fish_plugins                # 1 line, fisher plugin list
│   ├── conf.d/fish_ai.fish         # fisher-managed fish-ai integration
│   ├── functions/                  # 9 fisher-managed fish-ai functions
│   ├── completions/bun.fish        # IGNORED, generated by Bun
│   └── fish_variables              # IGNORED, universal variables
├── environment.d/
│   └── 90-dms.conf                 # 2 lines, TERMINAL=ghostty + Electron hint
├── autostart/
│   ├── kwe-command-1.desktop       # Hidden=true, legacy kwalletd6
│   └── xdm-app.desktop             # Hidden=true, Xtreme Download Manager
├── xsettingsd/
│   └── xsettingsd.conf             # 17 lines, GTK/X cursor/font/theme settings
├── mimeapps.list                   # 46 lines, default applications
├── ghostty/
│   ├── config                      # 34 lines, active Ghostty config
│   ├── config.ghostty              # 0 bytes; live values come from config
│   ├── themes/dankcolors           # 22 lines, generated by DMS Matugen
│   └── shaders/
│       ├── cursor_smear.glsl       # 173 lines, hexagonal cursor trail
│       ├── sonic_boom_cursor.glsl  # 148 lines, ripple on cursor shape change
│       └── cursor_glow.glsl        # 29 lines, purple cursor glow
├── kineticwe/                      # LEGACY KineticWE session
│   ├── kineticwe.kwe               # 142 lines, main compositor settings
│   ├── appearance.kwe              # 5 lines, cursor size/theme + icon theme
│   ├── custom-keybinds.kwe         # 11 lines, custom app/command actions
│   ├── keybinds.kwe                # 12 lines, non-default global chords
│   ├── kglobalaccelrc              # 14 lines, KDE global-accel registry
│   ├── kglobalshortcutsrc          # 360 lines, full KDE shortcut database
│   ├── kinetic-settings.kwe        # 3 lines, selected pointing device
│   ├── rules.kwe                   # 4 lines, window rules (currently none)
│   ├── kineticweoutputconfig.json  # 160 lines, output snapshot (stale)
│   ├── decoration.colors           # 11 lines, generated titlebar palette
│   ├── kdeglobals                  # ABSOLUTE SYMLINK -> ~/.config/kdeglobals
│   └── lsfg-vk/conf.toml           # 25 lines, Lossless Scaling frame-gen
├── nvim/                           # AstroNvim v6 user config
│   ├── init.lua                    # 28 lines, lazy.nvim bootstrap
│   ├── lazy-lock.json              # 48 lines, generated plugin lockfile
│   ├── README.md                   # 34 lines, generic AstroNvim template
│   ├── lua/
│   │   ├── lazy_setup.lua          # 32 lines, AstroNvim + import wiring
│   │   ├── community.lua           # 12 lines, DISABLED AstroCommunity stub
│   │   ├── polish.lua              # 5 lines, DISABLED last-run hook
│   │   └── plugins/
│   │       ├── cheatsheet.lua      # 11 lines, ACTIVE cheatsheet.nvim
│   │       ├── astrocore.lua       # 85 lines, DISABLED template
│   │       ├── astrolsp.lua        # 104 lines, DISABLED template
│   │       ├── astroui.lua         # 39 lines, DISABLED template
│   │       ├── mason.lua           # 28 lines, DISABLED template
│   │       ├── none-ls.lua         # 24 lines, DISABLED template
│   │       ├── treesitter.lua      # 24 lines, DISABLED template
│   │       └── user.lua            # 90 lines, DISABLED examples
│   ├── .luarc.json                 # disables Lua formatting
│   ├── .neoconf.json               # neodev/neoconf lua_ls setup
│   ├── selene.toml                 # Selene std=neovim + rule overrides
│   ├── .stylua.toml                # StyLua formatting rules
│   └── neovim.yml                  # lua51 + vim global for lua-language-server
├── opencode/                       # OpenCode config + local TUI plugin
│   ├── AGENTS.md                   # global instructions, ignored but present
│   ├── cli.json                    # 17 lines, TUI-only plugin list/options
│   ├── opencode.json               # 12 lines, server/TUI plugin list
│   └── plugins/current-session-cost/
│       ├── package.json            # private local plugin manifest
│       ├── README.md               # plugin usage/options
│       └── tui.tsx                 # Context section with /cost ledger spend
├── zed-stuff/
│   ├── zed/                        # symlinked to ~/.config/zed
│   │   ├── settings.json           # 52 lines, JSONC, live Zed settings
│   │   ├── keymap.json             # 13 lines, Ctrl+Alt+O OpenCode thread
│   │   └── themes/dank-zed-theme.json  # 1523 lines, generated DMS theme
│   └── vesper-blur/                # Zed extension, symlinked into extensions dir
│       ├── extension.toml          # 23 lines, extension manifest v0.1.1
│       └── themes/vesper-blur.json # 296 lines, "Vesper Blur" dark theme
└── noctalia-full-config.toml       # 866 lines, legacy Noctalia export
```

`kineticwe/kdeglobals` is intentionally untracked (see `.gitignore`) and is the
only symlink inside the repo. OpenCode uses file and directory symlinks outside
the repo; see §3. All other live deployment uses directory symlinks or copies
described in §3.

---

## 3. Deployment map (repo → live machine)

### 3.1 Current live state

| Repo path | Live path | Kind | Status |
|---|---|---|---|
| `hypr/` | `~/.config/hypr` | directory symlink | active |
| `dms/` | `~/.config/dms` | directory symlink | active |
| `alacritty/` | `~/.config/alacritty` | directory symlink | active |
| `fish/` | `~/.config/fish` | directory symlink | active |
| `autostart/` | `~/.config/autostart` | directory symlink | active |
| `xsettingsd/` | `~/.config/xsettingsd` | directory symlink | active |
| `environment.d/90-dms.conf` | `~/.config/environment.d/90-dms.conf` | file symlink | active |
| `mimeapps.list` | `~/.config/mimeapps.list` | file symlink | active |
| `ghostty/` | `~/.config/ghostty` | directory symlink | active |
| `nvim/` | `~/.config/nvim` | directory symlink | active |
| `zed-stuff/zed/` | `~/.config/zed` | directory symlink | active |
| `zed-stuff/vesper-blur/` | `~/.local/share/zed/extensions/installed/vesper-blur` | directory symlink | active |
| `Bibata-Modern-Ice/` | `/usr/share/icons/Bibata-Modern-Ice` | copy | active |
| `kineticwe/` | `~/.config/kineticwe` | directory symlink | **legacy** |
| `noctalia-full-config.toml` | `~/.config/noctalia-kwe/noctalia-full-config.toml` | copy | **not deployed**; `~/.config/noctalia-kwe/` is empty |
| `kineticwe/kineticweoutputconfig.json` | `~/.config/kineticweoutputconfig.json` | separate copy | stale; use `hyprctl monitors` |
| `kineticwe/lsfg-vk/conf.toml` | `~/.config/lsfg-vk/conf.toml` | separate copy | identical, not symlinked |
| `kineticwe/kdeglobals` | `~/.config/kdeglobals` | absolute symlink, gitignored | active |
| `opencode/cli.json` | `~/.config/opencode/cli.json` | file symlink | active |
| `opencode/opencode.json` | `~/.config/opencode/opencode.json` | file symlink | active |
| `opencode/plugins/current-session-cost/` | `~/opencode-plugins/current-session-cost` | directory symlink | active |
| `opencode/AGENTS.md` | `~/.config/opencode/AGENTS.md` | file symlink | active, gitignored |

`~/.config/opencode/service.json` is **not tracked** and remains a regular
file; it contains a service password (see §7). `dms/plugin_settings.json` and
`dms/plugins/` are deliberately ignored (see §4.3).

Because the main config dirs and OpenCode links are symlinks, **editing the
repo edits the live config**. Conversely, apps that rewrite their configs
rewrite the repo.

The live Noctalia settings (legacy session only) are
`~/.local/state/noctalia-kwe/settings.toml` (override layer), **not** the
repo's `noctalia-full-config.toml` export.

### 3.2 Fresh-machine deployment

Run `./install.sh` from the repo root. It performs the steps below, keeps
existing targets unless `--force` is given, and backs up anything it replaces as
`<path>.bak.<timestamp>`. Interactive runs offer Firefox Nightly (§6);
`--yes` skips that offer. Manual equivalent:

```sh
mkdir -p ~/.config ~/.config/environment.d \
  ~/.local/share/zed/extensions/installed \
  ~/.config/noctalia-kwe ~/.config/lsfg-vk ~/.config/opencode ~/opencode-plugins

ln -sfn "$PWD/hypr" ~/.config/hypr
ln -sfn "$PWD/dms" ~/.config/dms
ln -sfn "$PWD/alacritty" ~/.config/alacritty
ln -sfn "$PWD/fish" ~/.config/fish
ln -sfn "$PWD/autostart" ~/.config/autostart
ln -sfn "$PWD/xsettingsd" ~/.config/xsettingsd
ln -sfn "$PWD/environment.d/90-dms.conf" ~/.config/environment.d/90-dms.conf
ln -sfn "$PWD/mimeapps.list" ~/.config/mimeapps.list
ln -sfn "$PWD/ghostty" ~/.config/ghostty
ln -sfn "$PWD/nvim" ~/.config/nvim
ln -sfn "$PWD/zed-stuff/zed" ~/.config/zed
ln -sfn "$PWD/zed-stuff/vesper-blur" ~/.local/share/zed/extensions/installed/vesper-blur
ln -sfn "$PWD/opencode/cli.json" ~/.config/opencode/cli.json
ln -sfn "$PWD/opencode/opencode.json" ~/.config/opencode/opencode.json
ln -sfn "$PWD/opencode/plugins/current-session-cost" ~/opencode-plugins/current-session-cost

# legacy KineticWE/Noctalia
ln -sfn "$PWD/kineticwe" ~/.config/kineticwe
cp noctalia-full-config.toml ~/.config/noctalia-kwe/
cp kineticwe/lsfg-vk/conf.toml ~/.config/lsfg-vk/conf.toml

sudo cp -r Bibata-Modern-Ice /usr/share/icons/   # -r is required
```

Notes:

- Ensure the parent directories exist before the copy/`ln`; otherwise `ln` may
  create a link named `installed` instead of linking inside the directory.
- `cp -r Bibata-Modern-Ice /usr/share/icons/` writes to a system directory and
  normally needs root (`sudo`).
- On re-deploy, replace an existing symlink instead of nesting inside it
  (`ln -sfn` or remove the old link first). `install.sh` does this and backs up
  real directories rather than deleting them.
- **DMS uses atomic writes** for `settings.json` and `plugin_settings.json`
  (temp file + rename). This is why `~/.config/dms` must be a **directory**
  symlink; file symlinks would be replaced by regular files on the first save.
- The DMS plugin cache (`dms/plugins/`) is not tracked; the lockfile pins
  commits and DMS re-downloads plugins.
- `dms/plugin_settings.json` is machine-local and contains the Wallhaven API
  key. Never copy it into the repo; on a fresh install DMS creates it.
- Noctalia merges **every `*.toml` in `~/.config/noctalia-kwe/` alphabetically**,
  then applies `~/.local/state/noctalia-kwe/settings.toml` as an override. A
  copied full-config export therefore works as a base layer, but GUI changes
  stored in the state override can mask values from it. `install.sh` skips the
  copy when the state file already exists unless `--force` is given.
- The LSFG config is copied, not linked, to `~/.config/lsfg-vk/conf.toml`.
- OpenCode's `service.json` is machine-local and contains a password. It is
  deliberately absent from the repo; do not overwrite it when deploying.
- The `cli.json` entry for `current-session-cost` uses the live path
  `/home/opi/opencode-plugins/current-session-cost`; the `~/opencode-plugins`
  symlink must exist for the plugin to load.
- OpenCode fetches the npm plugins named in `cli.json`/`opencode.json` itself;
  only `current-session-cost` is vendored here.
- `opencode/AGENTS.md` is gitignored but linked to
  `~/.config/opencode/AGENTS.md` when present; a fresh clone will not contain
  it.

---

## 4. File-by-file reference

### 4.1 Root files

- **`README.md`** — install/deploy instructions, the repo→live map, DMS notes,
  the Hyprland config split, and the legacy KineticWE section.
- **`install.sh`** — idempotent installer. Links the new Hyprland/DMS, terminal,
  fish, autostart, xsettingsd, environment and MIME paths, plus the older
  Ghostty/Nvim/Zed/OpenCode/KineticWE links; copies the Noctalia/LSFG files and
  cursor theme; backs up replaced targets; skips the Noctalia base config when
  live state exists (unless `--force`), and never touches `service.json`,
  `dms/plugin_settings.json`, or the Noctalia state file. It also offers Firefox
  Nightly during an interactive run: Mozilla's tarball goes into
  `/opt/firefox-nightly`, the tree is chowned to the user so the built-in
  updater can write, the `/usr/share/applications/firefox-nightly.desktop`
  launcher is written, and `/usr/local/bin/firefox-nightly` points at it; an
  existing tree is maintained without asking, and a dangling link is repaired.
  `--yes` skips the offer. Flags: `--dry-run`, `--yes`, `--force`,
  `--skip-cursor`, `--skip-opencode`.
- **`.gitignore`** — ignores `AGENTS.md`, `opencode/AGENTS.md`,
  `kineticwe/kdeglobals`, the DMS secret/runtime files
  (`dms/plugin_settings.json`, `dms/plugins/`, `dms/.firstlaunch`,
  `dms/.changelog-2.1`), `hypr/.dms-backups/`, `fish/fish_variables`, and the
  generated `fish/completions/bun.fish`.
- **`noctalia-full-config.toml`** — 866-line legacy export of Noctalia settings
  (an old snapshot; no `config_version` field). Machine-readable section index
  in §4.13. Contains no API keys.
- **`AGENTS.md`** — this document.

### 4.2 `hypr/` — Hyprland + DMS

Hyprland loads `hyprland.lua` first, then requires the generated modules at the
bottom. Later files win, so values in `hypr/dms/*.lua` override the base config.

`hyprland.lua` (91 lines, hand-edited):

- `hl.on("hyprland.start", ...)` updates the systemd/dbus environment and starts
  `hyprland-session.target` unless `HYPRLAND_NO_SD_TARGET` is set.
- Base input: empty `kb_layout` (inherits `XKB_DEFAULT_LAYOUT`, falls back to
  `us`), `numlock_by_default = true`, `follow_mouse = 0`, touchpad tap and
  natural scroll.
- Base general: `gaps_in = 5`, `gaps_out = 5`, `border_size = 2`, dwindle.
- Decoration: `rounding = 12`, full opacity, shadow range 30.
- Misc: no Hyprland logo/splash.
- Animations for windows/workspaces/fade/border.
- Window/layer rules for WezTerm, GNOME apps, calculators, blueman, portals,
  Steam toasts, Firefox PiP, Zoom, and no-animation rules for `quickshell` and
  `dms:*`.
- Ends with `require("dms.colors")`, `outputs`, `layout`, `cursor`, `input`,
  `binds`, `binds-user`, `windowrules`.

`hypr/dms/binds.lua` (203 lines, **generated stock**): DMS keybinds, including
`SUPER+T`/`SUPER+Return` → Ghostty, `SUPER+Space` → spotlight, `SUPER+V` →
clipboard, `SUPER+M` → media dash, `SUPER+comma` → settings, `SUPER+Tab`/`O` →
overview, `SUPER+X` → power menu, `SUPER+A` → control center, `SUPER+Q` close,
`SUPER+F` maximize, `SUPER+Shift+F` fullscreen, `SUPER+Shift+T` float,
`SUPER+W` group, arrow/HJKL focus, `SUPER+[1-9]` workspaces, `SUPER+U/I`
workspace cycling, `SUPER+S` scratchpad, media/brightness keys via `dms ipc`,
`Print`/`CTRL+Print`/`ALT+Print` → `dms screenshot`, `SUPER+P` output profiles,
`SUPER+ALT+L` lock. DMS setup replaces this file; put personal changes in
`binds-user.lua`.

`hypr/dms/binds-user.lua` (6 lines): unbinds `SUPER+SHIFT+Tab` and binds it to
`dms ipc call wallhavenCarousel toggle`. DMS never overwrites this file.

`hypr/dms/colors.lua` (42 lines, generated by DMS Matugen): active border
`rgb(c2c8c5)`, inactive `rgb(8d928f)`, group/groupbar colors, and optional glow/
blur effect colors guarded by `hl.get_config`.

`hypr/dms/input.lua` (16 lines, generated): `follow_mouse = 1`, flat accel,
`swallow_focus_click = true`, touchpad natural scroll/tap, `kb_layout = "us,cz"`,
`kb_options = "grp:alt_shift_toggle"`, `numlock_by_default = false`.

`hypr/dms/layout.lua` (34 lines, generated): gaps 4, border 2,
`resize_on_border = false`, rounding 16, blur passes 2, groupbar blur, and
no-animation/xray layer rules for the DMS bar/island.

`hypr/dms/outputs.lua` (4 lines, generated): `DP-1` at `2560x1440@240.002`,
position `0x0`, scale 1, VRR on, 10-bit, `cm = "edid"`, `sdr_eotf = "auto"`;
fallback `preferred`/`auto` for other outputs.

`hypr/dms/windowrules.lua` (8 lines, generated): DMS floating and opaque rules.

`hypr/.dms-backups/` (ignored): DMS's copies of replaced configs. The current
backup is `2026-11-17_21-40-29/hyprland.lua`, 12.8 KB.

### 4.3 `dms/` — Dux Modular Shell settings

`dms/settings.json` (390 lines, `configVersion = 42`, GUI-written with atomic
writes): the live DMS shell configuration. Highlights:

- `interfaceStyle = "expressive"`, blur enabled (`hyprlandBlurVariant =
  "kawase"`), no glow/wobble/motion blur, window opacity 100, groupbar blur.
- `focusFollowsMouse = 1`, `swallowFocusClick`, `keyboardLayouts = "us,cz"`,
  `keyboardOptions = "grp:alt_shift_toggle"`.
- Cursor: `Bibata-Modern-Ice`, size 16.
- Main Bar enabled (top), Dot bar disabled, Dock disabled.
- Main bar: left `launcherButton`, `workspaceSwitcher`, focused window; center
  island (clock + media lyrics), KDE Connect (currently disabled in plugin
  settings); right memory/CPU/GPU temps, tray, network speed, clipboard,
  keyboard layout, notifications, battery, control center.
- Theme: `currentThemeName = "dynamic"`, `matugenSpec = "2021"`,
  `matugenScheme = "scheme-content"`, `matugenSourceMode = "darkness"`.
- Terminal palette `medium`, `terminalsAlwaysDark = true`, browser picker grid.
- `builtInPluginSettings` trigger aliases (`qrg`, `pw`, `cb`, `?`).

`dms/plugins.lock.json` (14 lines): pins `dankKDEConnect`
(`duxlabs-dev/dux-plugins`, commit `7a964dad…`) and `wallhavenCarousel`
(`alicercedigital/wallhaven-carousel`, commit `ada62d38…`).

Ignored under `dms/`:

- `plugin_settings.json` — plugin toggles/tags plus the **Wallhaven API key**;
  never print, stage, or commit it.
- `plugins/` — downloaded plugin code (wallhavenCarousel ~1.2 MB) and
  `plugins/.repos` git caches (~4 MB); re-downloadable from the lockfile.
- `.firstlaunch`, `.changelog-2.1` — runtime markers.

DMS runtime state lives outside the repo in `~/.local/state/dms/` (`session.json`,
`appusage.json`, wallhaven cache, `pam/`, `wellbeing/`); it is not tracked.

### 4.4 `alacritty/`

`alacritty.toml` (87 lines): 100×30, `dynamic_padding`, opacity 0.8, 10 000
lines of scrollback, `monospace` 12 pt, Nord palette, underline non-blinking
cursor, Vi/search bindings, middle-click paste, Ctrl+Shift copy/paste.
`dank-theme.toml` (31 lines): dark palette generated by DMS Matugen. The current
`alacritty.toml` does not import it (DMS's embedded config would); use
`general.import = ["~/.config/alacritty/dank-theme.toml"]` if you want the
generated palette.

### 4.5 `fish/`

- `config.fish` (23 lines): sources CachyOS's fish config, initializes zoxide,
  sets `SUDO_EDITOR`/`VISUAL`/`EDITOR` to nvim, adds Bun to `PATH`, initializes
  pyenv and pyenv-virtualenv.
- `fish_plugins` (1 line): `realiserad/fish-ai`.
- `conf.d/fish_ai.fish` and `functions/*.fish`: fisher-managed fish-ai
  integration; fisher may rewrite these on update.
- `completions/bun.fish`: generated by Bun, ignored.
- `fish_variables`: universal variables, ignored (local machine state).

### 4.6 Environment, autostart, X settings, MIME defaults

- `environment.d/90-dms.conf` (2 lines): `ELECTRON_OZONE_PLATFORM_HINT=auto`,
  `TERMINAL=ghostty`. DMS rewrites it with `os.WriteFile` (truncate, follows
  symlinks), so the file symlink is safe. `~/.config/environment.d/cursor.conf`
  is a root-owned KineticWE leftover and is not tracked.
- `autostart/*.desktop`: both entries are `Hidden=true` (kwalletd6 and Xtreme
  Download Manager), so they do not launch.
- `xsettingsd/xsettingsd.conf` (17 lines): GTK theme `Breeze-Dark`, icon theme
  `Breeze-Round-Chameleon Dark Icons`, cursor `Bibata-Modern-Ice` size 16, font
  `JetBrainsMono Nerd Font 10`, DPI 98304, decoration layout
  `icon:minimize,maximize,close`.
- `mimeapps.list` (46 lines): defaults include Zen for web/HTML, Dolphin for
  directories, Gwenview for images, mpv for video, Zed for `text/plain`, Ark
  for archives, and OpenCode/OpenChamber URL schemes. **`xdg-mime` saves with
  temp file + rename**, so a default-change can replace the symlink with a
  regular file; check `test -L ~/.config/mimeapps.list` afterwards and re-link
  if needed.

### 4.7 `ghostty/`

`ghostty/config` (34 lines) is the file currently applied; this was verified
with `ghostty +show-config`, which prints exactly these palette/background/
font values. Key values:

| Lines | Setting | Value |
|---|---|---|
| 1–16 | 16-color palette | 0 `#110f18`, 1 `#ff6767`, 2 `#61ffca`, 3 `#ffca85`, 4 `#a277ff`, 5 `#a277ff`, 6 `#61ffca`, 7 `#edecee`, 8 `#4d4d4d`, 9 `#ffca85`, 10 `#a277ff`, 11 `#ffca85`, 12 `#a277ff`, 13 `#a277ff`, 14 `#61ffca`, 15 `#edecee` |
| 17 | background | `#15141b` |
| 20 | background opacity | `0.8` — deliberately transparent so Hyprland/DMS blur shows through |
| 21 | `background-blur` | `true` |
| 24 | `background-opacity-cells` | `true` — keeps TUI cells translucent |
| 25–29 | foreground/cursor/selection | fg `#edecee`, cursor `#a277ff`, selection bg `#a277ff`, selection fg `#edecee` |
| 30–32 | custom shaders | `shaders/cursor_smear.glsl`, `shaders/sonic_boom_cursor.glsl`, `shaders/cursor_glow.glsl` |
| 33 | shader animation | `always` |
| 34 | font | `JetBrainsMono Nerd Font` |

`ghostty/themes/dankcolors` (22 lines) is written by DMS Matugen. The current
config does not set `theme = dankcolors`; add it if you want the generated
palette to replace the hard-coded one.

`ghostty/config.ghostty` is **0 bytes**. Ghostty 1.4 documents
`config.ghostty` as its default path, but the running setup gets its values
from `config` (verified via `ghostty +show-config`). Keep settings in `config`;
do not guess which name wins without re-checking `+show-config`.

Shaders:

- `cursor_smear.glsl` — hexagonal cursor trail; constructs a hexagon from
  current + previous cursor positions, SDF antialiasing, eased trailing corner.
- `sonic_boom_cursor.glsl` — ripple on cursor width change; 0.15 s, max radius
  0.06, 3 px blur, configurable `COLOR`.
- `cursor_glow.glsl` — steady purple glow around the cursor; radius 4 px,
  intensity 0.8, pulse disabled.

Validation: `ghostty +validate-config --config-file=ghostty/config` (returns 0).

### 4.8 `nvim/` — AstroNvim v6

Bootstrap chain: `init.lua` → ensure `lazy.nvim` in
`stdpath("data")/lazy/lazy.nvim` (or `$LAZY`) → `require "lazy_setup"` →
`require "polish"` → set `clipboard=unnamedplus`.

`lua/lazy_setup.lua`:

- Imports `AstroNvim/AstroNvim` version `^6`, with `mapleader = " "` and
  `maplocalleader = ","` set before Lazy.
- Imports `community` then `plugins`.
- Disabled runtime plugins: `gzip`, `netrwPlugin`, `tarPlugin`, `tohtml`,
  `zipPlugin`.
- Install colorschemes `astrotheme`, `habamax`; backdrop 100; update
  notifications on.

`lua/community.lua` and `lua/polish.lua` are disabled stubs
(`if true then return {} end` / `if true then return end`). Activating them
enables AstroCommunity (`pack.lua`) and last-run polish logic respectively.

Plugin files:

| File | State | Purpose / contents |
|---|---|---|
| `plugins/cheatsheet.lua` | **active** | `sudormrfbin/cheatsheet.nvim` + telescope, popup.nvim, plenary. Loads on demand. |
| `plugins/astrocore.lua` | disabled | Template for options, mappings, diagnostics, filetypes, buffer navigation. |
| `plugins/astrolsp.lua` | disabled | LSP features, format-on-save, handlers, codelens autocmds, LSP mappings. |
| `plugins/astroui.lua` | disabled | `astrodark` colorscheme, highlight overrides, LSP spinner icons. |
| `plugins/mason.lua` | disabled | mason-tool-installer: lua-language-server, stylua, debugpy, tree-sitter-cli. |
| `plugins/none-ls.lua` | disabled | Template for null-ls sources (stylua/prettier commented out). |
| `plugins/treesitter.lua` | disabled | AstroCore treesitter highlight/indent/auto-install, ensure lua+vim. |
| `plugins/user.lua` | disabled | Examples: presence.nvim, lsp_signature, dashboard header, luasnip, autopairs. |

`lazy-lock.json` is generated by Lazy (`:Lazy`); do not hand-edit it. It pins
AstroNvim and all plugins.

Tooling rules:

- `.stylua.toml`: 120 columns, Unix endings, 2-space indent,
  `AutoPreferDouble`, no call parentheses, collapse simple statements.
- `.luarc.json`: `format.enable = false` (StyLua owns formatting).
- `selene.toml`: `std = "neovim"`; allows `global_usage`, `if_same_then_else`,
  `incorrect_standard_library_use`, `mixed_table`, `multiple_statements`.
- `neovim.yml`: lua51 base plus `vim` global.
- `.neoconf.json`: neodev library/plugins + lua_ls format disabled.
- `README.md`: generic AstroNvim installation text, not repo-specific.

### 4.9 `zed-stuff/`

#### `zed/settings.json` (52 lines, JSONC)

- `colorize_brackets: true`, title bar sign-in hidden, cursor animation on.
- Icon theme `Monospace Icon Theme - Dark`, base keymap `Zed`.
- OpenCode ACP agent (`agent_servers.opencode`, type `registry`):
  `default_mode = "build"`, default model `deepseek/deepseek-flash`, effort
  `none`.
- Telemetry: diagnostics, metrics, anthropic retention all false.
- `ui_font_size: 16`, `buffer_font_size: 15`.
- Theme: dark `Vesper Blur`, light `Ayu Light`; override sets cursor and
  background `#a277ffff`.
- The trailing comma after `"dark": "Vesper Blur",` is valid JSONC — do not
  "fix" it with strict JSON tooling.

#### `zed/keymap.json` (13 lines, JSONC)

`Ctrl+Alt+O` in Workspace context calls `agent::NewExternalAgentThread` with
`agent: "opencode"` (starts an OpenCode thread in the current project).

#### `zed/themes/dank-zed-theme.json` (1523 lines, generated)

Written by DMS Matugen; theme name `Dynamic Base16 DankShell` by `Adarsh219`.
The live Zed setting still selects `Vesper Blur`; switch the theme in Zed or
`settings.json` to use it.

#### `vesper-blur/extension.toml` (23 lines)

Zed extension manifest: id `vesper-blur`, name `Vesper Blur`, version `0.1.1`,
schema 1, repository `https://github.com/taras-tereschenko/vesper-blur`,
theme file `themes/vesper-blur.json`.

#### `vesper-blur/themes/vesper-blur.json` (296 lines)

Zed theme schema v0.2.0, name `Vesper Blur`, appearance `dark`,
`background.appearance: "blurred"`. Core palette:

- Background/surface `#101010b8`, elevated surface `#161616`.
- Element background `#1C1C1C`, hover/active `#282828`, selected `#232323`.
- Text `#FFFFFF`, muted `#A0A0A0`, accent `#FFC799`, strings `#99FFE4`.
- Borders mostly transparent; focused/selected border `#FFC799`.
- Syntax/status colors continue after line ~100; use key names to locate.

### 4.10 `Bibata-Modern-Ice/`

XCursor theme, deployed to `/usr/share/icons/Bibata-Modern-Ice`.

- `index.theme` — name `Bibata-Modern-Ice`, comment
  `White and rounded edge Bibata (v2.0.6). XCursors`, inherits `hicolor`.
- `cursor.theme` — fallback metadata.
- `cursors/` — 56 regular Xcursor files plus 89 hash-named symlink aliases to
  the named cursors. Binary; do not edit by hand or read in bulk.

Chosen by DMS (`dms/settings.json`), GTK/X (`xsettingsd/xsettingsd.conf`), KDE
(`kdeglobals [KDE]`), and the legacy KineticWE config, at size 16.

### 4.11 `opencode/` — OpenCode config + local TUI plugin

`opencode/cli.json` (17 lines) is the TUI-only plugin list, symlinked to
`~/.config/opencode/cli.json`. It enables:

- `opencode-git-plugin` — sidebar Git changes/diffs.
- `opencode-plugin-usage` — provider balance/usage (DeepSeek credit).
- `@streetturtle/opencode-context-progress` — context progress bar.
- `@streetturtle/opencode-session-tokens` — session token/cost totals.
- `@streetturtle/opencode-recap` — sidebar session recap.
- `current-session-cost` — local plugin at
  `/home/opi/opencode-plugins/current-session-cost`, options
  `{"intervalMs": 1500}`.
- `-opencode.sidebar.context` — disables the built-in Context section so the
  local plugin can render it.

`opencode/opencode.json` (12 lines) is the server/TUI plugin list, symlinked to
`~/.config/opencode/opencode.json`. It enables:

- `opencode-session-items`
- `opencode-skills-tui`
- `@lidtop/opencode-cost` — provides the `/cost` ledger.
- `opencode-plugin-deepseek-peak`

It also sets `disabled_providers: ["unrestricted"]` (user change).

`opencode/plugins/current-session-cost/` is a private local TUI plugin:

- `tui.tsx` (168 lines) — replaces the built-in Context sidebar section. It
  reads the `/cost` ledger at
  `~/.local/state/opencode/opencode-cost/cost.sqlite` read-only, sums the
  current session plus its subagent family (or just the child session when
  `parentID` is set), refreshes every 1.5 s, and falls back to
  `data.session.cost(sessionID)` when the ledger is missing or empty.
- `package.json` (15 lines) — exports `./tui`; no build step.
- `README.md` (60 lines) — plugin behavior and options (`intervalMs`,
  `database`).

`~/.config/opencode/service.json` is **not** in the repo. It contains a service
password and stays machine-local. `cli.json.bak` is also untracked.

### 4.12 `kineticwe/` — legacy KineticWE session

Still installed (`kineticwe 2:0.2.0-1.202611101712`, `kineticwe-noctalia`,
`kineticwe-greeter`, `kineticwe-keyring`), and `kineticwe.desktop` remains in
`/usr/share/wayland-sessions/`. It is not the current session.

`kineticwe.kwe` (142 lines) — main compositor settings:

| Line | Section | Contents |
|---|---|---|
| 1 | `[Desktops]` | 5 desktops, `Number=5`, `Rows=5`; UUIDs below; `Name_2..Name_5 = Workspace 2..5` |
| 14 | `[Effect-blur]` | `ForceBlurAll=true` |
| 17 | `[Layout]` | keyboard layouts `us,cz`, display names `English (US),Czech` |
| 23, 26, 29 | `[Libinput]…` | pointer acceleration for two Logitech PRO 2 Mouse IDs; Keychron K8 HE Mouse |
| 32 | `[Mouse]` | `cursorSize=16`, `cursorTheme=Bibata-Modern-Ice` |
| 36 | `[Plugins]` | `hidecursorEnabled=true`, `wobblywindowsEnabled=true` |
| 40 | `[Tiling]` | `DefaultLayout=AutoGrid`, `GapBetween=15`, `TilingBorderMode=AllWindows`, `TilingCornerRadius=10` |
| 46–124 | `[Tiling][desktopUUID][outputUUID]` | per-workspace/output floating state, `padding=4`, `tiles={…}` JSON |
| 126 | `[Windows]` | focus follows mouse, invert scroll desktop switch, opacity 100, delay 100 |
| 135 | `[Xwayland]` | `Scale=1` |
| 138 | `[org.kde.kdecoration2]` | Breeze decoration, title font `JetBrainsMono Nerd Font` |

Desktop UUIDs (active):

| Desktop | UUID | Name |
|---|---|---|
| 1 | `cf87f1bb-2f83-4499-9f81-9b11c2c0a744` | default (unnamed) |
| 2 | `45393b2d-0bc3-4c93-984d-a698c75778c6` | Workspace 2 |
| 3 | `cd409e22-41a2-410c-bca3-9d5168c6d3b8` | Workspace 3 |
| 4 | `06e08283-dfd3-4f2d-82e8-ea7adea08635` | Workspace 4 |
| 5 | `2cc34ceb-6a50-41b0-8ee9-2bfbd6b72a67` | Workspace 5 |

The tiling section also contains stale blocks for UUIDs
`1999f8fa-a6ca-4970-9799-135705654552`, `6f765c7a-14bd-4650-a493-6bdae3f439bf`,
`c9f56509-4a91-4650-b57e-4f811aab7bd7`, `d51b32c5-01b2-4d5f-96f3-737d061c769a`,
and `dbba8f33-f532-4528-b393-6dbf7624ec8e` — old sessions/outputs.

`appearance.kwe` (5 lines): `CursorSize=16`, `CursorTheme=Bibata-Modern-Ice`,
`IconTheme=Adwaita`.

`custom-keybinds.kwe` (11 lines): `applications.firefox-nightly` →
`/opt/firefox-nightly/firefox`; `custom-commands.cmd-1` → `ghostty`.

`keybinds.kwe` (12 lines): Window Resize `Meta+Z`; Firefox nightly `Meta+W`;
Ghostty `Meta+T`; Spectacle rectangular region `Meta+Shift+S`.

`kglobalaccelrc` (14 lines): KDE global-accelerator registry; Spectacle
shortcuts blanked; migration marker `SpectacleRecordingUnbound=kineticwe-2.1`.

`kglobalshortcutsrc` (360 lines): full KDE-format shortcut database. Section
index:

```
1   [ActivityManager]                 239 [kmix]
5   [KineticWE Keyboard Layout Switcher] 251 [ksmserver]
12  [applications]                   262 [media-ui]
16  [audio]                          280 [mediacontrol]
25  [brightness]                     295 [noctalia]
33  [com.onepassword.OnePassword]    320 [services][com.mitchellh.ghostty.desktop]
38  [custom-commands]                323 [services][org.kde.dolphin.desktop]
42  [kineticwe]                      326 [services][org.kde.kcalc.desktop]
                                     329 [services][org.kde.krunner.desktop]
                                     333 [services][org.kde.kscreen.desktop]
                                     336 [services][org.kde.plasma-systemmonitor.desktop]
                                     339 [services][org.kde.spectacle.desktop]
                                     349 [unisic]
```

Important non-default bindings: `Meta+Space` launcher (61), `Meta+O` overview
(62), `Meta+Q` close (153), `Meta+V` float (137), `Meta+Z` resize (192),
`Meta+PgUp/PgDown` maximize/minimize (162/165), `Meta+Ctrl+Esc` kill (53),
`Meta+Shift+Space` master (129), `Meta+Arrow` focus (121–124),
`Meta+Ctrl+Arrow` desktop (69–72), `Meta+Shift+Arrow` swap (65–68),
`Meta+Ctrl+Shift+Arrow` move across desktops (170–173), `Meta+Ctrl+Shift+Left/
Right` move output (125/128), `Meta+1…9` desktops (77, 88, 95–101), `Meta+W`
Firefox (14), `Meta+T` Ghostty (40), `Meta+Shift+S` region shot (345/352),
`Meta+Alt+R` restart Noctalia (302), `Meta+L` lock (253/303), `Meta+Alt+K/L`
layout next/last (8/9), `Meta+Shift+Esc` disable input capture (234), `Meta+0`
zoom (235).

`kinetic-settings.kwe` (3 lines): `[PointingDevices] Mouse=event8`.
`rules.kwe` (4 lines): `count=0`, `rules=` — no window rules.

`kineticweoutputconfig.json` (160 lines): stale output snapshot (DP-1
2560×1440 CVT @240, HDR true, VRR Always, UUID `ce490dda…`, plus a stale virtual
output). The separate live `~/.config/kineticweoutputconfig.json` is also stale
(HDR false, VRR Never, old UUID). Neither is authoritative: under KineticWE use
`kscreen-doctor -o`; under Hyprland use `hyprctl monitors`.

`decoration.colors` (11 lines): generated titlebar palette (dark frame
`#131313`, titlebar `#1f1f1f`, foreground `#e2e2e2`, outline `#474747`).
Noctalia's KineticWE template writes it.

`kdeglobals` — live symlink, untracked: points to `/home/opi/.config/kdeglobals`
(4826 bytes). Contains the active KDE color scheme (`ColorScheme=noctalia`,
accent `137,103,179`), fonts `JetBrainsMono Nerd Font 10`, cursor
`Bibata-Modern-Ice` size 16, icon theme `Breeze-Round-Chameleon Dark Icons`,
animation factor 0.25, and the terminal command `/usr/bin/ghostty
--gtk-single-instance=true`. Never commit it.

`lsfg-vk/conf.toml` (25 lines): Lossless Scaling frame generation,
`version = 2`; global `allow_fp16 = true`, `log_level = "info"`; profiles for
vkcube/vkcubepp (4× FG) and `GenshinImpact.exe` (2× FG).

### 4.13 `noctalia-full-config.toml` (866 lines) — legacy Noctalia export

Line anchors; use these instead of grepping:

```
1   [accessibility]
5   [audio]
15  [backdrop]
20  [bar]
89  [battery]
95  [bluetooth]
99  [brightness]
105 [calendar]
119 [control_center]
157 [desktop_widgets]
166 [dock]
206 [hooks]
226 [hot_corners]
246 [idle]
274 [keybinds]
287 [location]
294 [lockscreen]
309 [lockscreen_widgets]
375 [nightlight]
381 [notification]
402 [osd]
437 [plugin_settings."coder/deepseek_usage"]
440 [plugins]
462 [shell]
679 [storage]
683 [system.monitor]
720 [theme]
737 [wallpaper]
757 [weather]
763 [widget.active_window]
770 [widget.bar]
773 [widget.battery]
777 [widget.cpu]
781 [widget.date]
785 [widget.divider]
791 [widget.divider_2]
797 [widget.indicator]
800 [widget.input_volume]
804 [widget.keyboard_layout]
808 [widget.lock_keys]
816 [widget.media]
823 [widget.network_rx]
827 [widget.network_tx]
831 [widget.output_volume]
835 [widget.peak]
838 [widget.ram]
842 [widget.spacer]
846 [widget.temp]
850 [widget.tray]
854 [widget.volume]
858 [widget.wallhaven]
861 [widget.workspaces]
```

Key values in the repo snapshot: bar top, 34 px, radius 12, margins 600,
`start=[active_window]`, `end=[privacy, clock]`; dock bottom auto-hide;
lock screen enabled with fingerprint; idle lock 600 s; plugins official +
community; theme source `wallpaper`, builtin `Rosé Pine`, community palette
`Rose Pine Alt`, wallpaper scheme `m3-rainbow`; wallpaper automation off;
weather metric. The **live** Noctalia state (legacy session) enables extra
plugins, a different bar, wallpaper `~/Pictures/wallhaven-kwlk51.jpg`,
`config_version = 16`, and contains API keys — never copy it into the repo.

---

## 5. Cross-file invariants and linked settings

- **Blur/transparency stack:** Hyprland blur (DMS `blurEnabled` +
  `hypr/dms/layout.lua` blur passes 2) + Ghostty `background-opacity=0.8` /
  `background-blur=true` / `background-opacity-cells=true` + Zed `Vesper Blur`
  `background.appearance=blurred` + DMS popup/bar transparency. Changing one
  layer affects the look of the others. KineticWE's old `ForceBlurAll=true`
  only matters in the legacy session.
- **Font:** `JetBrainsMono Nerd Font` is used by Ghostty, Zed, xsettingsd, KDE
  (`kdeglobals`), KineticWE titlebars, and the legacy Noctalia bar. DMS does
  not pin a font in `settings.json`; it follows the Matugen/theme defaults.
- **Cursor:** `Bibata-Modern-Ice` at size 16 is set in `dms/settings.json`
  (`cursorSettings`), `xsettingsd/xsettingsd.conf`, `kdeglobals [KDE]`, and the
  legacy KineticWE `appearance.kwe`/`kineticwe.kwe [Mouse]`.
- **Keyboard layouts:** US/Czech with `grp:alt_shift_toggle` in
  `hypr/dms/input.lua` and `dms/settings.json` (`keyboardLayouts`,
  `keyboardOptions`); the legacy KineticWE layout uses `Meta+Alt+K/L`.
- **Displays:** current runtime is one output, `DP-1`, 2560×1440@240, scale 1,
  10-bit, VRR on, position `0x0`, UUID-independent in Hyprland. The DMS bar
  reserves 42 px at the top. `hypr/dms/outputs.lua` is generated; query
  `hyprctl monitors` as the truth.
- **Theme generation:** DMS Matugen writes `hypr/dms/colors.lua`,
  `alacritty/dank-theme.toml`, `ghostty/themes/dankcolors`,
  `zed-stuff/zed/themes/dank-zed-theme.json`, and GTK `dank-colors.css` files.
  The old Noctalia outputs (`~/.config/gtk-*/noctalia.css`,
  `~/.local/share/color-schemes/noctalia.colors`, Qt `noctalia.conf`) remain
  from the legacy session and may be stale.
- **Terminal:** DMS writes `TERMINAL=ghostty` in
  `environment.d/90-dms.conf`; `SUPER+T`/`SUPER+Return` launch Ghostty.
  Alacritty is installed as an alternative and has its own config.
- **OpenCode plugin wiring:** `opencode/cli.json` and `opencode/opencode.json`
  are symlinked into `~/.config/opencode/`; the local
  `current-session-cost` plugin is symlinked from
  `~/opencode-plugins/current-session-cost`. `cli.json` disables
  `opencode.sidebar.context`, so the local plugin supplies the Context block.
  It depends on `@lidtop/opencode-cost` and its ledger at
  `~/.local/state/opencode/opencode-cost/cost.sqlite`; if the `/cost` plugin is
  removed, the widget falls back to `session.cost()`. If `/cost` uses a custom
  database path, set the widget's `database` option to match.

---

## 6. Where to change what

| Task | Edit | Notes |
|---|---|---|
| Hyprland base options/animations/window rules | `hypr/hyprland.lua` | Loaded first; DMS modules override later |
| Hyprland/DMS keybindings | `hypr/dms/binds-user.lua` | `binds.lua` is generated stock; DMS setup replaces it |
| Hyprland gaps/border/rounding/blur | DMS GUI, or `hypr/dms/layout.lua` | Generated; GUI changes win |
| Hyprland monitor mode/scale/VRR | DMS GUI, or `hypr/dms/outputs.lua` | Generated; verify with `hyprctl monitors` |
| Hyprland colors | `hypr/dms/colors.lua` | Generated by Matugen; change wallpaper/theme instead |
| DMS bar/dock/widgets/theme | DMS GUI → `dms/settings.json` | Written atomically; directory symlink is intentional |
| DMS plugin toggles / Wallhaven key | DMS GUI → `dms/plugin_settings.json` | Ignored secret; never stage |
| DMS plugins | DMS plugin manager → `dms/plugins.lock.json` | `dms/plugins/` is a re-downloadable cache |
| Terminal colors/font/opacity/shaders | `ghostty/config` | Add `theme = dankcolors` to use the generated palette |
| Alacritty colors/font/opacity | `alacritty/alacritty.toml` | `dank-theme.toml` is generated and not imported by default |
| Fish shell behavior | `fish/config.fish`, `fish/conf.d/`, `fish/functions/` | Fisher may rewrite its own files |
| Default applications | `mimeapps.list` | Re-link if `xdg-mime` replaces the symlink |
| GTK/X cursor, font, theme | `xsettingsd/xsettingsd.conf` | Read by xsettingsd/XWayland apps |
| Session environment | `environment.d/90-dms.conf` | DMS rewrites it; file symlink is safe |
| Autostart entries | `autostart/*.desktop` | Both currently `Hidden=true` |
| Cursor theme/size | DMS GUI, `xsettingsd`, `kdeglobals`, legacy `kineticwe/appearance.kwe` | Multiple places; keep in sync |
| Noctalia bar/dock/widgets/theme (legacy) | `noctalia-full-config.toml` base + live state | GUI writes the state file; export to repo to persist |
| Noctalia idle/lock (legacy) | `noctalia-full-config.toml` lines 246 / 294 | Live overrides may win |
| Nvim plugins | `nvim/lua/plugins/*.lua` | Remove the `if true then return {} end` guard to activate |
| Nvim core options/mappings | `nvim/lua/plugins/astrocore.lua` | Currently disabled template |
| Nvim LSP/formatting | `nvim/lua/plugins/astrolsp.lua` + `none-ls.lua` | Disabled templates |
| Nvim colorscheme/icons | `nvim/lua/plugins/astroui.lua` | Disabled template |
| Zed editor settings | `zed-stuff/zed/settings.json` | JSONC |
| Zed keybindings | `zed-stuff/zed/keymap.json` | JSONC |
| Zed theme colors | `zed-stuff/vesper-blur/themes/vesper-blur.json` | Installed via extension symlink |
| XCursor theme assets | `Bibata-Modern-Ice/` | Copy to `/usr/share/icons`, not symlink |
| OpenCode TUI plugins/settings | `opencode/cli.json` | TUI-only; local plugin + built-in disable directives |
| OpenCode server plugins | `opencode/opencode.json` | Server/TUI packages; `/cost` ledger comes from here |
| Current-session cost widget | `opencode/plugins/current-session-cost/tui.tsx` | Read-only `/cost` ledger; no build step |
| Commit-time secret guard | `.githooks/pre-commit` | Enabled by `install.sh`; scans staged files |
| KineticWE gaps/layout/corner radius | `kineticwe/kineticwe.kwe` `[Tiling]` line 40 | Legacy; generated by Kinetic Settings |
| KineticWE global blur | `kineticwe/kineticwe.kwe` `[Effect-blur]` line 14 | Legacy |
| KineticWE output mode/HDR/VRR | `kscreen-doctor -o`; output JSON only as snapshot | Legacy session |

---

## 7. Gotchas / repo ↔ live drift (verified 2026-11-19)

1. **The live session is Hyprland + DMS, not KineticWE + Noctalia.** Packages
   for both are installed; `/usr/share/wayland-sessions/` contains
   `hyprland.desktop`, `hyprland-uwsm.desktop`, `kineticwe.desktop`, and
   `plasma.desktop`. Do not assume `kineticwe/` or
   `noctalia-full-config.toml` is live.
2. **DMS uses atomic writes** for `dms/settings.json` and
   `dms/plugin_settings.json` (temp file + rename). `~/.config/dms` must stay a
   **directory symlink**; a file symlink would be replaced by a regular file on
   the next save. `hypr/dms/*` is safe for the same reason: the whole
   directory is linked.
3. **`dms/plugin_settings.json` contains the Wallhaven API key.** It is
   gitignored but physically present in the repo directory. Never print it,
   stage it, or copy it elsewhere. `dms/plugins/` and the runtime markers are
   ignored too.
4. **DMS-generated files are overwritten:** `hypr/dms/{binds,colors,input,
   layout,outputs,windowrules}.lua`, `alacritty/dank-theme.toml`,
   `ghostty/themes/dankcolors`, and `zed-stuff/zed/themes/dank-zed-theme.json`.
   Hand edits can disappear on the next DMS setup/theme change.
5. **`hypr/.dms-backups/` is ignored.** It holds DMS's own copies of replaced
   configs; do not treat it as source.
6. **`mimeapps.list` is a file symlink.** `xdg-mime` writes with
   `temp file + mv`, which replaces the symlink. After changing defaults, run
   `test -L ~/.config/mimeapps.list` and re-link if it became a regular file.
7. **`environment.d/90-dms.conf` is a file symlink.** DMS uses
   `os.WriteFile` (truncate), which follows the link, so this one is safe.
   `~/.config/environment.d/cursor.conf` is root-owned and not tracked.
8. **`fish/fish_variables` and `fish/completions/bun.fish` are ignored.**
   Universal variables and Bun completions are generated/local state. Fisher
   owns `conf.d/fish_ai.fish` and `functions/*.fish`.
9. **`ghostty/config.ghostty` is empty.** The live setup applies
   `ghostty/config` (verified via `ghostty +show-config`), even though Ghostty
   1.4's docs name `config.ghostty` as the default path. Keep edits in
   `config` unless you re-verify the load order.
10. **Zed files are JSONC.** Comments and trailing commas are valid there;
    `jq` and strict JSON parsers will reject them. Do not reformat to strict
    JSON unless the user asks.
11. **Most Nvim plugin templates are inactive.** Only
    `nvim/lua/plugins/cheatsheet.lua` is active. `community.lua`,
    `polish.lua`, and the other plugin files return early. AstroNvim defaults
    apply until a guard is removed.
12. **`lazy-lock.json` is generated.** Use `:Lazy` to update; don't hand-edit
    commit hashes.
13. **`kineticwe/kdeglobals` is an absolute symlink to
    `~/.config/kdeglobals`** and is gitignored. It exists only on this machine.
    Do not commit it, replace it with a regular file, or delete it with
    `git clean`.
14. **Both output-config JSONs are stale.** Under Hyprland, `hyprctl monitors`
    is authoritative (`DP-1`, 2560×1440@240, scale 1, VRR on, 10-bit). The
    KineticWE `kineticweoutputconfig.json` and the live
    `~/.config/kineticweoutputconfig.json` disagree with each other; don't
    mass-rename UUIDs or trust either JSON unless the user asks.
15. **`kineticwe.kwe` contains stale tiling blocks** for UUIDs that are not in
    `[Desktops]` (`1999f8fa…`, `6f765c7a…`, `c9f56509…`, `d51b32c5…`,
    `dbba8f33…`). Empty `tiles` arrays are normal floating state.
16. **`.kwe` files are generated** by Kinetic Settings and re-applied at session
    start. Hand edits can be overwritten by the Settings UI or session
    shutdown.
17. **Noctalia's repo config is not deployed.**
    `~/.config/noctalia-kwe/` is empty. The live overrides are
    `~/.local/state/noctalia-kwe/settings.toml` (`config_version = 16`), which
    wins over any copied full-config file.
18. **The live Noctalia state file contains secrets.** It has API keys under
    `[plugin_settings."coder/deepseek_usage"]` and
    `[plugin_settings."noctalia/wallhaven"]`. Never copy, print, diff, or
    commit that file. The repo export contains no keys.
19. **DMS's `plugin_settings.json` also contains secrets.** See item 3.
20. **Noctalia regenerates `kineticwe/decoration.colors`.** A theme or wallpaper
    change in the legacy session can overwrite it through the built-in
    `kineticwe` template.
21. **Noctalia merge order:** all `*.toml` in `~/.config/noctalia-kwe/` are
    merged alphabetically, then `~/.local/state/noctalia-kwe/settings.toml` is
    applied as overrides.
22. **No build/test suite exists.** Don't add one or run package managers to
    validate dotfiles. Use §8.
23. **`~/.config/opencode/service.json` contains a password.** It is
    deliberately not tracked. Never copy it into the repo, print it, or
    overwrite it with a repo file. Only `cli.json` and `opencode.json` are
    symlinked.
24. **OpenCode config is split by plugin type.** TUI-only packages go in
    `cli.json`; packages with a server entry go in `opencode.json` (their
    `./tui` loads automatically). The local `current-session-cost` is TUI-only
    and is listed in `cli.json`. It is paired with
    `-opencode.sidebar.context`; removing the plugin without removing that
    line leaves the sidebar with no Context section.
25. **The local plugin is loaded directly from TSX.** There is no build step.
    Its `cli.json` entry uses the live symlink
    `/home/opi/opencode-plugins/current-session-cost`, which must point at
    `opencode/plugins/current-session-cost`. The widget reads the `/cost`
    SQLite ledger; if the ledger path changes, update its `database` option.
26. **OpenCode's npm plugin cache is not tracked.** `~/.cache/opencode/npm/`
    is fetched from the package names in the JSON files; do not commit it.
27. **Node/npm currently fail** with `libsimdjson.so.36: cannot open shared
    object file`; use Bun 1.4.4 for scripts. Python 3.13, Rust 1.100, Go, gcc,
    clang, cmake, jq, ripgrep, fd, and gh work.
28. **Screenshots:** use `dms screenshot full --dir /tmp/opencode
    --filename screenshot.png --no-clipboard`. It writes 2560×1440 PNGs.
    Spectacle is still installed for the legacy session but is not the reliable
    path under Hyprland.

---

## 8. Safe, read-only checks

Run from `/home/opi/dotfiles`:

```sh
git status --short --ignored      # tracked + ignored live/runtime files
git diff --check                  # whitespace errors
git hook run pre-commit           # secret guard against the index

bash -n install.sh                # installer syntax
./install.sh --dry-run --yes      # what a deploy would change; writes nothing

hyprctl configerrors              # current Hyprland config errors (empty = ok)
find hypr -name '*.lua' -print0 | xargs -0 -n1 luac -p
jq empty dms/settings.json dms/plugins.lock.json
fish -n fish/config.fish fish/conf.d/*.fish fish/functions/*.fish

ghostty +validate-config --config-file=ghostty/config
ghostty +show-config --changes-only   # proves which values are live
hyprctl monitors                      # current displays (read-only)

python3 - <<'PY'
import tomllib
for p in ("noctalia-full-config.toml", "kineticwe/lsfg-vk/conf.toml"):
    tomllib.load(open(p, "rb"))
print("TOML OK")
PY

jq empty kineticwe/kineticweoutputconfig.json
jq empty zed-stuff/vesper-blur/themes/vesper-blur.json
jq empty opencode/cli.json opencode/opencode.json
readlink -f ~/.config/hypr ~/.config/dms ~/.config/alacritty ~/.config/fish \
  ~/.config/opencode/cli.json ~/.config/opencode/opencode.json \
  ~/opencode-plugins/current-session-cost
test -L ~/.config/mimeapps.list && echo "mimeapps link ok"

for f in $(find nvim -name '*.lua'); do luac -p "$f" || exit 1; done
```

Notes:

- `stylua` and `selene` are **not installed**; do not install them just to
  check formatting. Follow `.stylua.toml` / `selene.toml` manually.
- `jq` is not valid for Zed `settings.json`/`keymap.json` (JSONC).
- No standard validator is available for KConfig files (`.kwe`, `kdeglobals`,
  `kglobalshortcutsrc`); do not rewrite them with an INI parser, because
  KConfig uses nested `[Section][Subsection]` syntax.
- Do not run `noctalia-kwe`, KineticWE binaries, `dms run`, or other live
  GUI/session components to "test" config.
- `~/.config/opencode/service.json` is not tracked; never print or dump it in
  checks. Likewise, never dump `dms/plugin_settings.json`.

---

## 9. Related paths outside the repo

| Path | What it is |
|---|---|
| `/usr/bin/hyprctl` | Hyprland IPC/status tool (`hyprctl monitors`, `configerrors`, `reload`) |
| `/usr/bin/dms` | DMS CLI (package `dux-shell` 2.1.2): `dms ipc`, `dms screenshot`, `dms plugins`, `dms backup`, `dms doctor` |
| `~/.config/hypr/dms/` | Live path for `hypr/dms/` (through the `~/.config/hypr` symlink) |
| `~/.config/dms/` | Live DMS settings (symlink target of `dms/`) |
| `~/.local/state/dms/` | DMS runtime state: session, app usage, wallhaven cache, PAM/wellbeing |
| `~/Pictures/Screenshots/` | Default `dms screenshot` output |
| `/usr/share/wayland-sessions/hyprland.desktop` | Hyprland session entry |
| `/usr/share/wayland-sessions/kineticwe.desktop` | Legacy KineticWE session entry |
| `/usr/bin/kinetic-we`, `/usr/bin/start-kineticwe` | Legacy KineticWE launcher/session start |
| `/usr/bin/noctalia-kwe` | Legacy Noctalia shell binary |
| `/usr/share/kineticwe-wayland/` | Legacy compositor effects, scripts, tabbox, frames, assets |
| `~/.config/opencode/` | Live OpenCode config dir; `cli.json`/`opencode.json` symlink into this repo; `service.json` is machine-local |
| `~/.local/state/opencode/opencode-cost/cost.sqlite` | `/cost` plugin ledger read by the local sidebar widget |
| `~/.config/gtk-3.0/dank-colors.css`, `~/.config/gtk-4.0/dank-colors.css` | DMS Matugen GTK color outputs |
| `~/.config/gtk-3.0/noctalia.css`, `gtk-4.0/noctalia.css` | Stale legacy Noctalia GTK outputs |
| `~/.config/qt6ct/`, `~/.config/qt5ct/` | Qt theme config; generated colors may be stale |
| `~/.local/share/color-schemes/noctalia.colors` | Legacy Noctalia KDE color scheme |
| `~/.config/kdeglobals` | Live KDE globals; exposed in repo via `kineticwe/kdeglobals` symlink |
| `~/.config/zed`, `~/.config/ghostty`, `~/.config/nvim`, `~/.config/kineticwe` | Live symlinks back into this repo |
| `~/.config/opencode/service.json` | OpenCode service password; never print/copy |
| `~/opencode-plugins/current-session-cost` | Live symlink to `opencode/plugins/current-session-cost` |
| `~/.cache/opencode/npm/` | Fetched npm plugin cache; not tracked |
| `/usr/share/icons/Bibata-Modern-Ice` | Deployed cursor theme |
| `/opt/firefox-nightly` | Official Firefox Nightly tarball tree; owned by `opi` so its updater can write |
| `/usr/share/applications/firefox-nightly.desktop` | Nightly launcher written by `install.sh` |
| `/usr/local/bin/firefox-nightly` | Symlink to `/opt/firefox-nightly/firefox` |
| `~/.config/mozilla/firefox/` | Nightly profile (Nightly follows XDG config, not `~/.mozilla`) |
| `~/.local/share/zed/extensions/installed/vesper-blur` | Deployed Zed theme extension |

Installed Hyprland/DMS packages (as of verification): `hyprland 0.57.2-1.1`,
`dux-shell 2.1.2-1.1` (provides `dms-shell`), `quickshell 0.3.2-1.1`,
`matugen 4.2.0-1.1`, `hyprland-guiutils 0.2.2-6.1`, `hyprlang 0.6.8-5.1`,
`hyprtoolkit 0.6.0-3.1`, `hyprutils 0.14.4-1`, `hyprwire 0.3.1-3.1`,
`hyprcursor 0.1.14-1.1`, `hyprgraphics 0.6.0-1.1`.
Legacy KineticWE packages: `kineticwe 2:0.2.0-1.202611101712`,
`kineticwe-noctalia`, `kineticwe-greeter`, `kineticwe-keyring`.

---

## 10. Refresh this map when things drift

If a value or path is suspect, re-derive it cheaply:

```sh
git ls-files | sort                              # tracked files
git status --short --ignored                     # live symlinks + user edits
find . -path ./.git -prune -o -type f -print | sort
grep -n '^\[' noctalia-full-config.toml          # legacy TOML section index
grep -n '^\[' kineticwe/kglobalshortcutsrc       # shortcut section index
hyprctl monitors                                 # current displays
hyprctl configerrors                             # current Hyprland errors
dms --help                                       # DMS CLI surface
ls -la ~/.config ~/.local/state/dms              # live deployment/runtime
ls -la ~/.config/opencode ~/opencode-plugins     # live OpenCode links
```

Update this file when a path, deployment method, or repo↔live drift fact
changes. The goal is that the next agent does not need to rediscover it.
