# dotfiles

Personal CachyOS dotfiles for a KineticWE (Wayland + KWin) session: Ghostty,
KineticWE, AstroNvim, Zed, Noctalia, OpenCode, and the Bibata cursor theme.

Most directories are symlinked into the live config, so editing a file here
changes the running desktop immediately.

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
- never touches `~/.config/opencode/service.json` or the live Noctalia state.

Useful flags: `--dry-run`, `--yes`, `--force`, `--skip-cursor`,
`--skip-opencode`. See `./install.sh --help`.

## What goes where

| Repository | Live path | Kind |
|---|---|---|
| `ghostty/` | `~/.config/ghostty` | symlink |
| `kineticwe/` | `~/.config/kineticwe` | symlink |
| `nvim/` | `~/.config/nvim` | symlink |
| `zed-stuff/zed/` | `~/.config/zed` | symlink |
| `zed-stuff/vesper-blur/` | `~/.local/share/zed/extensions/installed/vesper-blur` | symlink |
| `Bibata-Modern-Ice/` | `/usr/share/icons/Bibata-Modern-Ice` | copy (needs root) |
| `noctalia-full-config.toml` | `~/.config/noctalia-kwe/noctalia-full-config.toml` | copy |
| `kineticwe/lsfg-vk/conf.toml` | `~/.config/lsfg-vk/conf.toml` | copy |
| `opencode/cli.json` | `~/.config/opencode/cli.json` | symlink |
| `opencode/opencode.json` | `~/.config/opencode/opencode.json` | symlink |
| `opencode/plugins/current-session-cost/` | `~/opencode-plugins/current-session-cost` | symlink |

Log out and back in after installing so KineticWE, Noctalia, and Zed reload the
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
Nightly first. `Meta+W` already launches this path
(`kineticwe/custom-keybinds.kwe`).

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
         ~/.local/share/zed/extensions/installed \
         ~/.config/noctalia-kwe \
         ~/.config/lsfg-vk \
         ~/.config/opencode \
         ~/opencode-plugins

ln -sfn "$PWD/ghostty" ~/.config/ghostty
ln -sfn "$PWD/kineticwe" ~/.config/kineticwe
ln -sfn "$PWD/nvim" ~/.config/nvim
ln -sfn "$PWD/zed-stuff/zed" ~/.config/zed
ln -sfn "$PWD/zed-stuff/vesper-blur" \
  ~/.local/share/zed/extensions/installed/vesper-blur

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

## Noctalia config layers

Noctalia merges every `*.toml` in `~/.config/noctalia-kwe/` alphabetically,
then applies `~/.local/state/noctalia-kwe/settings.toml` as an override.

That state file is written by the Noctalia GUI and holds the settings actually
in effect. It also contains API keys, so never copy it into this repository.
Use the GUI (or an export) to persist changes, and expect the state override to
mask values from the repo's base config. On an existing install, `install.sh`
therefore skips copying `noctalia-full-config.toml` unless you pass `--force`.

## Notes

- KineticWE `.kwe` files are written by Kinetic Settings and re-applied at
  session start; `kineticwe/decoration.colors` is generated by a Noctalia theme
  template. Hand edits to generated files can be overwritten.
- `kineticwe/kdeglobals` is a machine-specific absolute symlink to
  `~/.config/kdeglobals` and is gitignored.
- The output snapshots (`kineticweoutputconfig.json` and the live
  `~/.config/kineticweoutputconfig.json`) are stale. Query the running
  compositor with `kscreen-doctor -o` instead.
- Zed settings and keymaps are JSONC, so comments and trailing commas are
  valid; strict JSON tools will reject them.

## Known issues

- The Noctalia bar glitches at resolutions below 2560×1440. Scale it manually
  to fix it.
