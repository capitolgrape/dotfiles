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
    abbr -a ff "clear && fastfetch"

    if command -q lsd
        alias ls="lsd --human-readable --literal --group-directories-first --color=auto"
    else
        alias ls="ls --human-readable --literal --group-directories-first --color=auto"
    end

    alias udb="sudo rm -rf /var/lib/pacman/db.lck"
end
