#!/bin/bash

# 1. Homebrew 설치
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. Brewbundle 일괄 설치
brew bundle install

# 3. iCloud 심볼릭 링크 지정
ln -s /Users/$(whoami)/Library/Mobile\ Documents/com\~apple\~CloudDocs iCloud

# ~/.zshrc configuration 설정
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

cp -Rlp assets/.config/. ~/.config/

mv ~/.zshrc ~/.zshrc.bak
cp -lp assets/.zshrc ~/.zshrc
