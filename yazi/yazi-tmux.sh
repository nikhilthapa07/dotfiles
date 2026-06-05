#!/usr/bin/env bash

dir="$(basename "$PWD")"

if [ -n "$TMUX" ]; then
    tmux has-session -t "$dir" 2>/dev/null || \
        tmux new-session -d -s "$dir" -c "$PWD"

    tmux switch-client -t "$dir"
else
    exec tmux new-session -A -s "$dir" -c "$PWD"
fi
