#!/bin/bash

set -xo pipefail

# 1. Homebrew 설치
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. Brewbundle 일괄 설치
brew bundle install

# 3. iCloud 심볼릭 링크 지정
ln -s /Users/$(whoami)/Library/Mobile\ Documents/com\~apple\~CloudDocs ~/iCloud

# ~/.zshrc configuration 설정
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k

cp -Rlp assets/.config/. ~/.config/

mv ~/.zshrc ~/.zshrc.bak
cp -lp assets/.zshrc ~/.zshrc

# Git User 설정
SSH_CONFIG="$HOME/.ssh/config"
git config --global url."git@github.com-home:".insteadOf "git@github.com:one0x393/"
if command grep -Fqx "Host github.com-home" "$SSH_CONFIG"; then
    print "이미 존재함: Host github.com-home"
else
    [[ -s "$SSH_CONFIG" ]] && printf '\n' >>"$SSH_CONFIG"

    printf '%s\n' \
        'Host github.com-home
    HostName github.com
    User git
    IdentityAgent ~/.bitwarden-ssh-agent.sock
    IdentityFile ~/.ssh/bitwarden/github.com_one0x393.pub
    IdentitiesOnly yes' >>"$SSH_CONFIG"

    print "추가 완료: $SSH_CONFIG"
fi
