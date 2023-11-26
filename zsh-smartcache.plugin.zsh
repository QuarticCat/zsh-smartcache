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

    # Custom hash function for longer hash-like strings
    local args="$*"
    local hash=$(echo "${args//[^[:alnum:]]/}" | tr -d '\n' | cksum | awk '{print $1}')
    hash+=$(echo "$hash" | fold -w1 | sort | uniq -c | tr -d ' \n')
    hash=${hash:0:32}  # Truncate to desired length

    local cache=$ZSH_SMARTCACHE_DIR/$hash

    # TODO: do I need to check whether the command exist or not?
    _smartcache-$subcommand $cache $@
}

