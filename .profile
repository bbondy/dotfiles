
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

=() {
    echo "$@" | bc
}

#Updaet patches
alias up="npm run sync -- --run_hooks"

# Build muon
alias bm="npm run build -- --debug_build=true --official_build=false --muon"

# Create dist
alias c="npm run create_dist -- --debug_build=true --official_build=false"

# Build Chromium
alias b="npm run build"
alias br="npm run build -- Release --official_build=false --debug_build=true"
alias brn="npm run build -- Release --official_build=false --debug_build=true --no_branding_update"

# Start Brave Core
alias s="npm run start"

# Build Chromium without branding copy
alias bn="npm run build -- --no_branding_update"

# Clean profile
alias clp="rm -Rf ~/Library/Application\ Support/brave-development && rm -Rf ~/Library/Application\ Support/BraveSoftware/Brave-Browser-Development"

export PATH="$PATH:/Users/bbondy/projects/brave/depot_tools"

export PATH="$HOME/.cargo/bin:$PATH"

alias rut="npm run test brave_unit_tests"
alias rbt="npm run test brave_browser_tests"


# disk cache
export SCCACHE_CACHE_SIZE=100G     # some of us use 100GB; you can use less if needed
export SCCACHE_DIR=~/sccache       # where the cache is physically stored

# s3 cache
#export SCCACHE_BUCKET=sccache-macos-bucket # bucket must exist and your access key must have read/write perm
#export SCCACHE_ENDPOINT=optional-host:123
#export AWS_ACCESS_KEY_ID=XXX
#export AWS_SECRET_ACCESS_KEY=YYY
