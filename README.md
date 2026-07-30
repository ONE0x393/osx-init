# macOS 환경 설정

이 저장소는 새 macOS 환경을 Homebrew, dotfiles, Git/SSH 설정으로 구성하기 위한 개인용 bootstrap 설정입니다. `Brewfile`에는 설치할 패키지를 선언하고, `assets`에는 배포할 설정 파일을 보관하며, `setup.sh`가 초기 설치를 수행합니다.

## 구성

```text
.
├── Brewfile                 # Homebrew formula, cask, MAS 앱, VS Code 확장 목록
├── setup.sh                 # 최초 환경 구성 스크립트
├── setup.local.example.sh   # 개인별 설정 템플릿
├── setup.local.sh           # 개인별 실제 설정(.gitignore 대상)
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

### 2. 개인 설정 파일 생성

템플릿을 복사한 뒤 본인 환경에 맞게 수정합니다.

```bash
cp setup.local.example.sh setup.local.sh
chmod 600 setup.local.sh
vi setup.local.sh
```

`setup.local.sh`은 `.gitignore`에 포함되어 Git에 커밋되지 않습니다.

```bash
GITHUB_HOME_ACCOUNT="your-github-account"
GIT_NAME="Your Name"
GIT_EMAIL="you@example.com"

SSH_IDENTITY_AGENT="$HOME/.bitwarden-ssh-agent.sock"
SSH_IDENTITY_FILE="$HOME/.ssh/bitwarden/github.com_example.pub"
```

| 변수 | 설명 |
| --- | --- |
| `GITHUB_HOME_ACCOUNT` | 개인 GitHub 계정 또는 namespace. Git URL rewrite에 사용됩니다. |
| `GIT_NAME` | 개인 Git 사용자 이름입니다. |
| `GIT_EMAIL` | 개인 Git 이메일 주소입니다. |
| `SSH_IDENTITY_AGENT` | Bitwarden SSH agent Unix socket 경로입니다. |
| `SSH_IDENTITY_FILE` | GitHub용 SSH 공개키(`.pub`) 경로입니다. |

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

개인 설정 파일이 무시되는지도 확인할 수 있습니다.

```bash
git check-ignore -v setup.local.sh
```

Git conditional include와 SSH host 설정은 다음 명령으로 확인합니다.

```bash
git config --show-origin --get-regexp '^includeIf'
ssh -G github.com-home
```

## 설정 업데이트

- 패키지, 앱, VS Code 확장은 `Brewfile`에서 관리합니다.
- Zsh 및 XDG 설정의 원본은 `assets` 디렉터리입니다.
- 개인별 Git/SSH 값은 `setup.local.sh`에서만 관리합니다.
- `setup.local.sh`을 수정했으면 Git에 추가하지 마세요.

> [!NOTE]
> 현재 설정 배포는 `cp -Rlp`를 사용합니다. `-l` 옵션은 파일을 hard link로 배포하므로, 홈 디렉터리의 배포된 설정을 수정하면 저장소의 원본 파일도 같은 inode를 공유해 함께 바뀔 수 있습니다. `assets`를 설정의 기준 원본으로 취급하고, 변경 후 `git status`를 확인하세요.

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

- `setup.local.sh`은 개인별 경로와 identity를 위한 파일이지 비밀 저장소가 아닙니다.
- 원격 installer와 Git repository에서 코드를 내려받아 실행하므로, 실행 전에 `setup.sh`, `Brewfile`의 변경 사항을 검토하세요.
- 이 저장소를 다른 사용자 또는 다른 GitHub 계정에서도 사용할 계획이라면 `setup.local.example.sh`만 공유하고 `setup.local.sh`은 새로 만드세요.
