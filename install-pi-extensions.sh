#!/bin/sh
# Extensions live directly under .pi via npm prefix
EXT_DIR="$HOME/.pi"
mkdir -p "$EXT_DIR"
# Tell npm to install packages into .pi
export npm_config_prefix="$EXT_DIR"
export PATH="$EXT_DIR/bin:$PATH"

# Use arguments if provided, otherwise fall back to the EXTENSIONS env var
if [ $# -eq 0 ] && [ -n "$EXTENSIONS" ]; then
  set -- $EXTENSIONS
fi
for ext in "$@"; do
    # Check if extension is already installed via pi list
    if pi list 2>/dev/null | grep -q "$ext"; then
        continue
    fi

    echo "Installing extension: $ext"
    pi install "$ext" || true
done

exec pi
