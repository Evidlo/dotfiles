#!/usr/bin/env bash
#
# Fresh Debian bootstrap for evan.
#
# Safe to re-run: files are refreshed, existing clones are pulled, and
# tools that are already installed are skipped.
#
# To add software:
#   - apt package        -> add a line to APT_PACKAGES
#   - dotfile / config    -> add a line to OVERLAY
#   - a whole tool        -> add a small install_* function and call it in main()
#
# Usage:  ./install_debian.sh

# ----------------------------------------------------------------------
# Settings  (edit these, not the logic below)
# ----------------------------------------------------------------------

DOTFILES_HTTPS="https://github.com/evidlo/dotfiles"
DOTFILES_SSH="git@github.com:evidlo/dotfiles"

GOMUKS_HTTPS="https://github.com/evidlo/gomuks"
GOMUKS_SSH="git@github.com:evidlo/gomuks"
GOMUKS_BRANCH="evidlocustom"   # fork branch that carries the custom build + build.sh

SYNCTHINGTUI_PKG="github.com/evidlo/syncthingtui/cmd/syncthingtui@latest"

# flox ships as a .deb that registers its own apt repo for future upgrades.
# The latest version is resolved at run time from LATEST_VERSION (see install_flox).
FLOX_BASE="https://downloads.flox.dev/by-env/stable"

# Go is installed manually (Debian's package lags too far behind for the go
# tools below). The latest version is resolved at run time (see install_go).
GO_DL="https://go.dev/dl"
GO_PREFIX="/usr/local"        # go lands in $GO_PREFIX/go ; add $GO_PREFIX/go/bin to PATH

DOOM_HTTPS="https://github.com/doomemacs/doomemacs"

RESOURCES="$HOME/resources"
DOTFILES_DIR="$RESOURCES/dotfiles"
GOMUKS_DIR="$RESOURCES/gomuks"
VENV_DIR="$RESOURCES/venv3"
EMACS_DIR="$HOME/.config/emacs"    # doom framework clone (private config is ~/.config/doom)
SECRETS_DIR="$HOME/secrets"        # Syncthing folder holding passhole db, illinikey seed, etc.

# Python tools installed into venv3 (referenced by the i3 config).
# Add a line per tool; git+https entries clone keyless.
VENV_TOOLS=(
  passhole         # provides `ph`  ($mod+p passhole binds)
  illinikey        # $mod+x
  flashfocus       # exec_always flash-on-focus
  yt-dlp           # $mod+m plays clipboard URLs via mpv (venv3/bin on PATH)
  "git+https://github.com/evidlo/nichromecast#subdirectory=python"  # $mod+y cast
)

# Where `go install` drops binaries (matches ~/.profile).
export GOPATH="$RESOURCES/go"
export GOBIN="$RESOURCES/go/bin"

# ----------------------------------------------------------------------
# apt packages  (one per line; add or remove freely)
# NOTE: starting draft -- curate to taste.
# ----------------------------------------------------------------------

APT_PACKAGES=(
  # base cli
  vim
  neovim
  git
  rsync
  htop
  ncdu
  tree
  tmux
  autojump         # `j` fast dir jumping
  tar
  zip
  unzip
  wget
  curl
  aria2
  expect

  # build / languages
  build-essential
  gcc
  make
  python3
  python3-venv
  python3-pip
  libolm-dev       # C headers required to build gomuks (CGO)
  # go is installed manually (see install_go), not via apt.

  # network
  openssh-client
  openssh-server   # sshd (enabled by enable_sshd)
  dnsutils         # dig
  telnet
  nload
  iproute2

  # desktop / wm
  i3
  kitty
  pqiv
  feh
  mpv
  emacs
  acpi
  xscreensaver
  autorandr
  arandr
  powertop
  evince
  zathura          # pdf/document viewer
  zathura-pdf-poppler   # pdf backend for zathura
  light            # backlight control (XF86MonBrightness keys)
  rofi             # launcher ($mod+d) + prompt used by passhole/illinikey binds
  rofimoji         # emoji picker ($mod+e)
  xdotool          # keystroke injection (passhole/illinikey typing)
  xsel             # clipboard read (mpv paste, nichromecast)
  playerctl        # media keys
  maim             # screenshots (Print key)
  dunst            # notifications
  redshift         # night color temp (i3 startup)
  autocutsel       # clipboard sync (i3 startup)
  zenity

  # audio (PulseAudio; pactl drives the volume/mute keys)
  pulseaudio
  pulseaudio-utils

  # network
  network-manager
  network-manager-gnome   # nm-applet (i3 startup)

  # input
  xserver-xorg-input-synaptics   # syndaemon (i3 startup)
  xinit
  xinput

  # mail / matrix
  neomutt

  # misc
  wine
  octave
)

