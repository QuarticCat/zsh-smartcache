ZSH_SMARTCACHE_DIR=${ZSH_SMARTCACHE_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/zsh-smartcache}

_smartcache-eval() {
    local cache=$1; shift
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

# Ref: https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/rust/rust.plugin.zsh
_smartcache-comp() {
    local cache=$1; shift
    if [[ ! -f $cache ]] {
        local cmd=$1
        autoload -Uz _$cmd
        typeset -gA _comps
        _comps[$cmd]=_$cmd
    }
    fpath+=($ZSH_SMARTCACHE_DIR)
    $@ > $cache &!
}

_smartcache-clear() {
    rm -i $ZSH_SMARTCACHE_DIR/*
}

smartcache() {
    [[ -d $ZSH_SMARTCACHE_DIR ]] || mkdir -p $ZSH_SMARTCACHE_DIR

    local subcommand=$1; shift

    local cache=''
    if (( $+commands[base64] )) {
        cache=$ZSH_SMARTCACHE_DIR/${$(base64 <<< $@)%%=#}
    } else {
        echo 'base64 not found' >&2
        return 1
    }

    # TODO: do I need to check whether the command exist or not?
    _smartcache-$subcommand $cache $@
}
