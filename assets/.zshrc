CONFIG_DIR="$HOME/.config/zsh"

# FASTFETCH
if [[ $- == *i* ]] && command -v fastfetch &>/dev/null; then
  fastfetch
fi

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins
plugins=(
    git
    fzf
)

source $ZSH/oh-my-zsh.sh

# User configuration
export LANG=ko_KR.UTF-8

# IMPORT Alias
[[ -r "$CONFIG_DIR/alias" ]] && source "$CONFIG_DIR/alias"
# IMPORT Coimmands
[[ -r "$CONFIG_DIR/cmds" ]] && source "$CONFIG_DIR/cmds"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
