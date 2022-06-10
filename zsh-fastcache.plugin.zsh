ZSH_FASTCACHE_DIR=${XDG_CACHE_HOME:-$HOME/.cache}/zsh-fastcache

_fcache-eval() {
    local cache=$1; shift
    if [[ ! -f $cache ]] {
        local output=$($@)
        eval $output
        echo $output > $cache &!
    } else {
        source $cache
        (
            local output=$($@)
            if [[ $output != $(<$cache) ]] {
                echo $output > $cache
                echo "Cache updated: '$@' (will be applied next time)"
            }
        ) &!
    }
}

# Ref: https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/rust/rust.plugin.zsh
_fcache-comp() {
    local cache=$1; shift
    if [[ ! -f $cache ]] {
        local cmd=$1
        autoload -Uz _$cmd
        typeset -gA _comps
        _comps[$cmd]=_$cmd
    }
    fpath+=($ZSH_FASTCACHE_DIR)
    $@ > $cache &!
}

_fcache-clear() {
    rm -i $ZSH_FASTCACHE_DIR/*
}

fcache() {
    [[ -d $ZSH_FASTCACHE_DIR ]] || mkdir $ZSH_FASTCACHE_DIR

    local subcommand=$1; shift

    # TODO: subshell costs extra 1ms, so find a built-in method to substitute it.
    local cache=''
    if (( $+commands[md5] )) {
        cache=$ZSH_FASTCACHE_DIR/$(md5 <<< $@)
    } elif (( $+commands[md5sum] )) {
        cache=$(md5sum <<< $@)
        cache=$ZSH_FASTCACHE_DIR/${cache:0:32}
    } else {
        echo 'MD5 hash program not found!' >&2
        return 1
    }

    # TODO: do I need to check whether the command exist or not?
    _fcache-$subcommand $cache $@
}
