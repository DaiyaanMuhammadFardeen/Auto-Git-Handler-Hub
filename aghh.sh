#!/bin/bash

# Source global variables + menu map
. "$(dirname "$0")/globals.sh"

# Step 1: Try to read last used repo
if [ -f "$CACHE_FILE" ]; then
    LAST_REPO=$(cat "$CACHE_FILE")
else
    LAST_REPO=""
fi

# Validate last repo (must be a git repo)
if [ -n "$LAST_REPO" ] && [ -d "$LAST_REPO/.git" ]; then
    SELECTED_REPO="$LAST_REPO"
else
    # Run listRepos.sh to pick one
    SELECTED_REPO=$(bash "$(dirname "$0")/Menu Options/listRepos.sh")
    if [ $? -ne 0 ] || [ -z "$SELECTED_REPO" ]; then
        clear
        echo "No repo selected. Exiting."
        exit 1
    fi
    echo "$SELECTED_REPO" > "$CACHE_FILE"
fi

# Show selected repo briefly
dialog --msgbox "Using repository: $SELECTED_REPO" 10 50

# Step 2: Menu loop
while true; do
    NAV_CHOICE=$(bash "$(dirname "$0")/navbar.sh")
    EXITSTATUS=$?

    clear

    if [ -z "$NAV_CHOICE" ] || [ -z "${MENU_MAP[$NAV_CHOICE]}" ]; then
        echo "Invalid or no selection made. Returning to menu..."
        continue
    fi

    # If user chooses Exit
    if [ $EXITSTATUS -ne 0 ] || [ "${MENU_MAP[$NAV_CHOICE]}" = "exit" ]; then
        echo "Exiting program. Goodbye!"
        break
    fi

    SCRIPT_PATH="${MENU_MAP[$NAV_CHOICE]}"
    if [ -f "$SCRIPT_PATH" ]; then
        (cd "$SELECTED_REPO" && bash "$SCRIPT_PATH")
    else
        echo "Script '$SCRIPT_PATH' not found!"
    fi
    clear
done
