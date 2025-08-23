#!/bin/bash
set -e

echo "Starting installation..."

# ------------------------------
# Detect OS and Package Manager
# ------------------------------
OS_TYPE=""
PKG_MANAGER=""

if [[ "$OSTYPE" == "darwin"* ]]; then
    OS_TYPE="macos"
    PKG_MANAGER="brew"
elif [[ -f /etc/os-release ]]; then
    . /etc/os-release
    ID_LOWER=$(echo "$ID" | tr '[:upper:]' '[:lower:]')
    ID_LIKE_LOWER=$(echo "$ID_LIKE" | tr '[:upper:]' '[:lower:]')

    if [[ "$ID_LOWER" == ubuntu || "$ID_LOWER" == debian || "$ID_LIKE_LOWER" == *debian* ]]; then
        OS_TYPE="debian"
        PKG_MANAGER="apt"
    elif [[ "$ID_LOWER" == arch || "$ID_LIKE_LOWER" == *arch* ]]; then
        OS_TYPE="arch"
        PKG_MANAGER="pacman"
    elif [[ "$ID_LOWER" == fedora || "$ID_LOWER" == centos || "$ID_LOWER" == rhel || "$ID_LIKE_LOWER" == *fedora* ]]; then
        OS_TYPE="fedora"
        PKG_MANAGER="dnf"
    elif [[ "$ID_LOWER" == opensuse* || "$ID_LIKE_LOWER" == *suse* ]]; then
        OS_TYPE="opensuse"
        PKG_MANAGER="zypper"
    elif [[ "$ID_LOWER" == alpine || "$ID_LIKE_LOWER" == *alpine* ]]; then
        OS_TYPE="alpine"
        PKG_MANAGER="apk"
    else
        echo "Unsupported Linux distribution: $ID"
        exit 1
    fi
else
    echo "Unsupported OS type: $OSTYPE"
    exit 1
fi

echo "Detected OS: $OS_TYPE, package manager: $PKG_MANAGER"

# ------------------------------
# Install system dependencies
# ------------------------------
install_package() {
    local pkg="$1"
    case "$PKG_MANAGER" in
        apt)
            sudo apt update
            sudo apt install -y "$pkg"
            ;;
        pacman)
            sudo yay -Sy --noconfirm "$pkg"
            ;;
        dnf)
            sudo dnf install -y "$pkg"
            ;;
        zypper)
            sudo zypper install -y "$pkg"
            ;;
        apk)
            sudo apk add "$pkg"
            ;;
        brew)
            brew install "$pkg"
            ;;
        *)
            echo "Unknown package manager: $PKG_MANAGER"
            exit 1
            ;;
    esac
}

# Git
if ! command -v git &>/dev/null; then
    echo "Installing Git..."
    install_package git
else
    echo "Git already installed."
fi

# Dialog
if ! command -v dialog &>/dev/null; then
    echo "Installing dialog..."
    install_package dialog
else
    echo "Dialog already installed."
fi

# Python3
if ! command -v python3 &>/dev/null; then
    echo "Installing Python3..."
    case "$PKG_MANAGER" in
        apt)
            install_package python3 python3-venv python3-dev python3-pip
            ;;
        pacman)
            install_package python
            ;;
        dnf)
            install_package python3 python3-venv python3-devel
            ;;
        zypper)
            install_package python3 python3-venv python3-devel
            ;;
        apk)
            install_package python3 py3-pip py3-virtualenv
            ;;
        brew)
            install_package python
            ;;
    esac
else
    echo "Python3 already installed."
fi

# pip (only for Debian/macOS/Alpine)
if [[ "$PKG_MANAGER" == "apt" || "$PKG_MANAGER" == "brew" || "$PKG_MANAGER" == "apk" ]]; then
    if ! command -v pip3 &>/dev/null; then
        echo "Installing pip..."
        install_package python3-pip
    else
        echo "pip already installed."
    fi
fi

# ------------------------------
# Python package installation
# ------------------------------
echo "Installing Python packages..."
case "$PKG_MANAGER" in
    apt|brew|apk)
        pip3 install --upgrade pip
        pip3 install torch transformers --quiet
        ;;
    pacman)
        install_package python-pytorch
        install_package python-transformers
        ;;
    dnf)
        install_package python3-torch
        install_package python3-transformers
        ;;
    zypper)
        install_package python3-torch
        install_package python3-transformers
        ;;
esac

# ------------------------------
# GitHub CLI
# ------------------------------
if ! command -v gh &>/dev/null; then
    echo "Installing GitHub CLI..."
    case "$PKG_MANAGER" in
        apt)
            type -p curl >/dev/null || sudo apt install curl -y
            curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
            sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
            sudo apt update
            sudo apt install gh -y
            ;;
        pacman)
            install_package github-cli
            ;;
        dnf)
            sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
            sudo dnf install -y gh
            ;;
        zypper)
            sudo zypper addrepo https://cli.github.com/packages/rpm/gh-cli.repo
            sudo zypper install -y gh
            ;;
        apk)
            install_package gh
            ;;
        brew)
            brew install gh
            ;;
    esac
else
    echo "GitHub CLI already installed."
fi

# ------------------------------
# Install aghh executable
# ------------------------------
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
AGHH_SCRIPT="$SCRIPT_DIR/aghh.sh"
AGHH_TARGET="$SCRIPT_DIR/aghh"

if [ -f "$AGHH_SCRIPT" ]; then
    mv "$AGHH_SCRIPT" "$AGHH_TARGET"
    echo "Renamed aghh.sh to aghh"
fi

chmod +x "$AGHH_TARGET"
echo "Made 'aghh' executable."

# Add to PATH if not already present
PROFILE_FILE="$HOME/.bashrc"
if [[ "$SHELL" == *zsh ]]; then
    PROFILE_FILE="$HOME/.zshrc"
fi

if ! echo "$PATH" | grep -q "$SCRIPT_DIR"; then
    echo "Adding Auto-Git-Handler-Hub to PATH..."
    echo "export PATH=\"$SCRIPT_DIR:\$PATH\"" >> "$PROFILE_FILE"
    echo "Please run 'source $PROFILE_FILE' or restart your terminal to use the 'aghh' command."
fi

# ------------------------------
# Verify installation
# ------------------------------
echo ""
echo "Installation complete! Verifying:"
echo "---------------------------------"
echo -n "Git version: "; git --version
echo -n "Dialog version: "; dialog --version
echo -n "Python version: "; python3 --version
if [[ "$PKG_MANAGER" == "apt" || "$PKG_MANAGER" == "brew" || "$PKG_MANAGER" == "apk" ]]; then
    echo -n "pip version: "; pip3 --version
    echo -n "torch version: "; python3 -c "import torch; print(torch.__version__)"
    echo -n "transformers version: "; python3 -c "import transformers; print(transformers.__version__)"
else
    echo "Python modules installed via system package manager"
fi
echo -n "GitHub CLI version: "; gh --version
echo -n "'aghh' path: "; realpath "$AGHH_TARGET"

echo ""
echo "You can now run 'aghh' from any terminal!"
echo "To login to GitHub CLI: run 'gh auth login'"
