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

SYNCTHINGTUI_PKG="github.com/evidlo/syncthingtui/cmd/syncthingtui@latest"

# flox ships as a .deb that registers its own apt repo for future upgrades.
# The latest version is resolved at run time from LATEST_VERSION (see install_flox).
FLOX_BASE="https://downloads.flox.dev/by-env/stable"

# Go is installed manually (Debian's package lags too far behind for the go
# tools below). The latest version is resolved at run time (see install_go).
GO_DL="https://go.dev/dl"
GO_PREFIX="/usr/local"        # go lands in $GO_PREFIX/go ; add $GO_PREFIX/go/bin to PATH

RESOURCES="$HOME/resources"
DOTFILES_DIR="$RESOURCES/dotfiles"
GOMUKS_DIR="$RESOURCES/gomuks"
VENV_DIR="$RESOURCES/venv3"

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
  htop
  ncdu
  tree
  tmux
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
  # go is installed manually (see install_go), not via apt.

  # network
  openssh-client
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
  info "Building gomuks (fork)"
  if [ -d "$GOMUKS_DIR/.git" ]; then
    git -C "$GOMUKS_DIR" pull --ff-only
  else
    git clone "$GOMUKS_HTTPS" "$GOMUKS_DIR"
  fi
  git -C "$GOMUKS_DIR" remote set-url --push origin "$GOMUKS_SSH"
  ( cd "$GOMUKS_DIR" && ./build.sh )
  ln -sf ../resources/gomuks/gomuks "$HOME/bin/gomuks"
}

install_syncthingtui() {
  info "Installing syncthingtui"
  go install "$SYNCTHINGTUI_PKG"
}

# ----------------------------------------------------------------------
# main
# ----------------------------------------------------------------------

main() {
  make_dirs
  install_apt_packages
  install_go
  clone_dotfiles
  overlay_dotfiles
  install_keyboard_conf
  setup_venv
  install_flox
  install_claude
  install_gomuks
  install_syncthingtui

  info "Done. Log out and back in (or re-source ~/.profile) to pick up PATH changes."
}

main "$@"
