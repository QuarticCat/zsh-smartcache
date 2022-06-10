# zsh-fastcache

Zsh plugin to cache command output to improve shell startup time

## What it does

It basically does the same thing as [evalcache](https://github.com/mroth/evalcache), except that

- It will check command output update in the background and notify you.
- It also supports caching completions. (experimental)

## Benchmark

Here are some informal benchmarks from my 3700X on my [.zshrc](https://github.com/QuarticCat/dotfiles/tree/main/zsh).

Benchmarked by `hyperfine 'zsh -ic exit'` and comparing the differences.

| command | version | raw eval | zsh-fastcache | evalcache |
| :-----: | :-----: | -------: | ------------: | --------: |
| `rbenv init` | 1.2.0 | ~48ms | ~23.5ms | ~23.5ms |
| `hub alias` | 2.14.2 | ~2.5ms | ~1.5ms | ~1.5ms |
| `scmpuff init` | 0.5.0 | ~2.5ms | ~2ms | ~2ms |

Some changes from evalcache's results:

- Only the subsequent runs are recorded. The first run has a fixed extra cost (~1ms) on the MD5 hash computation.
- `rbenv init`'s speedup are much lower, since the command output now includes `rbenv` calls, which are super slow.
- `hub alias` and `scmpuff init` are superfast now.

## Installation

## Usage

## Configuration

- `ZSH_FASTCACHE_DIR`: cache files storage, default to `${XDG_CACHE_HOME:-$HOME/.cache}/zsh-fastcache`.
