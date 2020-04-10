# Dotfiles

My personal dotfiles.

## Setup

Log in to LastPass to synchronize SSH keys:

```sh
lpass login
```

Add SSH keys to "SSH Keys" group:

```sh
lpass add --note-type="ssh-key" "SSH Keys/key_name"
```

```sh
DOTFILES_USERNAME=your_name source <(curl -s https://git.io/JUgAx)

git clone https://github.com/martensm/dotfiles ~/dotfiles
~/dotfiles/install.sh
```

> **NOTE:** [https://raw.githubusercontent.com/martensm/dotfiles/master/init.sh](https://raw.githubusercontent.com/martensm/dotfiles/master/init.sh)
> is shortened to [https://git.io/JUgAx](https://git.io/JUgAx),
> so this would also work:
>
> ```sh
> source <(curl -s https://raw.githubusercontent.com/martensm/dotfiles/master/init.sh)
> ```

## License

This project is licensed under the WTFPL - see the [LICENSE](LICENSE) file for details.
