# macOS 환경 설정

이 저장소는 새 macOS 환경을 Homebrew, dotfiles, Git/SSH 설정으로 구성하기 위한 개인용 bootstrap 설정입니다. `Brewfile`에는 설치할 패키지를 선언하고, `assets`에는 배포할 설정 파일을 보관하며, `setup.sh`가 초기 설치를 수행합니다.

## 구성

```text
.
├── Brewfile                 # Homebrew formula, cask, MAS 앱, VS Code 확장 목록
├── setup.sh                 # 최초 환경 구성 스크립트
├── .env.example             # 개인별 환경 변수 템플릿
├── .env                     # 개인별 실제 환경 변수(.gitignore 대상)
├── assets/
│   ├── .zshrc               # Zsh 설정
│   └── .config/             # Neovim 등 XDG 설정
└── .gitignore
```

## 수행 작업

`setup.sh`는 다음 작업을 순서대로 수행합니다.

1. Homebrew를 설치합니다.
2. `Brewfile`의 CLI 도구, GUI 앱, Mac App Store 앱, VS Code 확장을 설치합니다.
3. iCloud Drive를 가리키는 `~/iCloud` 심볼릭 링크를 생성합니다.
4. Oh My Zsh와 Powerlevel10k를 설치합니다.
5. `assets/.config`와 `assets/.zshrc`를 홈 디렉터리에 배포합니다.
6. 개인 Git identity, GitHub SSH host alias, Git URL rewrite 및 conditional include를 설정합니다.

## 사전 준비

- macOS와 인터넷 연결이 필요합니다.
- Homebrew 설치 중 관리자 암호를 요구할 수 있습니다.
- `mas` 항목을 설치하려면 Mac App Store에 로그인되어 있어야 합니다.
- Bitwarden SSH agent를 사용할 경우 Bitwarden 앱과 SSH agent를 설정해야 합니다.
- 기존 `~/.zshrc`, `~/.ssh/config`, `~/.gitconfig`를 사용 중이라면 실행 전에 백업하세요.

> [!WARNING]
> 현재 `setup.sh`는 최초 설치를 위한 스크립트입니다. 이미 구성된 Mac에서 반복 실행할 경우 기존 링크, Zsh 설정, Powerlevel10k 디렉터리 등과 충돌할 수 있습니다. 실행 전 스크립트 내용을 검토하고 필요한 파일을 백업하세요.

## 설치 방법

### 1. 저장소를 복제하고 루트로 이동

```bash
git clone <repository-url> "$HOME/.config/homebrew"
cd "$HOME/.config/homebrew"
```

> [!IMPORTANT]
> 현재 `setup.sh`의 `brew bundle install`은 실행 중인 디렉터리에서 `Brewfile`을 찾습니다. 반드시 저장소 루트에서 실행하세요.

### 2. 환경 변수 파일 생성

템플릿을 복사한 뒤 본인 환경에 맞게 수정합니다.

```bash
cp .env.example .env
chmod 600 .env
vi .env
```

`.env`는 `.gitignore`에 포함되어 Git에 커밋되지 않습니다.

```bash
# Git 및 SSH
GITHUB_HOST="github.com"
GIT_SSH_HOST_ALIAS="github.com-home"
GITHUB_HOME_ACCOUNT="your-github-account"
GIT_NAME="Your Name"
GIT_EMAIL="you@example.com"

SSH_CONFIG="$HOME/.ssh/config"
SSH_IDENTITY_AGENT="$HOME/.bitwarden-ssh-agent.sock"
SSH_IDENTITY_FILE="$HOME/.ssh/bitwarden/github.com_example.pub"

# macOS 및 개발 도구 경로
ICLOUD_SOURCE="$HOME/Library/Mobile Documents/com~apple~CloudDocs"
ICLOUD_LINK="$HOME/iCloud"
OH_MY_ZSH_DIR="${ZSH:-$HOME/.oh-my-zsh}"
POWERLEVEL10K_DIR="${ZSH_CUSTOM:-$OH_MY_ZSH_DIR/custom}/themes/powerlevel10k"

# dotfiles 및 Git config 경로
DOTFILES_SOURCE="$REPO_ROOT/assets/.config"
DOTFILES_TARGET="$HOME/.config"
ZSHRC_SOURCE="$REPO_ROOT/assets/.zshrc"
ZSHRC_TARGET="$HOME/.zshrc"
ZSHRC_BACKUP="$HOME/.zshrc.bak"
GIT_CONFIG="${GIT_CONFIG:-$HOME/.gitconfig}"
GIT_HOME_CONFIG="$DOTFILES_TARGET/git/.gitconfig-home"
```

`.env`는 `REPO_ROOT`를 계산한 뒤 `setup.sh`에서 불러오므로, 템플릿에 있는 `$REPO_ROOT` 기반 경로를 그대로 사용할 수 있습니다.

