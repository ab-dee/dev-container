#!/usr/bin/env bash
set -euo pipefail

apt-get update
apt-get install -y --no-install-recommends \
    git curl ca-certificates build-essential x11-apps zsh \
    openssh-client openssh-server
rm -rf /var/lib/apt/lists/*

# uv
curl -LsSf https://astral.sh/uv/install.sh | bash

# oh-my-zsh (skip if already installed)
if [ ! -d "${HOME}/.oh-my-zsh" ]; then
    RUNZSH=no CHSH=no bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

ZSH_CUSTOM="${HOME}/.oh-my-zsh/custom"

[ -d "${ZSH_CUSTOM}/plugins/zsh-autosuggestions" ] || \
    git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions \
        "${ZSH_CUSTOM}/plugins/zsh-autosuggestions"

[ -d "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting" ] || \
    git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting \
        "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting"

sed -i 's/^plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' "${HOME}/.zshrc"

chsh -s /usr/bin/zsh root || true

# Claude Code
npm install -g @anthropic-ai/claude-code

# OpenCode
curl -fsSL https://opencode.ai/install | bash

# Ensure ~/.local/bin, npm global bin, and ~/.opencode/bin are on PATH for zsh and bash
NPM_GLOBAL_BIN="$(npm config get prefix 2>/dev/null || echo /usr/local)/bin"
PATH_EXPORT_LINE="export PATH=\"\$HOME/.local/bin:${NPM_GLOBAL_BIN}:\$HOME/.opencode/bin:\$PATH\""

grep -qF '.opencode/bin' "${HOME}/.zshrc" 2>/dev/null || \
    printf '\n%s\n' "${PATH_EXPORT_LINE}" >> "${HOME}/.zshrc"

grep -qF '.opencode/bin' "${HOME}/.bashrc" 2>/dev/null || \
    printf '\n%s\n' "${PATH_EXPORT_LINE}" >> "${HOME}/.bashrc"

echo "Setup complete. Run 'exec zsh' (or open a new shell) to pick up PATH changes."