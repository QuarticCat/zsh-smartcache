ZSH_SMARTCACHE_DIR=${ZSH_SMARTCACHE_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/zsh-smartcache}

_smartcache-eval() {
    local cache=$ZSH_SMARTCACHE_DIR/eval-$1; shift
    if [[ ! -f $cache ]] {
        local output=$($@)
        eval $output
        printf '%s' $output >| $cache &!
    } else {
        source $cache
        {
            local output=$($@)
            [[ $output == $(<$cache) ]] && return
            printf '%s' $output >| $cache
            echo "Cache updated: '$@' (applied next time)"
        } &!
    }
}

_smartcache-comp() {
    local cache=$ZSH_SMARTCACHE_DIR/_$1; shift
    if [[ ! -f $cache ]] {
        $@ >| $cache
    } else {
        $@ >| $cache &!
    }
    fpath+=($ZSH_SMARTCACHE_DIR)
}

_smartcache-clear() {
    rm -i $ZSH_SMARTCACHE_DIR/*
}

smartcache() {
    [[ -d $ZSH_SMARTCACHE_DIR ]] || mkdir -p $ZSH_SMARTCACHE_DIR

    local subcommand=$1; shift

    if (( $+commands[base64] )) {
        local cache=${$(base64 <<< $@)%%=#}
    } else {
        echo 'base64 not found' >&2
        return 1
    }

    _smartcache-$subcommand $cache $@
}