| 변수 | 설명 |
| --- | --- |
| `GITHUB_HOST` | GitHub 호스트 이름입니다. |
| `GIT_SSH_HOST_ALIAS` | `~/.ssh/config`에 생성할 GitHub SSH host alias입니다. |
| `GITHUB_HOME_ACCOUNT` | 개인 GitHub 계정 또는 namespace입니다. |
| `GIT_NAME` / `GIT_EMAIL` | 개인 Git 사용자 이름과 이메일입니다. |
| `SSH_CONFIG` | SSH config 파일 경로입니다. |
| `SSH_IDENTITY_AGENT` / `SSH_IDENTITY_FILE` | SSH agent socket 및 GitHub 공개키 경로입니다. |
| `ICLOUD_SOURCE` / `ICLOUD_LINK` | iCloud Drive 원본과 생성할 심볼릭 링크 경로입니다. |
| `OH_MY_ZSH_DIR` / `POWERLEVEL10K_DIR` | Oh My Zsh와 Powerlevel10k 설치 경로입니다. |
| `DOTFILES_SOURCE` / `DOTFILES_TARGET` | `.config` hard link 동기화의 원본과 대상 경로입니다. |
| `ZSHRC_SOURCE` / `ZSHRC_TARGET` / `ZSHRC_BACKUP` | `.zshrc` 원본·대상·백업 경로입니다. |
| `GIT_CONFIG` / `GIT_HOME_CONFIG` | 전역 Git config와 생성할 개인 Git config 경로입니다. |

개인키, GitHub Personal Access Token, Bitwarden access token, 비밀번호, 복구 코드는 이 파일이나 저장소에 저장하지 마세요.

### 3. 설치 실행

```bash
./setup.sh
```

실행 권한이 없는 경우에는 다음처럼 실행할 수 있습니다.

```bash
bash setup.sh
```

## 설치 후 확인

패키지 선언과 현재 설치 상태를 비교합니다.

```bash
brew bundle check --file Brewfile
```

필요한 Homebrew 패키지만 다시 설치하려면 전체 bootstrap 대신 다음 명령을 사용합니다.

```bash
brew bundle install --file Brewfile
```

개인 환경 변수 파일이 무시되는지도 확인할 수 있습니다.

```bash
git check-ignore -v .env
```

Git conditional include와 SSH host 설정은 다음 명령으로 확인합니다.

```bash
git config --show-origin --get-regexp '^includeIf'
ssh -G github.com-home
```

## 설정 업데이트

- 패키지, 앱, VS Code 확장은 `Brewfile`에서 관리합니다.
- Zsh 및 XDG 설정의 원본은 `assets` 디렉터리입니다.
- 개인별 Git/SSH 값은 `.env`에서만 관리합니다.
- `.env`를 수정했으면 Git에 추가하지 마세요.

> [!NOTE]
> `.config` 배포는 `rsync -a --link-dest=assets/.config`를 사용합니다. 새로 배포하거나 갱신하는 파일은 `assets/.config`의 같은 파일과 hard link를 공유하며, 재실행 시 이미 동일한 파일을 복사해 발생하던 오류가 없습니다. 대상에만 있는 파일은 삭제하지 않습니다. `~/.zshrc`도 hard link로 배포합니다.

## 문제 해결

### `brew: command not found`

Homebrew 설치 직후 PATH가 설정되지 않은 경우가 있습니다. Homebrew installer가 출력한 안내를 우선 따르세요. 일반적으로 Apple Silicon Mac에서는 다음 명령이 필요할 수 있습니다.

```bash
eval "$(/opt/homebrew/bin/brew shellenv)"
```

Intel Mac에서는 Homebrew 경로가 `/usr/local/bin/brew`일 수 있습니다.

### Mac App Store 앱 설치 실패

`mas` 항목은 App Store 로그인 상태에 따라 실패할 수 있습니다. App Store에 로그인한 뒤 다음을 다시 실행하세요.

```bash
brew bundle install --file Brewfile
```

### SSH 인증 실패

먼저 Bitwarden SSH agent socket이 존재하는지 확인합니다.

```bash
test -S "$SSH_IDENTITY_AGENT" && echo "SSH agent is available"
```

이 명령은 현재 셸에 `SSH_IDENTITY_AGENT`가 설정되어 있을 때만 사용할 수 있습니다. 설정 파일의 값을 직접 확인하거나, Bitwarden SSH agent가 실행 중인지 확인하세요.

## 보안 및 운영 원칙

- `.env`는 개인별 경로와 identity를 위한 파일이지 비밀 저장소가 아닙니다.
- 원격 installer와 Git repository에서 코드를 내려받아 실행하므로, 실행 전에 `setup.sh`, `Brewfile`의 변경 사항을 검토하세요.
- 이 저장소를 다른 사용자 또는 다른 GitHub 계정에서도 사용할 계획이라면 `.env.example`만 공유하고 `.env`는 새로 만드세요.
