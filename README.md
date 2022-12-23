# zsh-smartcache

A Zsh plugin to cache command output to boost shell startup.

## What it does

It basically has the same functionality as [evalcache](https://github.com/mroth/evalcache), except that

- It will automatically update the cache and inform you, while evalcache will never update the cache until you clear them. This operation is done in the background, so it has no effect on the satrtup time.
- It also supports caching completions. (experimental)

## Benchmark

Here are some benchmark results. (CPU: Ryzen 3700X)

Benchmarked by `hyperfine 'zsh -ic exit'` and comparing the differences.

| command | version | raw eval | zsh-smartcache | evalcache |
| :-----: | :-----: | -------: | -------------: | --------: |
| `rbenv init` | 1.2.0 | ~48ms | ~23.5ms | ~23.5ms |
| `hub alias` | 2.14.2 | ~2.5ms | ~1.5ms | ~1.5ms |
| `scmpuff init` | 0.5.0 | ~2.5ms | ~2ms | ~2ms |

Some changes from evalcache's results:

- Only the subsequent runs are recorded. The first run has a fixed extra cost (~1ms) on the MD5 hash computation.
- Speedup of `rbenv init` is much lower, since the command output now includes `rbenv` calls, which are super slow.
- `hub alias` and `scmpuff init` are superfast now.

## Usage

### Eval

```zsh
eval "$(rbenv init -)"
# change to
smartcache eval rbenv init -
```

### Completion

```zsh
rustup completions zsh > ~/.zfunc/_rustup
fpath+=~/.zfunc
# change to
smartcache comp rustup completions zsh
```

## Configuration

- `ZSH_SMARTCACHE_DIR`: cache files storage, default to `${XDG_CACHE_HOME:-$HOME/.cache}/zsh-smartcache`.
