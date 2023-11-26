#!/bin/zsh
ZSH_SMARTCACHE_DIR=${ZSH_SMARTCACHE_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/zsh-smartcache}


_smartcache-eval() {
    local cache=$1; shift
    if [[ ! -f $cache ]]; then
        local output=$("$@")
        eval "$output"
        printf '%s' "$output" >| "$cache" &!
    else
        source "$cache"
        (
            local new_output=$("$@")
            local cached_output=$(<"$cache")

            if [[ $new_output != "$cached_output" ]]; then
                # Update cache with new output
                printf '%s' "$new_output" >| "$cache" &!
                echo "Cache updated: '$@' (will be applied next time)"
            fi
        ) &!
    fi
}


# Ref: https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/rust/rust.plugin.zsh
_smartcache-comp() {
    local cache=$1; shift
    filename=${cache:t}
    modified_cache="${cache/$filename/_$filename}"
    $@ > $modified_cache &!
}

_smartcache-clear() {
    rm -i $ZSH_SMARTCACHE_DIR/*
}

smartcache() {
    [[ -d $ZSH_SMARTCACHE_DIR ]] || mkdir -p $ZSH_SMARTCACHE_DIR

    local subcommand=$1; shift

    # TODO: subshell costs extra 1ms, so find a built-in method to substitute it.
    local cache=''
    if (( $+commands[md5] )) {
        cache=$ZSH_SMARTCACHE_DIR/$(md5 <<< $@)
    } elif (( $+commands[md5sum] )) {
        cache=$(md5sum <<< $@)
        cache=$ZSH_SMARTCACHE_DIR/${cache:0:32}
    } else {
        echo 'MD5 hash program not found!' >&2
        return 1
    }

    # TODO: do I need to check whether the command exist or not?
    _smartcache-$subcommand $cache $@
}
