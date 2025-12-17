if status is-interactive
	starship init fish | source
end

set -g fish_greeting

alias ls="lsd"
alias wal-update="~/wal-update.sh"
alias udb="sudo rm -rf /var/lib/pacman/db.lck"