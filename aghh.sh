#!/bin/bash

# Source the global menu map
. ./globals.sh

# Step 1: Run listRepos.sh to select repo
SELECTED_REPO=$(bash ./listRepos.sh)
if [ $? -ne 0 ]; then
    clear
    echo "No repo selected. Exiting."
    exit 1
fi

# Show selected repo for 3 seconds
dialog --msgbox "You selected: $SELECTED_REPO" 10 50

while true; do
    # Step 2: Run navbar.sh to show menu and get numeric choice
    NAV_CHOICE=$(bash ./navbar.sh)
    EXITSTATUS=$?  # Capture immediately after dialog in navbar.sh returns

    clear

    if [ -z "$NAV_CHOICE" ] || [ -z "${MENU_MAP[$NAV_CHOICE]}" ]; then
        echo "Invalid or no selection made. Returning to menu..."
        continue
    fi

  # If user chooses Exit (mapped as "exit"), break the loop
  if [ $EXITSTATUS -ne 0 ] || [ "${MENU_MAP[$NAV_CHOICE]}" = "exit" ]; then
      echo "Exiting program. Goodbye!"
      break
  fi

  # Run the mapped script using bash
  SCRIPT_PATH="${MENU_MAP[$NAV_CHOICE]}"
  if [ -f "$SCRIPT_PATH" ]; then
      bash "$SCRIPT_PATH"
  else
      echo "Script '$SCRIPT_PATH' not found!"
  fi
  clear
done

