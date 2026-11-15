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
Run it as your normal user; sudo is only used for the system cursor theme.

Options:
  -n, --dry-run        Show what would be done, change nothing
  -y, --yes            Do not ask for confirmation (backups still happen)
  -f, --force          Replace existing files/dirs (they are backed up first)
      --skip-cursor    Do not install the Bibata cursor theme (/usr/share/icons)
      --skip-opencode  Do not link the OpenCode configuration
  -h, --help           Show this help

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

  say ""
  if ((DRY_RUN)); then
    say "Dry run finished. Re-run without --dry-run to apply."
  else
    say "Done. Log out and back in so KineticWE, Noctalia, and Zed reload the config."
    say "OpenCode picks up its config the next time it starts."
  fi
}

main "$@"
