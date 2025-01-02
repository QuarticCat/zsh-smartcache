ZSH_SMARTCACHE_DIR=${ZSH_SMARTCACHE_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/zsh-smartcache}

_smartcache-eval() {
    local cache=$ZSH_SMARTCACHE_DIR/eval-$1; shift
    if [[ ! -f $cache ]] {
        local output=$("$@")
        eval $output
        printf '%s' $output >| $cache &!
    } else {
        source $cache
        {
            local output=$("$@")
            [[ $output == "$(<$cache)" ]] && return
            printf '%s' $output >| $cache
            print "Cache updated: '$@' (applied next time)"
        } &!
    }
}

_smartcache-comp() {
    local cache=$ZSH_SMARTCACHE_DIR/_$1; shift
    if [[ ! -f $cache ]] {
        "$@" >| $cache
    } else {
        {
            local output=$("$@")
            [[ $output == "$(<$cache)" ]] && return
            printf '%s' $output >| $cache
            print "Cache updated: '$@' (applied next time)"
        } &!
    }
    # fpath is set unique by default so it's OK to append multiple times.
    fpath+=($ZSH_SMARTCACHE_DIR)
}

smartcache() {
    emulate -LR zsh -o extended_glob -o err_return

    # Doing these lately as users might change settings after plugin loading.
    (( $+commands[base64] )) || base64 --help  # trigger error
    [[ -d $ZSH_SMARTCACHE_DIR ]] || mkdir -p $ZSH_SMARTCACHE_DIR

    local subcmd=$1; shift
    local id=${$(base64 <<< "$@")%%=#}
    _smartcache-$subcmd $id "$@"
}
