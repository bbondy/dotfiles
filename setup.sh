#!/usr/bin/env bash
# Symlinks these dotfiles into $HOME. Settings in existing files that were never
# part of this repo are moved to ~/<file>.local, which each dotfile loads.
set -euo pipefail

repo=$(cd "$(dirname "$0")" && pwd -P)
backup="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
text_files=(.profile .zshrc .vimrc .tmux.conf)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

is_linked() { [ -L "$HOME/$1" ] && [ "$(readlink "$HOME/$1")" = "$repo/$1" ]; }

replace_with_link() {
  if [ -e "$HOME/$1" ] || [ -L "$HOME/$1" ]; then
    mkdir -p "$backup"
    mv "$HOME/$1" "$backup/"
    backed_up=1
  fi
  ln -s "$repo/$1" "$HOME/$1"
  echo "linked  ~/$1"
}

# Every line ever committed to (or currently in) the text dotfiles, plus distro
# defaults from /etc/skel, trimmed. Matching against history means a stale copy
# of the repo isn't mistaken for local changes.
{
  git -C "$repo" log -p --format= --no-color -- "${text_files[@]}" | sed -n '/^+++ /d; s/^+//p'
  (cd "$repo" && cat "${text_files[@]}")
  for f in "${text_files[@]}"; do
    if [ -f "/etc/skel/$f" ]; then cat "/etc/skel/$f"; fi
  done
} | sed 's/^[[:space:]]*//; s/[[:space:]]*$//' > "$tmp/known"

# Lines of $1 not in the known set. Closers and blanks right after a kept line
# are kept too, so extracted if/fi and {…} blocks stay intact.
local_only() {
  awk '
    function trim(s) { sub(/^[ \t]+/, "", s); sub(/[ \t]+$/, "", s); return s }
    NR == FNR { known[$0]; next }
    {
      t = trim($0)
      closer = (t == "" || t ~ /^(fi|done|esac|[}]|else|;;|endif|endfunction|endfor|endwhile)$/)
      if (!(t in known) || (closer && kept)) { print; kept = 1 }
      else if (!closer) kept = 0
    }' "$tmp/known" "$1" | cat -s
}

syntax_ok() {
  case $1 in
    .profile) bash -n "$2" ;;
    .zshrc) ! command -v zsh >/dev/null || zsh -n "$2" ;;
  esac
}

link_text() {
  local f=$1 lines="$tmp/lines" note=""
  if is_linked "$f"; then echo "ok      ~/$f"; return; fi
  if [ -f "$HOME/$f" ]; then
    local_only "$HOME/$f" > "$lines"
    if grep -q '[^[:space:]]' "$lines"; then
      if ! syntax_ok "$f" "$lines" >/dev/null 2>&1; then
        sed 's/^/# /' "$lines" > "$lines.c" && mv "$lines.c" "$lines"
        note=" (commented out: failed syntax check, review by hand)"
      fi
      {
        [ -s "$HOME/$f.local" ] && echo
        echo "# From ~/$f, moved by dotfiles/setup.sh on $(date +%F)"
        cat "$lines"
      } >> "$HOME/$f.local"
      echo "moved   $(grep -c '[^[:space:]]' "$lines") lines from ~/$f to ~/$f.local$note"
    fi
  fi
  replace_with_link "$f"
}

link_gitconfig() {
  local f=.gitconfig
  if is_linked "$f"; then echo "ok      ~/$f"; return; fi
  if [ -f "$HOME/$f" ]; then
    git -C "$repo" log --format=%H -- "$f" | while read -r c; do
      git -C "$repo" show "$c:$f" > "$tmp/gv" 2>/dev/null && git config -f "$tmp/gv" --list || true
    done > "$tmp/gknown"
    git config -f "$repo/$f" --list >> "$tmp/gknown"
    git config -f "$HOME/$f" --list | grep -vxF -f "$tmp/gknown" > "$tmp/gnew" || true
    if [ -s "$tmp/gnew" ]; then
      echo "# From ~/$f, moved by dotfiles/setup.sh on $(date +%F)" >> "$HOME/$f.local"
      while IFS= read -r entry; do
        case $entry in
          *=*) git config -f "$HOME/$f.local" --add -- "${entry%%=*}" "${entry#*=}" ;;
          *) git config -f "$HOME/$f.local" --add -- "$entry" true ;;
        esac
      done < "$tmp/gnew"
      echo "moved   $(wc -l < "$tmp/gnew" | tr -d ' ') settings from ~/$f to ~/$f.local"
    fi
  fi
  replace_with_link "$f"
}

link_dir() {
  local f=$1
  if is_linked "$f"; then echo "ok      ~/$f"; return; fi
  if [ -d "$HOME/$f" ] && ! diff -rq -x .DS_Store "$repo/$f" "$HOME/$f" >/dev/null 2>&1; then
    echo "skipped ~/$f: differs from the repo, merge it by hand"
    return
  fi
  replace_with_link "$f"
}

for f in "${text_files[@]}"; do link_text "$f"; done
link_gitconfig
link_dir .git-templates

loads() { grep -qsE '^[^#]*(\.|source)[[:space:]]+(~|"?\$HOME"?)/\.'"$1"'"?([[:space:];&|]|$)' "$HOME/$2"; }
load_profile_from() {
  printf '\n[ -f ~/.profile ] && . ~/.profile\n' >> "$HOME/$1"
  echo "updated ~/$1 to load ~/.profile"
}

# Non-login bash (e.g. Linux terminal windows) reads only ~/.bashrc
if ! loads profile .bashrc; then load_profile_from .bashrc; fi
# Login bash reads ~/.bash_profile instead of ~/.profile when it exists
if [ -f "$HOME/.bash_profile" ] && ! loads '(profile|bashrc)' .bash_profile; then
  load_profile_from .bash_profile
fi

if [ -n "${backed_up:-}" ]; then echo "Originals saved in $backup"; fi
