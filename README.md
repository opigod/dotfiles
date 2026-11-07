noctalia bar is glitched on resolutions lower than 2560x1440 u have to scale it manually to fix it

## Deploy

Run from the repo root:

```sh
ln -s ghostty ~/.config/
ln -s kineticwe ~/.config/
ln -s nvim ~/.config/
ln -s zed-stuff/zed ~/.config
ln -s zed-stuff/vesper-blur ~/.local/share/zed/extensions/installed/
cp noctalia-full-config.toml ~/.config/noctalia-kwe/
cp Bibata-Modern-Ice /usr/share/icons
```

## OpenCode

```sh
mkdir -p ~/.config/opencode ~/opencode-plugins
ln -sfn "$PWD/opencode/cli.json" ~/.config/opencode/cli.json
ln -sfn "$PWD/opencode/opencode.json" ~/.config/opencode/opencode.json
ln -sfn "$PWD/opencode/plugins/current-session-cost" ~/opencode-plugins/current-session-cost
```

`~/.config/opencode/service.json` is intentionally not tracked: it contains the
OpenCode service password. Keep it machine-local. The npm plugins listed in
`cli.json` and `opencode.json` are fetched by OpenCode itself; only the local
`current-session-cost` plugin source is stored here.
