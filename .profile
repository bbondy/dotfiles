# Stops recursion: this and ~/.bashrc source each other
[ -n "${_DOTFILES_PROFILE:-}" ] && return
_DOTFILES_PROFILE=1

# Login bash doesn't read ~/.bashrc, so load it unless it's what sourced this
if [ -n "$BASH_VERSION" ] && [ -f ~/.bashrc ]; then
    case " ${BASH_SOURCE[*]} " in
        *"/.bashrc "*) ;;
        *) . ~/.bashrc ;;
    esac
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

# `=() {` is a parse error in zsh (process substitution syntax)
function = {
    echo "$@" | bc
}

alias l="ls"
alias python='python3'

# Update patches
alias up="pnpm run sync --run_hooks"

# Build Chromium
alias b="pnpm run build"
alias br="pnpm run build Release"
alias basan="pnpm run build --is_asan"

# Start Brave Core
#alias s="pnpm run start --env-leo=staging --env-ai-chat.bsg=dev --env-ai-chat-premium.bsg=dev"
alias s="pnpm run start"
alias sai="pnpm run start --ai-chat-server-url=\"http://0.0.0.0:8000\""
alias so="pnpm run start --enable-features=BraveOrigin"
alias s2="pnpm run start"
alias s-ui="pnpm run start --enable-ui-devtools --enable-features=NativeBraveWallet"

# Clean profile
alias clp="rm -Rf ~/Library/Application\ Support/BraveSoftware/Brave-Browser-Development && rm -Rf ~/Library/Application\ Support/BraveSoftware/Brave-Origin-Development"
alias clbp="rm -Rf ~/Library/Application\ Support/brave-development && rm -Rf ~/Library/Application\ Support/BraveSoftware/Brave-Browser-Beta"

alias create-brave-origin='mkdir -p "$HOME/Library/Application Support/BraveSoftware/Brave-Browser-Development" && echo "{\"is_brave_origin_user\": true}" > "$HOME/Library/Application Support/BraveSoftware/Brave-Browser-Development/brave_origin_state.json" && echo "✅ Brave Origin enabled"'
# Reset Origin startup dialog (clears pref and SKU creds)
alias reset-origin="python3 -c \"
import json, os
p = os.path.expanduser('~/Library/Application Support/BraveSoftware/Brave-Origin-Development/Local State')
with open(p) as f: d = json.load(f)
d.setdefault('brave', {}).setdefault('origin', {})['purchase_validated'] = False
d.pop('skus', None)
with open(p, 'w') as f: json.dump(d, f, indent=3)
print('Reset purchase_validated and cleared skus state')
\""

alias rut="pnpm run test brave_unit_tests"
alias rbt="pnpm run test brave_browser_tests"

alias iax86="pnpm run init --target_os=android --target_arch=x86"
alias iosdev="pnpm run ios_bootstrap --open_xcodeproj"
alias ia="pnpm run init --target_os=android --target_arch=arm"
alias ba="pnpm run build --target_os=android --target_arch=arm"
alias bax86="pnpm run build --target_os=android --target_arch=x86"
alias da="./build/android/adb_install_apk.py out/android_Debug_arm/apks/Bravearm.apk"
alias ta="pnpm run test brave_unit_tests --target_os=android --target_arch=arm"
alias tax86="pnpm run test brave_unit_tests --target_os=android --target_arch=x86"
alias android-monitor="third_party/android_tools/sdk/tools/monitor"
alias avdmanager="third_party/android_tools/sdk/tools/bin/avdmanager"
alias android-studio="/usr/local/android-studio/bin/studio.sh"

fix() {
  local last_cmd=$(fc -ln -1)
  claude --allowedTools "Bash($last_cmd)" -- "I ran \`$last_cmd\` and it failed. Help me fix."
}

cleartitle() {
  printf '\033]0;\007'
}

export PATH="$PATH:$HOME/projects/brave/depot_tools:$HOME/bin"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.local/share/solana/install/active_release/bin:$PATH"
export PATH="$HOME/.local/bin/:$PATH"
export PATH="/usr/local/bin/:$PATH"
export PATH="$PATH:$HOME/projects/brave/brave-browser/src/brave/vendor/depot_tools"
export PATH="$HOME/.opencode/bin:$PATH"

# disk cache
export SCCACHE_CACHE_SIZE=100G     # some of us use 100GB; you can use less if needed
export SCCACHE_DIR="$HOME/sccache" # where the cache is physically stored

# s3 cache
#export SCCACHE_BUCKET=sccache-macos-bucket # bucket must exist and your access key must have read/write perm
#export SCCACHE_ENDPOINT=optional-host:123
#export AWS_ACCESS_KEY_ID=XXX
#export AWS_SECRET_ACCESS_KEY=YYY

export RBE_exec_strategy=racing # do not set for now, there are still bugs to resolve
export RBE_local_resource_fraction=0.5

# zsh completion is set up in .zshrc
if [ -n "$BASH_VERSION" ] && [[ $- == *i* ]]; then
    # Ubuntu's default ~/.bashrc may have loaded it already
    if [ -n "${BASH_COMPLETION_VERSINFO:-}" ]; then
        :
    elif [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
    bind 'set completion-ignore-case on'
    bind 'set show-all-if-ambiguous on'
    shopt -s autocd 2>/dev/null  # bash 4+; macOS ships 3.2
    if type __git_ps1 >/dev/null 2>&1; then
        PS1='\u@\h:\w\[\e[32m\]$(__git_ps1 " (%s)")\[\e[0m\]\$ '
    fi
fi

# Machine-specific/private config, not in the public repo
[ -f ~/.profile.local ] && . ~/.profile.local
unset _DOTFILES_PROFILE
