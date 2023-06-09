#!/bin/sh

# Ensure script path is given
if [ -z "$1" ]; then
    echo "No script path provided"
    exit 1
fi

# Ensure the script exists
if [ ! -f "$1" ]; then
    echo "Script $1 not found"
    exit 1
fi

# The script path is the first parameter
SCRIPT="$1"

# Shift all positional parameters to the left so we can get the remaining arguments
shift

# Run the script with the remaining arguments
elixir "$SCRIPT" "$@"
