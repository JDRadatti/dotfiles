# dotfiles
A compilation of important configuration files.


## Install

1. Install stow with `brew install stow` or `sudo apt install stow`.
2. Clone the repository and symlink with stow.
```sh
git clone https://github.com/JDRadatti/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
stow --target="$HOME" .
```

## Additional Installations

1. xcode tools: `xcode-select --install`
2. homebrew
3. neovim: `brew install neovim`
4. ripgrep: `brew install ripgrep`
5. node, go, zig, rust
6. rust-analyzer: `rustup component add rust-analyzer`
