#!/usr/bin/env bash
# Installs duploctl. Uses pipx so we work on PEP 668-locked Pythons
# (Ubuntu 24.04 / cimg/base:2026.x and beyond).

PARAM_VERSION=$(circleci env subst "${PARAM_VERSION}")

# Short-circuit if duploctl is already on PATH (e.g. the duplocloud/cimg-base executor
# bakes it in at image build time).
if command -v duploctl &>/dev/null; then
  echo "duploctl already installed"
  duploctl version -o yaml
  exit 0
fi

needs() { ! command -v "$1" &>/dev/null; }

if   [ -x "$(command -v apt-get)" ]; then PM=apt
elif [ -x "$(command -v apk)" ];     then PM=apk
elif [ -x "$(command -v dnf)" ];     then PM=dnf
elif [ -x "$(command -v zypper)" ];  then PM=zypper
else                                      PM=
fi

pkg_install() {
  [ "$#" -eq 0 ] && return 0
  case "$PM" in
    apt)    sudo apt-get update && sudo apt-get install -y "$@" ;;
    apk)    sudo apk add --no-cache "$@" ;;
    dnf)    sudo dnf install -y "$@" ;;
    zypper) sudo zypper install -y "$@" ;;
    *)      echo "FAILED: no supported package manager found. Install manually: $*" >&2; return 1 ;;
  esac
}

# Map a generic dependency name to the manager's package name.
pkg_for() {
  case "$1:$PM" in
    python3:*)                  echo python3 ;;
    pip:apk)                    echo py3-pip ;;
    pip:apt|pip:dnf|pip:zypper) echo python3-pip ;;
    pipx:apt|pipx:dnf)          echo pipx ;;
    pipx:apk)                   echo py3-pipx ;;
    pipx:zypper)                echo python3-pipx ;;
    jq:*)                       echo jq ;;
  esac
}

add_pkg() {
  local p
  p="$(pkg_for "$1")"
  [ -n "$p" ] && packages+=("$p")
}

packages=()
needs python3 && add_pkg python3
needs jq      && add_pkg jq
needs pipx    && add_pkg pipx

pkg_install "${packages[@]}"

# Fallback: bootstrap pipx via pip if the package manager didn't provide it
# (older Alpine, minimal RHEL, etc.). --break-system-packages is the documented
# escape hatch on PEP 668 systems and is safe in ephemeral CI containers.
if ! command -v pipx &>/dev/null; then
  needs pip3 && pkg_install "$(pkg_for pip)"
  python3 -m pip install --user pipx 2>/dev/null \
    || python3 -m pip install --user --break-system-packages pipx
fi

# pipx drops binaries in ~/.local/bin; make sure subsequent steps see them.
PIPX_BIN="${HOME}/.local/bin"
export PATH="${PIPX_BIN}:${PATH}"
echo "export PATH=\"${PIPX_BIN}:\$PATH\"" >> "$BASH_ENV"

if [[ "$PARAM_VERSION" == "latest" ]]; then
  pipx install duplocloud-client
else
  pipx install "duplocloud-client==$PARAM_VERSION"
fi

echo "Successfully installed duploctl"
duploctl version -o yaml
