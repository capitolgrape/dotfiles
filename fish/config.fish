if status is-interactive
    set -g fish_greeting ""

    if type -q zoxide
        zoxide init fish | source
    end

    if type -q starship
        starship init fish | source
    end

    if type -q eza
        alias ls 'eza --icons --git --group-directories-first'
        alias tree 'eza --icons --git --tree --group-directories-first'
    end

    alias cp 'cp -iv'
    alias mv 'mv -iv'
    alias mkdir 'mkdir -pv'
    alias rm 'rm -I --preserve-root'

    alias ga 'git add'
    alias gc 'git commit'
    alias gp 'git push'
    alias gs 'git status'
    alias gd 'git diff'
    alias gl 'git log --oneline'
    alias gll 'git log'
    alias gpl 'git pull'
    alias gf 'git fetch'

    if type -q gh
        alias ghcr 'gh repo create'
        alias ghcl 'gh repo clone'
        alias ghrf 'gh repo fork'
        alias ghpr 'gh pr create'
        alias ghprl 'gh pr list'
        alias ghprs 'gh pr status'
        alias ghprc 'gh pr checkout'
        alias ghprm 'gh pr merge'
        alias ghi 'gh issue create'
        alias ghic 'gh issue close'
        alias ghil 'gh issue list'
    end
end
