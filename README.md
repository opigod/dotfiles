# dotfiles

Personal CachyOS dotfiles for a Hyprland (Wayland) session with DMS (Dux Modular
Shell): Ghostty, Alacritty, fish, Hyprland, DMS, AstroNvim, Zed, OpenCode, and
the Bibata cursor theme.

Most directories are symlinked into the live config, so editing a file here
changes the running desktop immediately.

The old KineticWE + Noctalia session is still installed and its configs remain
tracked in this repo as a legacy fallback; see [Legacy KineticWE](#legacy-kineticwe).

## Install

```sh
git clone https://github.com/opigod/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

`install.sh` is idempotent and non-destructive:

- creates the config symlinks and copies the files that cannot be symlinked;
- keeps existing files by default, and with `--force` moves them to
  `<path>.bak.<timestamp>` before replacing them;
- installs the cursor theme with `sudo` (it writes to `/usr/share/icons`);
- offers Firefox Nightly as an optional extra during an interactive run;
- activates the tracked pre-commit guard, which rejects staged API keys,
  tokens, and passwords (empty placeholders are fine);
- never touches `~/.config/opencode/service.json`, `~/.config/dms/plugin_settings.json`,
  or the live Noctalia state.

Useful flags: `--dry-run`, `--yes`, `--force`, `--skip-cursor`,
`--skip-opencode`. See `./install.sh --help`.

## What goes where

| Repository | Live path | Kind |
|---|---|---|
| `ghostty/` | `~/.config/ghostty` | symlink |
| `hypr/` | `~/.config/hypr` | symlink |
| `dms/` | `~/.config/dms` | symlink (runtime files ignored) |
| `alacritty/` | `~/.config/alacritty` | symlink |
| `fish/` | `~/.config/fish` | symlink (`fish_variables` stays local) |
| `autostart/` | `~/.config/autostart` | symlink |
| `xsettingsd/` | `~/.config/xsettingsd` | symlink |
| `environment.d/90-dms.conf` | `~/.config/environment.d/90-dms.conf` | file symlink |
| `mimeapps.list` | `~/.config/mimeapps.list` | file symlink |
| `kineticwe/` | `~/.config/kineticwe` | symlink (legacy) |
| `nvim/` | `~/.config/nvim` | symlink |
| `zed-stuff/zed/` | `~/.config/zed` | symlink |
| `zed-stuff/vesper-blur/` | `~/.local/share/zed/extensions/installed/vesper-blur` | symlink |
| `Bibata-Modern-Ice/` | `/usr/share/icons/Bibata-Modern-Ice` | copy (needs root) |
| `noctalia-full-config.toml` | `~/.config/noctalia-kwe/noctalia-full-config.toml` | copy (legacy) |
| `kineticwe/lsfg-vk/conf.toml` | `~/.config/lsfg-vk/conf.toml` | copy |
| `opencode/cli.json` | `~/.config/opencode/cli.json` | symlink |
| `opencode/opencode.json` | `~/.config/opencode/opencode.json` | symlink |
| `opencode/plugins/current-session-cost/` | `~/opencode-plugins/current-session-cost` | symlink |

Log out and back in after installing so Hyprland, DMS, and Zed reload the
config. OpenCode reads its config when it next starts.

## Firefox Nightly (optional)

During an interactive run, `./install.sh` asks whether to install Mozilla's
official Nightly tarball into `/opt/firefox-nightly`, writes
`/usr/share/applications/firefox-nightly.desktop`, and links
`/usr/local/bin/firefox-nightly`. Answer `n` and Firefox is not touched. With
`--yes` no question is asked: a missing install stays missing, while an
existing one is still kept repaired.

The install tree is chowned to the user because Nightly updates itself by
writing next to the binary; a root-owned tree silently stays on the build it was
installed from. The profile lives in `~/.config/mozilla/firefox`, so refreshing
the install with `--force` keeps bookmarks, logins, and extensions — quit
Nightly first.

Manual equivalent:

```sh
sudo mkdir -p /opt/firefox-nightly
curl -fL "https://download.mozilla.org/?product=firefox-nightly-latest-ssl&os=linux64&lang=en-US" |
  sudo tar -xJf - -C /opt/firefox-nightly --strip-components=1
sudo chown -R "$USER:" /opt/firefox-nightly
sudo ln -sfn /opt/firefox-nightly/firefox /usr/local/bin/firefox-nightly
```

## Manual deploy

If you prefer not to run the installer, run this from the repository root:

```sh
mkdir -p ~/.config \
         ~/.config/environment.d \
         ~/.local/share/zed/extensions/installed \
         ~/.config/noctalia-kwe \
         ~/.config/lsfg-vk \
         ~/.config/opencode \
         ~/opencode-plugins

ln -sfn "$PWD/ghostty" ~/.config/ghostty
ln -sfn "$PWD/hypr" ~/.config/hypr
ln -sfn "$PWD/dms" ~/.config/dms
ln -sfn "$PWD/alacritty" ~/.config/alacritty
ln -sfn "$PWD/fish" ~/.config/fish
ln -sfn "$PWD/autostart" ~/.config/autostart
ln -sfn "$PWD/xsettingsd" ~/.config/xsettingsd
ln -sfn "$PWD/environment.d/90-dms.conf" ~/.config/environment.d/90-dms.conf
ln -sfn "$PWD/mimeapps.list" ~/.config/mimeapps.list
ln -sfn "$PWD/nvim" ~/.config/nvim
ln -sfn "$PWD/zed-stuff/zed" ~/.config/zed
ln -sfn "$PWD/zed-stuff/vesper-blur" \
  ~/.local/share/zed/extensions/installed/vesper-blur

# legacy KineticWE/Noctalia
ln -sfn "$PWD/kineticwe" ~/.config/kineticwe
cp noctalia-full-config.toml ~/.config/noctalia-kwe/
cp kineticwe/lsfg-vk/conf.toml ~/.config/lsfg-vk/conf.toml

sudo cp -r Bibata-Modern-Ice /usr/share/icons/   # -r is required; needs root
```

OpenCode links:

```sh
ln -sfn "$PWD/opencode/cli.json" ~/.config/opencode/cli.json
ln -sfn "$PWD/opencode/opencode.json" ~/.config/opencode/opencode.json
ln -sfn "$PWD/opencode/plugins/current-session-cost" \
  ~/opencode-plugins/current-session-cost
```

`~/.config/opencode/service.json` is intentionally not tracked: it contains the
OpenCode service password. Keep it machine-local. The npm plugins named in
`cli.json` and `opencode.json` are fetched by OpenCode itself; only the local
`current-session-cost` plugin source lives here.

## Hyprland and DMS

- `hypr/hyprland.lua` is the hand-edited base config. `hypr/dms/*.lua` is
  generated by DMS (colors, input, layout, outputs, window rules); DMS setup
  also replaces `hypr/dms/binds.lua` with its stock keybinds. Put personal
  overrides in `hypr/dms/binds-user.lua`, which DMS never overwrites.
- `hypr/.dms-backups/` is ignored: those are DMS's own copies of replaced
  configs.
- DMS settings live in `dms/settings.json` and are written by the shell GUI.
  Because the directory is symlinked, GUI changes land in this repo. DMS uses
  atomic writes, which is why the directory (not individual files) is linked.
- `dms/plugins.lock.json` records installed plugins; `dms/plugins/` is a
  re-downloadable cache and is ignored.
- `dms/plugin_settings.json` is ignored: it contains the Wallhaven API key.
  Never stage or commit it.
- Reload after editing: `hyprctl reload`. Check for errors with
  `hyprctl configerrors`.

## Git hooks

`install.sh` points `core.hooksPath` at the tracked `.githooks/` directory.
Its `pre-commit` hook scans staged files for non-empty API keys, tokens,
secrets, and passwords, and rejects the commit before they enter history.
Empty placeholders such as `api_key = ""` and variable references such as
`"${TOKEN}"` are allowed. The hook is shell + awk; no Python is required.

Enable it manually with:

```sh
git config core.hooksPath .githooks
```

If it flags a false positive, bypass it once with `git commit --no-verify`.

## Legacy KineticWE

KineticWE and Noctalia are no longer the default session, but the packages and
their configs remain installed. The tracked files are kept so the fallback
session still works:

- `kineticwe/*.kwe` is written by Kinetic Settings and re-applied at session
  start; `kineticwe/decoration.colors` is generated by a Noctalia theme
  template. Hand edits to generated files can be overwritten.
- `kineticwe/kdeglobals` is a machine-specific absolute symlink to
  `~/.config/kdeglobals` and is gitignored.
- Noctalia merges every `*.toml` in `~/.config/noctalia-kwe/` alphabetically,
  then applies `~/.local/state/noctalia-kwe/settings.toml` as an override.
  That state file is written by the Noctalia GUI and contains API keys, so
  never copy it into this repository. On an existing install, `install.sh`
  skips copying `noctalia-full-config.toml` unless you pass `--force`.
- The output snapshots (`kineticweoutputconfig.json` and the live
  `~/.config/kineticweoutputconfig.json`) are stale. Query the running
  compositor instead: `kscreen-doctor -o` under KineticWE, `hyprctl monitors`
  under Hyprland.

## Notes

- Zed settings and keymaps are JSONC, so comments and trailing commas are
  valid; strict JSON tools will reject them.
- DMS's Matugen hooks generate theme files such as
  `ghostty/themes/dankcolors`, `alacritty/dank-theme.toml`, and
  `zed-stuff/zed/themes/dank-zed-theme.json`. They are tracked for reference
  but can be rewritten by DMS.
- Application state (caches, logs, service passwords) is intentionally not
  tracked; only the config groups listed above are.
