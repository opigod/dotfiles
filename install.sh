#!/usr/bin/env bash
# Install these dotfiles on the current machine.
#
# Symlinked paths are edited in place: changes in this repo apply immediately.
# Existing files are never overwritten unless --force is given, and then they
# are moved to <path>.bak.<timestamp> first.
set -euo pipefail

REPO="$(cd -- "$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")" && pwd)"
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
DATA="${XDG_DATA_HOME:-$HOME/.local/share}"
STATE="${XDG_STATE_HOME:-$HOME/.local/state}"
STAMP="$(date +%Y%m%d-%H%M%S)"

DRY_RUN=0
ASSUME_YES=0
FORCE=0
INSTALL_CURSOR=1
INSTALL_OPENCODE=1

usage() {
  cat <<'EOF'
Usage: ./install.sh [OPTIONS]

Links and copies this repository's configs into the current user's home.
Run it as your normal user; sudo is used only for system-wide steps (the
cursor theme and the optional Firefox Nightly install).

Options:
  -n, --dry-run        Show what would be done, change nothing
  -y, --yes            Do not ask for confirmation (backups still happen)
  -f, --force          Replace existing files/dirs (they are backed up first)
      --skip-cursor    Do not install the Bibata cursor theme (/usr/share/icons)
      --skip-opencode  Do not link the OpenCode configuration
  -h, --help           Show this help

Firefox Nightly is offered as an optional extra during an interactive run;
--yes skips that offer. It is installed under /opt and owned by you, so its
built-in updater works. An existing Nightly tree is kept and repaired.

Existing targets are left alone by default. "skip ... use --force" in the
output means that path already exists and differs from this repository.
EOF
}

say() { printf '%s\n' "$*"; }

run() {
  if ((DRY_RUN)); then
    printf '        [dry-run]'
    printf ' %q' "$@"
    printf '\n'
  else
    "$@"
  fi
}

confirm() {
  ((ASSUME_YES)) && return 0
  local reply
  read -r -p "$1 [y/N] " reply
  case "$reply" in
    [yY] | [yY][eE][sS]) return 0 ;;
    *) return 1 ;;
  esac
}

backup() {
  local dest="$1" bak="$1.bak.$STAMP"
  say "        backup  $dest -> $bak"
  run mv -- "$dest" "$bak"
}

# link_path SRC DEST - point DEST at SRC.
link_path() {
  local src="$1" dest="$2"

  if [[ -L "$dest" ]]; then
    if [[ "$(readlink -f -- "$dest" 2>/dev/null || true)" == "$(readlink -f -- "$src")" ]]; then
      say "  ok      $dest"
      return 0
    fi
    if ((!FORCE)); then
      say "  skip    $dest (links to $(readlink -- "$dest"); use --force to retarget)"
      return 0
    fi
    backup "$dest"
  elif [[ -e "$dest" ]]; then
    if ((!FORCE)); then
      say "  skip    $dest (exists; use --force to replace, a backup is made)"
      return 0
    fi
    backup "$dest"
  fi

  run mkdir -p -- "$(dirname -- "$dest")"
  say "  link    $dest -> $src"
  run ln -s -- "$src" "$dest"
}

# copy_file SRC DEST - copy a regular file, skipping unchanged targets.
copy_file() {
  local src="$1" dest="$2"

  if [[ -e "$dest" ]]; then
    if cmp -s -- "$src" "$dest"; then
      say "  ok      $dest"
      return 0
    fi
    if ((!FORCE)); then
      say "  skip    $dest (differs; use --force to replace, a backup is made)"
      return 0
    fi
    backup "$dest"
  fi

  run mkdir -p -- "$(dirname -- "$dest")"
  say "  copy    $src -> $dest"
  run cp -p -- "$src" "$dest"
}

install_config_links() {
  say "Config symlinks"
  link_path "$REPO/ghostty" "$CONFIG/ghostty"
  link_path "$REPO/kineticwe" "$CONFIG/kineticwe"
  link_path "$REPO/nvim" "$CONFIG/nvim"
  link_path "$REPO/zed-stuff/zed" "$CONFIG/zed"
  link_path "$REPO/zed-stuff/vesper-blur" \
    "$DATA/zed/extensions/installed/vesper-blur"
}

