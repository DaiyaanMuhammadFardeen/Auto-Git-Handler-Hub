#!/bin/bash

# Source themes path in cache
CACHE_THEMES_DIR="$HOME/.cache/aghh/Themes"
DIALOG_RC="$HOME/.dialogrc"

# Copy Themes to cache if not already done
SOURCE_THEMES_DIR="$(dirname "$0")/Themes"
if [ ! -d "$CACHE_THEMES_DIR" ]; then
    mkdir -p "$CACHE_THEMES_DIR"
    cp -r "$SOURCE_THEMES_DIR/"* "$CACHE_THEMES_DIR/"
fi

# List all available themes dynamically
THEME_OPTIONS=()
i=1
for theme in "$CACHE_THEMES_DIR"/*; do
    if [ -d "$theme" ]; then
        name=$(basename "$theme")
        selected="off"
        [ $i -eq 1 ] && selected="on"
        THEME_OPTIONS+=("$name" "" "$selected")
        ((i++))
    fi
done

# Show radiolist to pick a theme
SELECTED_THEME=$(dialog --clear \
    --title "Select a Theme" \
    --radiolist "Available themes:" 20 60 10 \
    "${THEME_OPTIONS[@]}" \
    3>&1 1>&2 2>&3)

clear

if [ -n "$SELECTED_THEME" ]; then
    THEME_FILE="$CACHE_THEMES_DIR/$SELECTED_THEME/.dialogrc"

    if [ -f "$THEME_FILE" ]; then
        # Remove old symlink if exists
        [ -L "$DIALOG_RC" ] && rm "$DIALOG_RC"

        # Create absolute symlink
        ln -s "$THEME_FILE" "$DIALOG_RC"

        # Inform user
        dialog --msgbox "Theme '$SELECTED_THEME' applied successfully!" 8 50
        clear
    else
        dialog --msgbox "Error: .dialogrc not found for theme '$SELECTED_THEME'" 8 50
        clear
    fi
fi