# ----------------------------------------------------------------------
# Everything the dotfiles repo tracks is overlaid into $HOME as-is.
# List only the tracked paths that should NOT go to $HOME (git metadata,
# repo docs, and xorg.conf.d which is installed to /etc separately).
# ----------------------------------------------------------------------

OVERLAY_EXCLUDE=(
  ".git"
  ".gitignore"
  ".gitmodules"
  "xorg.conf.d"
  "README.md"
  "install_debian.sh"
)

# ----------------------------------------------------------------------
# Helpers
# ----------------------------------------------------------------------

info() {
  echo
  echo "==> $*"
}

warn() {
  echo "!!  $*" >&2
}

have() {
  command -v "$1" >/dev/null 2>&1
}

# Verify we can sudo before doing anything. This also caches the sudo
# timestamp so the later steps don't re-prompt for a password.
require_sudo() {
  info "Checking sudo access"
  if ! sudo -v; then
    warn "This script needs sudo, but $USER cannot use it."
    warn "On a fresh box, as root run:  usermod -aG sudo $USER"
    warn "then start a NEW login session and re-run this script."
    exit 1
  fi
}

# ----------------------------------------------------------------------
# Steps
# ----------------------------------------------------------------------

make_dirs() {
  info "Creating base directories"
  mkdir -p "$HOME/bin" "$RESOURCES" "$HOME/downloads"
}

install_apt_packages() {
  info "Installing apt packages"
  sudo apt-get update
  sudo apt-get install -y "${APT_PACKAGES[@]}"
}

clone_dotfiles() {
  info "Fetching dotfiles"
  if [ -d "$DOTFILES_DIR/.git" ]; then
    git -C "$DOTFILES_DIR" pull --ff-only
  else
    git clone "$DOTFILES_HTTPS" "$DOTFILES_DIR"
  fi
  # Clone read-only over https, but push over ssh.
  git -C "$DOTFILES_DIR" remote set-url --push origin "$DOTFILES_SSH"
}

overlay_dotfiles() {
  info "Overlaying dotfiles into \$HOME"
  # rsync the whole repo into $HOME, excluding git metadata and the paths
  # listed in OVERLAY_EXCLUDE. Directories merge; existing files are updated.
  local excludes=()
  local e
  for e in "${OVERLAY_EXCLUDE[@]}"; do
    excludes+=(--exclude "$e")
  done
  rsync -a "${excludes[@]}" "$DOTFILES_DIR/" "$HOME/"
}

install_keyboard_conf() {
  # Caps Lock -> Super (Mod4), plus compose keys. Applies to all keyboards.
  info "Installing X11 keyboard config (caps:super)"
  local src="$DOTFILES_DIR/xorg.conf.d/00-keyboard.conf"
  if [ -f "$src" ]; then
    sudo install -D -m 644 "$src" /etc/X11/xorg.conf.d/00-keyboard.conf
  else
    warn "keyboard conf not found in repo: $src"
  fi
}

setup_venv() {
  info "Creating python venv at $VENV_DIR"
  if [ ! -d "$VENV_DIR" ]; then
    python3 -m venv "$VENV_DIR"
  fi
}

install_venv_tools() {
  info "Installing python tools into venv3"
  "$VENV_DIR/bin/pip" install --upgrade "${VENV_TOOLS[@]}"
}

install_go() {
  info "Installing latest Go into $GO_PREFIX/go"
  local version tarball url
  version=$(curl -fsSL "https://go.dev/VERSION?m=text" | head -1)   # e.g. go1.27.1
  tarball="${version}.linux-amd64.tar.gz"
  url="$GO_DL/$tarball"

  if [ -x "$GO_PREFIX/go/bin/go" ] && "$GO_PREFIX/go/bin/go" version | grep -q "$version"; then
    echo "$version already installed; skipping"
  else
    curl -fL "$url" -o "$HOME/downloads/$tarball"
    sudo rm -rf "$GO_PREFIX/go"
    sudo tar -C "$GO_PREFIX" -xzf "$HOME/downloads/$tarball"
  fi
  # Make go available to the build/install steps in this same run.
  export PATH="$GO_PREFIX/go/bin:$GOBIN:$PATH"
}