install_noctalia() {
  local dest="$CONFIG/noctalia-kwe/noctalia-full-config.toml"
  local live="$STATE/noctalia-kwe/settings.toml"

  say "Noctalia"
  if [[ -f "$live" ]] && ((!FORCE)); then
    say "  skip    $dest (live settings exist in $live and override this base layer)"
    return 0
  fi
  copy_file "$REPO/noctalia-full-config.toml" "$dest"
}

install_lsfg() {
  say "Lossless Scaling frame generation"
  copy_file "$REPO/kineticwe/lsfg-vk/conf.toml" "$CONFIG/lsfg-vk/conf.toml"
}

install_cursor() {
  local src="$REPO/Bibata-Modern-Ice"
  local dest="/usr/share/icons/Bibata-Modern-Ice"
  local -a priv=()

  say "XCursor theme"
  if [[ ! -w "/usr/share/icons" ]] && ((EUID != 0)); then
    if ! command -v sudo >/dev/null 2>&1; then
      say "  skip    $dest (no write access to /usr/share/icons and sudo is missing)"
      return 0
    fi
    priv=(sudo)
  fi

  if [[ -e "$dest" ]]; then
    if ((!FORCE)); then
      say "  ok      $dest (already installed; use --force to refresh)"
      return 0
    fi
    say "        backup  $dest -> $dest.bak.$STAMP"
    run "${priv[@]}" mv -- "$dest" "$dest.bak.$STAMP"
  fi

  say "  copy    $src -> /usr/share/icons/"
  run "${priv[@]}" mkdir -p -- /usr/share/icons
  run "${priv[@]}" cp -a -- "$src" /usr/share/icons/
}

install_opencode() {
  say "OpenCode"
  link_path "$REPO/opencode/cli.json" "$CONFIG/opencode/cli.json"
  link_path "$REPO/opencode/opencode.json" "$CONFIG/opencode/opencode.json"
  link_path "$REPO/opencode/plugins/current-session-cost" \
    "$HOME/opencode-plugins/current-session-cost"

  # Machine-local global instructions; not tracked, so only link if present.
  if [[ -f "$REPO/opencode/AGENTS.md" ]]; then
    link_path "$REPO/opencode/AGENTS.md" "$CONFIG/opencode/AGENTS.md"
  fi
}

