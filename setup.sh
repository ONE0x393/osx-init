#!/usr/bin/env bash

set -Eeuo pipefail

readonly REPO_ROOT="$(
  CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P
)"
LOCAL_CONFIG="$REPO_ROOT/setup.local.sh"

if [[ -f "$LOCAL_CONFIG" ]]; then
  source "$LOCAL_CONFIG"
fi

: "${GIT_NAME:?setup.local.sh에 GIT_NAME을 설정하세요.}"
: "${GIT_EMAIL:?setup.local.sh에 GIT_EMAIL을 설정하세요.}"
: "${GITHUB_HOME_ACCOUNT:?setup.local.sh에 GITHUB_HOME_ACCOUNT 설정하세요.}"


# 1. Homebrew 설치
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. Brewbundle 일괄 설치
brew bundle install

# 3. iCloud 심볼릭 링크 지정
ln -s "$HOME/Library/Mobile\ Documents/com\~apple\~CloudDocs" "$HOME/iCloud"

# ~/.zshrc configuration 설정
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
git clone --depth=1 \
  https://github.com/romkatv/powerlevel10k.git \
  "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"

cp -Rlp "$REPO_ROOT/assets/.config/." "$HOME/.config/"

mv "$HOME/.zshrc" "$HOME/.zshrc.bak"
cp -lp "$REPO_ROOT/assets/.zshrc" "$HOME/.zshrc"

# Git User 설정
SSH_CONFIG="$HOME/.ssh/config"

mkdir -p ~/.ssh
git config --global url."git@github.com-home:$GITHUB_HOME_ACCOUNT/".insteadOf "git@github.com:$GITHUB_HOME_ACCOUNT/"

if command grep -Fqx "Host github.com-home" "$SSH_CONFIG"; then
    printf "이미 존재함: Host github.com-home"
else
    [[ -s "$SSH_CONFIG" ]] && printf '\n' >>"$SSH_CONFIG"

    printf '%s\n' \
        'Host github.com-home' \
        '    HostName github.com' \
        '    User git' \
        "    IdentityAgent $SSH_IDENTITY_AGENT" \
        "    IdentityFile $SSH_IDENTITY_FILE" \
        '    IdentitiesOnly yes' >>"$SSH_CONFIG"

    printf "추가 완료: $SSH_CONFIG"
fi

GIT_CONFIG="${GIT_CONFIG:-$HOME/.gitconfig}"

line1='[includeIf "hasconfig:remote.*.url:git@github.com-home:**/**"]'
line2='[includeIf "hasconfig:remote.*.url:git@github.com:ONE0x393/**"]'
path_line='    path = ~/.config/git/.gitconfig-home'

touch "$GIT_CONFIG"

if command grep -Fqx "$line1" "$GIT_CONFIG" &&
    command grep -Fqx "$line2" "$GIT_CONFIG"; then
    printf "Git include 설정이 이미 존재합니다."
elif command grep -Fq "$line1" "$GIT_CONFIG" ||
    command grep -Fq "$line2" "$GIT_CONFIG"; then
    printf "Git include 설정이 일부만 존재합니다. 수동 확인이 필요합니다."
    exit 1
else
    [[ -s "$GIT_CONFIG" ]] && printf '\n' >>"$GIT_CONFIG"

    printf '%s\n' \
        "$line1" \
        "$path_line" \
        "$line2" \
        "$path_line" >>"$GIT_CONFIG"

    printf "Git include 설정을 추가했습니다."
fi

mkdir -p "$HOME/.config/git"
cat <<EOF >"$HOME/.config/git/.gitconfig-home"
[user]
    name = $GIT_NAME
    email = $GIT_EMAIL
EOF
