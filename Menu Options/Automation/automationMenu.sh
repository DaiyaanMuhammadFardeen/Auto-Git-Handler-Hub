#!/bin/bash

# Automation Menu for the selected Git repository

while true; do
    CHOICE=$(dialog --clear \
        --title "Automation Menu" \
        --menu "Select an automation to run:" 20 70 10 \
        1 "Smart commit all files using GPT2" \
        2 "Auto format code" \
        3 "Timed auto push" \
        4 "Auto run tests" \
        5 "Auto Docker Build" \
        6 "Back to Main Menu" \
        3>&1 1>&2 2>&3)

    EXIT_STATUS=$?
    clear

    # Exit if cancel pressed or 'Back to Main Menu' chosen
    if [ $EXIT_STATUS -ne 0 ] || [ "$CHOICE" = "6" ]; then
        echo "Returning to main menu..."
        break
    fi

    case $CHOICE in
        1) echo "Running Smart commit all files using GPT2...";;
        2) echo "Running Auto format code...";;
        3) echo "Running Timed auto push...";;
        4) echo "Running Auto run tests...";;
        5) echo "Running Auto Docker Build...";;
    esac

    read -p "Press Enter to continue..."
done