# Mozilla ships Nightly as a tarball, not as a package. Unpack it into /opt and
# give the tree to the user: Nightly's built-in updater writes next to the
# binary, and a root-owned tree silently stays on the build it was installed
# from. The profile lives in ~/.config/mozilla, so replacing the tree is safe.
install_firefox() {
  local dir="/opt/firefox-nightly"
  local stage="/opt/firefox-nightly.new"
  local old="/opt/firefox-nightly.old"
  local desktop="/usr/share/applications/firefox-nightly.desktop"
  local bin="/usr/local/bin/firefox-nightly"
  local url="https://download.mozilla.org/?product=firefox-nightly-latest-ssl&os=linux64&lang=en-US"
  local tmp version
  local -a priv=()

  say "Firefox Nightly"

  if ((EUID != 0)); then
    if ! command -v sudo >/dev/null 2>&1; then
      say "  skip    $dir (needs root and sudo is missing)"
      return 0
    fi
    priv=(sudo)
  fi

  # A download is needed for a missing tree or a forced refresh; check the tool
  # before offering the install, not after the user says yes.
  if [[ ! -x "$dir/firefox" ]] || ((FORCE)); then
    if ! command -v curl >/dev/null 2>&1; then
      say "  skip    $dir (curl is missing)"
      return 0
    fi
  fi

  # Optional: asked here, in the script's own run, not through an argument.
  # An existing tree is maintained without asking (ownership, launcher, link).
  if [[ ! -x "$dir/firefox" ]]; then
    if ((ASSUME_YES)); then
      say "  skip    $dir (optional; run without --yes to install it)"
      return 0
    fi
    if ! confirm "  Install it now into /opt (~100 MB, needs sudo)?"; then
      say "  skip    $dir (declined)"
      return 0
    fi
  fi

  if [[ -x "$dir/firefox" ]] && ((!FORCE)); then
    say "  ok      $dir (already installed; Nightly updates itself)"
  elif ((DRY_RUN)); then
    say "  fetch   $url"
    say "        [dry-run] unpack into $stage, then swap it with $dir"
  else
    say "  fetch   $url"
    "${priv[@]}" rm -rf -- "$stage" "$old"
    "${priv[@]}" mkdir -p -- "$stage"
    if ! curl --fail --location --progress-bar "$url" |
      "${priv[@]}" tar -xJf - -C "$stage" --strip-components=1; then
      say "  skip    $dir (download or unpack failed)"
      "${priv[@]}" rm -rf -- "$stage"
      return 0
    fi
    if [[ -e "$dir" ]]; then
      "${priv[@]}" mv -- "$dir" "$old"
    fi
    "${priv[@]}" mv -- "$stage" "$dir"
    "${priv[@]}" rm -rf -- "$old"
  fi

  # Hand-installed trees are often root-owned; take ownership so updates apply.
  if [[ -d "$dir" ]] && [[ "$(stat -c %u -- "$dir")" != "$(id -u)" ]]; then
    say "  chown   $dir -> $(id -un):$(id -gn)"
    run "${priv[@]}" chown -R -- "$(id -u):$(id -g)" "$dir"
  fi

  if [[ -x "$dir/firefox" ]] && ((!DRY_RUN)); then
    version="$("$dir/firefox" --version 2>/dev/null || true)"
    if [[ -n "$version" ]]; then
      say "        $version"
    fi
  fi

  # Launcher; rewritten only when it does not point at this install.
  if [[ -f "$desktop" ]] && grep -qxF -- "Exec=$dir/firefox %u" "$desktop"; then
    say "  ok      $desktop"
  elif ((DRY_RUN)); then
    say "        [dry-run] write $desktop"
  else
    say "  write   $desktop"
    tmp="$(mktemp)"
    cat >"$tmp" <<EOF
[Desktop Entry]
Name=Firefox Nightly
Exec=$dir/firefox %u
Icon=$dir/browser/chrome/icons/default/default128.png
Type=Application
Categories=Network;WebBrowser;
MimeType=text/html;x-scheme-handler/http;x-scheme-handler/https;
StartupNotify=true
EOF
    "${priv[@]}" install -Dm644 -- "$tmp" "$desktop"
    rm -f -- "$tmp"
  fi

  # A dangling link (old /opt/firefox path) is repaired; a real file is kept.
  if [[ -L "$bin" ]] &&
    [[ "$(readlink -f -- "$bin" 2>/dev/null || true)" == "$(readlink -f -- "$dir/firefox")" ]]; then
    say "  ok      $bin"
  elif [[ -e "$bin" ]] && ((!FORCE)); then
    say "  skip    $bin (exists; use --force to replace)"
  else
    say "  link    $bin -> $dir/firefox"
    run "${priv[@]}" ln -sfn -- "$dir/firefox" "$bin"
  fi
}

main() {
  while (($#)); do
    case "$1" in
      -n | --dry-run) DRY_RUN=1 ;;
      -y | --yes) ASSUME_YES=1 ;;
      -f | --force) FORCE=1 ;;
      --skip-cursor) INSTALL_CURSOR=0 ;;
      --skip-opencode) INSTALL_OPENCODE=0 ;;
      -h | --help)
        usage
        exit 0
        ;;
      *)
        printf 'Unknown option: %s\n\n' "$1" >&2
        usage >&2
        exit 2
        ;;
    esac
    shift
  done

  if ((DRY_RUN)); then
    say "Dry run: no changes will be made."
  elif ((!ASSUME_YES)); then
    say "This links dotfiles into $CONFIG and $DATA and copies the cursor theme."
    say "Existing files are kept unless --force is given."
    confirm "Continue?" || {
      say "Aborted."
      exit 1
    }
  fi

  install_config_links

  if ((INSTALL_OPENCODE)); then
    install_opencode
  fi

  install_noctalia
  install_lsfg

  if ((INSTALL_CURSOR)); then
    install_cursor
  fi

  install_firefox

  say ""
  if ((DRY_RUN)); then
    say "Dry run finished. Re-run without --dry-run to apply."
  else
    say "Done. Log out and back in so KineticWE, Noctalia, and Zed reload the config."
    say "OpenCode picks up its config the next time it starts."
  fi
}

main "$@"
