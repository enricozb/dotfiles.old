# ---------------------- environment ---------------------
set fish_greeting                       # no greeting
set SHELL /usr/bin/fish
set -x VISUAL kak                       # editors
set -x EDITOR kak
set -x GIT_EDITOR kak
set -x TEXMFHOME "$HOME/.texmf"         # latex
set -x XDG_CONFIG_HOME "$HOME/.config"
set -x FZF_DEFAULT_OPTS \
  "--color=16 --reverse \
   --preview 'bat --style=numbers --color=always --line-range :500 {}' \
   --tiebreak=length,end \
   --bind=tab:down,shift-tab:up"        # fzf
set -U FZF_LEGACY_KEYBINDINGS 0

# ------------------------- path -------------------------
set -x PATH "$HOME/.elan/bin" $PATH         # lean
set -x PATH "$HOME/.local/bin/" $PATH       # personal scripts
set -x PATH "$HOME/.mathlib/bin" $PATH      # lean - mathlib
set -x PATH "$HOME/.node_modules/bin" $PATH # node
set -x PATH "$HOME/.poetry/bin" $PATH       # poetry python
set -x PATH "/opt/bin/" $PATH               # manual installs

# ------------------------ aliases -----------------------
alias o="open"
alias l="ls"
alias cp="cp -p"
alias wiki="kak ~/wiki/index.md"
alias gg="lazygit"

# ----------------------- functions ----------------------
function work --description "default tmux session"
  tmux -2 new-session -A -s work
end


function wikifind --description "find wiki files with content"
  switch "$argv"
  case '-w *'
    find -L ~/wiki \
      ! -path "*/node_modules/*" \
      ! -path "*/_target/*" \
      -iname "*.md" \
    | xargs -d '\n' grep --color -ine (echo -n "$argv" | sed -n "s/-w\s*//p")
  case '*'
    find -L ~/wiki \
      ! -path "*/node_modules/*" \
      ! -path "*/_target/*" \
      -iname "*.md" \
    | xargs -d '\n' grep --color -wine $argv
  end
end


function wiki-open --description "wiki filenames fzf"
  set -l file ~/wiki/(find -L ~/wiki \
               ! -path "*/node_modules/*" \
               ! -path "*/_target/*" \
               -iname "*.md" -printf "%P\n" | fzf)
  if [ -n "$file" ]
    kak $file
  end
  commandline -f repaint
end


function config --description "access configs"
  switch $argv
    case i3
      open "$HOME/.config/i3/config"
    case fish
      open "$HOME/.config/fish/config.fish"
    case kak sway
      cd "$HOME/.config/$argv"
    case ""
      set -l file ~/.config/(find -L ~/.config \
                   ! -path "*/lazygit/*/*" \
                   ! -path "*/BraveSoftware/*" \
                   -printf '%P\n' | fzf)
      if [ -n "$file" ]
        open $file
      end
    case "*"
      echo "Unknown arg '$argv'"
  end
end


function projects --description "cd into a project with fzf"
  set -l proj (find ~/wiki/activities/projects -type d -not -path '*/\.*' | fzf)
  if [ -n "$proj" ]
    cd $proj
    commandline -f repaint
    if test -e "pyproject.toml"
      # if a virtual env is set, deactivate before going into a new one
      if set -q VIRTUAL_ENV
        deactivate
      end
      echo -e "\n"(set_color yellow)"Found pyproject.toml"(set_color normal)
      source (poetry env list --full-path | awk '{ print $1 }')/bin/activate.fish
    end
  end
end


# Originally defined in /usr/share/fish/functions/__fish_prepend_sudo.fish @ line 1
# The modification here is so it has a toggling behavior on multiple presses.
function __fish_prepend_sudo -d "Prepend 'sudo ' to the beginning of the current commandline"
    set -l cmd (commandline -po)
    set -l cursor (commandline -C)
    if test "$cmd[1]" != sudo
        commandline -C 0
        commandline -i "sudo "
        commandline -C (math $cursor + 5)
    else
        commandline -r (string sub --start=6 (commandline -p))
        commandline -C -- (math $cursor - 5)
    end
end


function open
  switch (file -b --mime-type $argv[1])
    case 'application/pdf'
      zathura $argv & disown
    case 'text/*' 'inode/x-empty' 'application/octet-stream'
      kak $argv
    case 'video/*'
      mpv --really-quiet $argv & disown
    case 'inode/directory'
      cd $argv
    case '*'
      xdg-open $argv
  end
end


function man -w man -d "man with kak as the pager"
  command kak -e "man $argv[1]"
end


function ezb -d "ssh into main ezb machine"
  command ssh me.ezb.io -p 1749
end


# ----------------------- bindings -----------------------
bind \ep projects
bind \ew wiki-open
bind \cw forward-word
bind \cb backward-kill-word
bind \cs __fish_prepend_sudo
bind \eo __fzf_open
bind \eC config


# ------------------------ source ------------------------
source "$HOME/.opam/opam-init/init.fish" > /dev/null 2> /dev/null or true
