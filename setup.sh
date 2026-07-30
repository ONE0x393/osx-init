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
GIT_USER="Howon Jeong"
GIT_EMAIL="howon2k@me.com"
git config --global url."git@github.com-home:ONE0x393/".insteadOf "git@github.com:ONE0x393/"

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

GIT_CONFIG="${GIT_CONFIG:-$HOME/.gitconfig}"

line1='[includeIf "hasconfig:remote.*.url:git@github.com-home:**/**"]'
line2='[includeIf "hasconfig:remote.*.url:git@github.com:ONE0x393/**"]'
path_line='    path = ~/.config/git/.gitconfig-home'

touch "$GIT_CONFIG"

if command grep -Fqx "$line1" "$GIT_CONFIG" &&
    command grep -Fqx "$line2" "$GIT_CONFIG"; then
    print "Git include 설정이 이미 존재합니다."
elif command grep -Fq "$line1" "$GIT_CONFIG" ||
    command grep -Fq "$line2" "$GIT_CONFIG"; then
    print -u2 "Git include 설정이 일부만 존재합니다. 수동 확인이 필요합니다."
    exit 1
else
    [[ -s "$GIT_CONFIG" ]] && printf '\n' >>"$GIT_CONFIG"

    printf '%s\n' \
        "$line1" \
        "$path_line" \
        "$line2" \
        "$path_line" >>"$GIT_CONFIG"

    print "Git include 설정을 추가했습니다."
fi

mkdir -p "$HOME/.config/git"
cat <<EOF >"$HOME/.config/git/.gitconfig-home"
[user]
    name = $GIT_USER
    email = $GIT_EMAIL
EOF
