if status is-interactive
	starship init fish | source
end

fastfetch

set -g fish_greeting

alias ls="lsd"
alias pacman="paru"
alias yay="paru"
alias udb="sudo rm -rf /var/lib/pacman/db.lck"
