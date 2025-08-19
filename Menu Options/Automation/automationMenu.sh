#!/bin/bash

CACHE_FILE="$HOME/.cache/aghh/lastRepoUsed.txt"

while true; do
    CHOICE=$(dialog --clear \
        --title "Automation Menu" \
        --menu "Select an automation to run:" 20 70 10 \
        1 "Smart commit all files using GPT2" \
        2 "Git Operations" \
        3 "Back to Main Menu" \
        3>&1 1>&2 2>&3)

    EXIT_STATUS=$?
    clear

    # Exit if cancel pressed or 'Back to Main Menu' chosen
    if [ $EXIT_STATUS -ne 0 ] || [ "$CHOICE" = "6" ]; then
        echo "Returning to main menu..."
        break
    fi

    case $CHOICE in
        1)
            # Read repo path from cache
            if [ -f "$CACHE_FILE" ]; then
                REPO_PATH=$(cat "$CACHE_FILE")
            else
                dialog --msgbox "No last used repository found." 10 50
                continue
            fi

            # Run commitgen.sh with repo path
            OUTPUT=$(bash "$(dirname "$0")/../../commitgen.sh" "$REPO_PATH" 2>&1)

            # Show output in a dialog that auto-exits after 3s
            dialog --title "Smart Commit" --infobox "$OUTPUT" 35 90
            sleep 5
            ;;
        2)
            # Launch git operations script, passing cache file
            bash "$(dirname "$0")/gitMenu.sh" "$CACHE_FILE"
            ;;
    esac
done
