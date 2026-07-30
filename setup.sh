#!/usr/bin/env bash

set -Eeuo pipefail

print_step() {
  local step="$1"

  printf '\n\033[0;32m%s\033[0m\n' '=========================================================='
  printf '\033[0;32m%s\033[0m\n' "$step"
  printf '\033[0;32m%s\033[0m\n' '=========================================================='
}

readonly REPO_ROOT="$(
  CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P
)"
readonly ENV_FILE="$REPO_ROOT/.env"

print_step "[0/6] 환경 변수 확인"

if [[ -f "$ENV_FILE" ]]; then
  source "$ENV_FILE"
fi

: "${GITHUB_HOST:?.env에 GITHUB_HOST를 설정하세요.}"
: "${GIT_SSH_HOST_ALIAS:?.env에 GIT_SSH_HOST_ALIAS를 설정하세요.}"
: "${GITHUB_HOME_ACCOUNT:?.env에 GITHUB_HOME_ACCOUNT를 설정하세요.}"
: "${GIT_NAME:?.env에 GIT_NAME을 설정하세요.}"
: "${GIT_EMAIL:?.env에 GIT_EMAIL을 설정하세요.}"
: "${SSH_CONFIG:?.env에 SSH_CONFIG를 설정하세요.}"
: "${SSH_IDENTITY_AGENT:?.env에 SSH_IDENTITY_AGENT를 설정하세요.}"
: "${SSH_IDENTITY_FILE:?.env에 SSH_IDENTITY_FILE을 설정하세요.}"
: "${ICLOUD_SOURCE:?.env에 ICLOUD_SOURCE를 설정하세요.}"
: "${ICLOUD_LINK:?.env에 ICLOUD_LINK를 설정하세요.}"
: "${OH_MY_ZSH_DIR:?.env에 OH_MY_ZSH_DIR을 설정하세요.}"
: "${POWERLEVEL10K_DIR:?.env에 POWERLEVEL10K_DIR을 설정하세요.}"
: "${DOTFILES_SOURCE:?.env에 DOTFILES_SOURCE를 설정하세요.}"
: "${DOTFILES_TARGET:?.env에 DOTFILES_TARGET을 설정하세요.}"
: "${ZSHRC_SOURCE:?.env에 ZSHRC_SOURCE를 설정하세요.}"
: "${ZSHRC_TARGET:?.env에 ZSHRC_TARGET을 설정하세요.}"
: "${ZSHRC_BACKUP:?.env에 ZSHRC_BACKUP을 설정하세요.}"
: "${GIT_CONFIG:?.env에 GIT_CONFIG를 설정하세요.}"
: "${GIT_HOME_CONFIG:?.env에 GIT_HOME_CONFIG를 설정하세요.}"

print_step "[1/6] Homebrew 설치"
# 1. Homebrew 설치
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

print_step "[2/6] Brew bundle 패키지 설치"
# 2. Brewbundle 일괄 설치
brew bundle install

print_step "[3/6] iCloud 심볼릭 링크 생성"
# 3. iCloud 심볼릭 링크 지정
if [[ -L "$ICLOUD_LINK" ]]; then
  printf '%s\n' "이미 존재함: $ICLOUD_LINK"
elif [[ -e "$ICLOUD_LINK" ]]; then
  printf '%s\n' "충돌: $ICLOUD_LINK가 링크가 아닌 파일 또는 디렉터리입니다." >&2
  exit 1
else
  ln -s "$ICLOUD_SOURCE" "$ICLOUD_LINK"
fi

print_step "[4/6] Zsh 환경 설정"
# ~/.zshrc configuration 설정
if [[ -d "$OH_MY_ZSH_DIR" ]]; then
  printf '%s\n' "이미 존재함: Oh My Zsh ($OH_MY_ZSH_DIR)"
elif [[ -e "$OH_MY_ZSH_DIR" || -L "$OH_MY_ZSH_DIR" ]]; then
  printf '%s\n' "충돌: $OH_MY_ZSH_DIR가 디렉터리가 아닙니다." >&2
  exit 1
else
  ZSH="$OH_MY_ZSH_DIR" sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
fi

if [[ -d "$POWERLEVEL10K_DIR" ]]; then
  printf '%s\n' "이미 존재함: Powerlevel10k ($POWERLEVEL10K_DIR)"
elif [[ -e "$POWERLEVEL10K_DIR" || -L "$POWERLEVEL10K_DIR" ]]; then
  printf '%s\n' "충돌: $POWERLEVEL10K_DIR가 디렉터리가 아닙니다." >&2
  exit 1
else
  mkdir -p "$(dirname "$POWERLEVEL10K_DIR")"
  git clone --depth=1 \
    https://github.com/romkatv/powerlevel10k.git \
    "$POWERLEVEL10K_DIR"
fi

print_step "[5/6] dotfiles 배포"
mkdir -p "$DOTFILES_TARGET"
rsync -a --link-dest="$DOTFILES_SOURCE" "$DOTFILES_SOURCE/" "$DOTFILES_TARGET/"
printf '%s\n' "hard link 동기화 완료: $DOTFILES_TARGET"

if [[ -e "$ZSHRC_TARGET" || -L "$ZSHRC_TARGET" ]]; then
  if [[ "$ZSHRC_SOURCE" -ef "$ZSHRC_TARGET" ]]; then
    printf '%s\n' "이미 hard link됨: $ZSHRC_TARGET"
  else
    mv "$ZSHRC_TARGET" "$ZSHRC_BACKUP"
    cp -lp "$ZSHRC_SOURCE" "$ZSHRC_TARGET"
  fi
else
  cp -lp "$ZSHRC_SOURCE" "$ZSHRC_TARGET"
fi

print_step "[6/6] Git 및 SSH 설정"
# Git User 설정
mkdir -p "$(dirname "$SSH_CONFIG")"
git config --global url."git@$GIT_SSH_HOST_ALIAS:$GITHUB_HOME_ACCOUNT/".insteadOf "git@$GITHUB_HOST:$GITHUB_HOME_ACCOUNT/"

if command grep -Fqx "Host $GIT_SSH_HOST_ALIAS" "$SSH_CONFIG"; then
    printf "이미 존재함: Host $GIT_SSH_HOST_ALIAS"
else
    [[ -s "$SSH_CONFIG" ]] && printf '\n' >>"$SSH_CONFIG"

    printf '%s\n' \
        "Host $GIT_SSH_HOST_ALIAS" \
        "    HostName $GITHUB_HOST" \
        '    User git' \
        "    IdentityAgent $SSH_IDENTITY_AGENT" \
        "    IdentityFile $SSH_IDENTITY_FILE" \
        '    IdentitiesOnly yes' >>"$SSH_CONFIG"

    printf "추가 완료: $SSH_CONFIG"
fi

line1="[includeIf \"hasconfig:remote.*.url:git@$GIT_SSH_HOST_ALIAS:**/**\"]"
line2="[includeIf \"hasconfig:remote.*.url:git@$GITHUB_HOST:$GITHUB_HOME_ACCOUNT/**\"]"
path_line="    path = $GIT_HOME_CONFIG"

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

mkdir -p "$(dirname "$GIT_HOME_CONFIG")"
cat <<EOF >"$GIT_HOME_CONFIG"
[user]
    name = $GIT_NAME
    email = $GIT_EMAIL
EOF

print_step "설치 완료"
