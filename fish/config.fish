set -gx BUN_INSTALL "$HOME/.bun"
fish_add_path "$BUN_INSTALL/bin"

if status is-interactive
    set -g fish_greeting

    if command -q starship
        starship init fish | source
    end

    abbr -a g git
    abbr -a ga "git add"
    abbr -a gc "git commit"
    abbr -a gp "git push"

    if command -q lsd
        alias ls="lsd"
    else
        alias ls="ls --color=auto"
    end

    alias wal-update="$HOME/wal-update.sh"
    alias udb="sudo rm -rf /var/lib/pacman/db.lck"
end
