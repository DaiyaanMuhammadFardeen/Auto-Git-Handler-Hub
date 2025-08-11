#!/bin/sh

# Source the global menu map
. ./globals.sh

# Step 1: Run listRepos.sh to select repo
SELECTED_REPO=$(bash ./listRepos.sh)
if [ $? -ne 0 ]; then
    echo "No repo selected. Exiting."
    exit 1
fi

# Show selected repo for 3 seconds
dialog --msgbox "You selected: $SELECTED_REPO" 10 50

# Step 2: Run navbar.sh to show menu and get numeric choice
NAV_CHOICE=$(bash ./navbar.sh)

# Step 3: Clear screen and print the string value associated with the menu number
clear

if [ -n "$NAV_CHOICE" ] && [ -n "${MENU_MAP[$NAV_CHOICE]}" ]; then
    echo "You chose: ${MENU_MAP[$NAV_CHOICE]}"
else
    echo "Invalid or no selection made."
fi