install_flox() {
  info "Installing latest flox"
  if have flox; then
    echo "flox already installed; skipping"
    return
  fi
  local version deb
  version=$(curl -fsSL "$FLOX_BASE/LATEST_VERSION")                 # e.g. 1.16.0
  deb="$HOME/downloads/flox-${version}.x86_64-linux.deb"
  curl -fL "$FLOX_BASE/deb/flox-${version}.x86_64-linux.deb" -o "$deb"
  sudo apt-get install -y "$deb"
}

install_claude() {
  info "Installing Claude Code"
  if have claude; then
    echo "claude already installed; skipping"
    return
  fi
  curl -fsSL https://claude.ai/install.sh | bash
}

install_gomuks() {
  # evan's gomuks fork: clone, build, symlink into ~/bin.
  info "Building gomuks (fork, $GOMUKS_BRANCH)"
  if [ -d "$GOMUKS_DIR/.git" ]; then
    git -C "$GOMUKS_DIR" fetch origin "$GOMUKS_BRANCH"
    git -C "$GOMUKS_DIR" checkout "$GOMUKS_BRANCH"
    git -C "$GOMUKS_DIR" pull --ff-only
  else
    git clone -b "$GOMUKS_BRANCH" "$GOMUKS_HTTPS" "$GOMUKS_DIR"
  fi
  git -C "$GOMUKS_DIR" remote set-url --push origin "$GOMUKS_SSH"
  ( cd "$GOMUKS_DIR" && ./build.sh )
  ln -sf ../resources/gomuks/gomuks "$HOME/bin/gomuks"
}

install_syncthingtui() {
  info "Installing syncthingtui"
  go install "$SYNCTHINGTUI_PKG"
}

enable_sshd() {
  info "Enabling ssh server"
  sudo systemctl enable --now ssh
}

install_doom() {
  # Doom Emacs framework. Private config lives in ~/.config/doom (overlaid
  # from the dotfiles repo), so here we only clone the framework and sync.
  info "Installing Doom Emacs"
  if [ ! -d "$EMACS_DIR/.git" ]; then
    git clone --depth 1 "$DOOM_HTTPS" "$EMACS_DIR"
  fi
  if [ -x "$EMACS_DIR/bin/doom" ]; then
    "$EMACS_DIR/bin/doom" sync
  fi
  # Run the emacs daemon at login so `emacsclient -tc` (EDITOR/`e`) always
  # connects instead of failing with "can't find socket".
  systemctl --user enable --now emacs >/dev/null 2>&1 || true
}

link_secrets() {
  # Point tools at secret files that live in the Syncthing secrets folder.
  info "Linking secrets from $SECRETS_DIR"
  if [ ! -d "$SECRETS_DIR" ]; then
    warn "secrets folder $SECRETS_DIR not present (Syncthing not set up yet?); skipping"
    return
  fi
  # illinikey reads its seed + HOTP counter from ~/.cache (synced copies).
  mkdir -p "$HOME/.cache"
  local f
  for f in illinikey.json illinikey_counter.json; do
    if [ -e "$SECRETS_DIR/illinikey/$f" ]; then
      ln -sfn "$SECRETS_DIR/illinikey/$f" "$HOME/.cache/$f"
    fi
  done
  # passhole reads its db/key path from ~/.config/passhole.ini (a tracked
  # dotfile pointing directly at $SECRETS_DIR/passhole), so no link needed.

  # autojump weight file (plain text; low-stakes, tolerates the odd conflict).
  if [ -e "$SECRETS_DIR/autojump/autojump.txt" ]; then
    mkdir -p "$HOME/.local/share/autojump"
    ln -sfn "$SECRETS_DIR/autojump/autojump.txt" "$HOME/.local/share/autojump/autojump.txt"
  fi

  # ssh client config + identity keys (whatever is curated into secrets/ssh).
  # Per-host known_hosts/authorized_keys/agent stay local and are NOT linked.
  if [ -d "$SECRETS_DIR/ssh" ]; then
    mkdir -p "$HOME/.ssh"; chmod 700 "$HOME/.ssh"
    local s
    for s in "$SECRETS_DIR/ssh/"*; do
      [ -e "$s" ] && ln -sfn "$s" "$HOME/.ssh/$(basename "$s")"
    done
  fi
}

# ----------------------------------------------------------------------
# main
# ----------------------------------------------------------------------

main() {
  require_sudo
  make_dirs
  install_apt_packages
  enable_sshd
  install_go
  clone_dotfiles
  overlay_dotfiles
  install_keyboard_conf
  link_secrets
  setup_venv
  install_venv_tools
  install_doom
  install_flox
  install_claude
  install_gomuks
  install_syncthingtui

  info "Done. Log out and back in (or re-source ~/.profile) to pick up PATH changes."
}

main "$@"
