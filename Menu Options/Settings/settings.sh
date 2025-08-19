#!/bin/bash

# Path for storing settings
SETTINGS_DIR="$HOME/.cache/aghh"
SETTINGS_FILE="$SETTINGS_DIR/settings.conf"

mkdir -p "$SETTINGS_DIR"

# Load existing settings or set defaults
if [ -f "$SETTINGS_FILE" ]; then
    source "$SETTINGS_FILE"
else
    # Default settings
    THEME="Dracula"
    MENU_STYLE="Expanded"
    HIGHLIGHT_COLOR="cyan"
    DIALOG_WIDTH=70
    DIALOG_HEIGHT=20

    DEFAULT_REPO=""
    AUTO_FETCH_INTERVAL=15
    PUSH_PULL_BEHAVIOR="merge"

    AUTO_COMMIT=1
    COMMIT_STYLE="AI-generated"
    TIMED_PUSH=0

    BACKUP_LOCATION="$HOME/.cache/aghh/backups"
    BACKUP_FREQUENCY="weekly"
    EXPORT_COMMITS=0

    VERBOSE_LOG=0
    POPUP_DIALOGS=1
    LOG_FILE="$SETTINGS_DIR/logs.log"

    DEFAULT_EDITOR="nano"
    CONFIRM_DESTRUCTIVE=1
    AUTO_COMPLETION=1

    AI_MODEL="GPT-2"
    AI_SUGGESTIONS=1
    AI_TEMPERATURE=0.7

    SHOW_HIDDEN_FILES=0
    DEFAULT_BRANCH="main"
    COLORIZE_OUTPUT=1
fi

# Helper function to save settings
save_settings() {
    cat > "$SETTINGS_FILE" <<EOL
THEME="$THEME"
MENU_STYLE="$MENU_STYLE"
HIGHLIGHT_COLOR="$HIGHLIGHT_COLOR"
DIALOG_WIDTH=$DIALOG_WIDTH
DIALOG_HEIGHT=$DIALOG_HEIGHT

DEFAULT_REPO="$DEFAULT_REPO"
AUTO_FETCH_INTERVAL=$AUTO_FETCH_INTERVAL
PUSH_PULL_BEHAVIOR="$PUSH_PULL_BEHAVIOR"

AUTO_COMMIT=$AUTO_COMMIT
COMMIT_STYLE="$COMMIT_STYLE"
TIMED_PUSH=$TIMED_PUSH

BACKUP_LOCATION="$BACKUP_LOCATION"
BACKUP_FREQUENCY="$BACKUP_FREQUENCY"
EXPORT_COMMITS=$EXPORT_COMMITS

VERBOSE_LOG=$VERBOSE_LOG
POPUP_DIALOGS=$POPUP_DIALOGS
LOG_FILE="$LOG_FILE"

DEFAULT_EDITOR="$DEFAULT_EDITOR"
CONFIRM_DESTRUCTIVE=$CONFIRM_DESTRUCTIVE
AUTO_COMPLETION=$AUTO_COMPLETION

AI_MODEL="$AI_MODEL"
AI_SUGGESTIONS=$AI_SUGGESTIONS
AI_TEMPERATURE=$AI_TEMPERATURE

SHOW_HIDDEN_FILES=$SHOW_HIDDEN_FILES
DEFAULT_BRANCH="$DEFAULT_BRANCH"
COLORIZE_OUTPUT=$COLORIZE_OUTPUT
EOL
}

# Main Settings Menu
while true; do
    CHOICE=$(dialog --clear \
        --title "Settings Menu" \
        --menu "Select a setting to configure:" 25 70 15 \
        1 "Theming & Appearance" \
        2 "Git & Repo Settings" \
        3 "Automation Preferences" \
        4 "Backup & Export Options" \
        5 "Notifications & Logging" \
        6 "CLI Behavior" \
        7 "AI & Autogeneration Settings" \
        8 "Miscellaneous" \
        9 "Exit" \
        3>&1 1>&2 2>&3)

    EXIT_STATUS=$?
    clear
    [ $EXIT_STATUS -ne 0 ] && break

    case $CHOICE in
        1)  # Theming & Appearance
            # Call the dynamic theme switcher script
            bash "$(dirname "$0")/switch_theme.sh"
            ;;

        2)  # Git & Repo Settings
            DEFAULT_REPO=$(dialog --inputbox "Default repository path:" 10 60 "$DEFAULT_REPO" 3>&1 1>&2 2>&3)
            AUTO_FETCH_INTERVAL=$(dialog --inputbox "Auto-fetch interval (minutes):" 8 40 "$AUTO_FETCH_INTERVAL" 3>&1 1>&2 2>&3)
            PUSH_PULL_BEHAVIOR=$(dialog --radiolist "Default push/pull behavior:" 10 50 2 \
                "merge" "" on \
                "rebase" "" off \
                3>&1 1>&2 2>&3)
            ;;

        3)  # Automation Preferences
            AUTO_COMMIT=$(dialog --checklist "Enable auto commit suggestions:" 10 50 1 \
                "AutoCommit" "" $AUTO_COMMIT 3>&1 1>&2 2>&3)
            COMMIT_STYLE=$(dialog --radiolist "Commit message style:" 10 50 3 \
                "AI-generated" "" on \
                "Conventional" "" off \
                "Free-form" "" off \
                3>&1 1>&2 2>&3)
            TIMED_PUSH=$(dialog --checklist "Enable timed auto push:" 10 50 1 \
                "TimedPush" "" $TIMED_PUSH 3>&1 1>&2 2>&3)
            ;;

        4)  # Backup & Export Options
            BACKUP_LOCATION=$(dialog --inputbox "Backup location:" 10 50 "$BACKUP_LOCATION" 3>&1 1>&2 2>&3)
            BACKUP_FREQUENCY=$(dialog --radiolist "Backup frequency:" 10 50 3 \
                "daily" "" off \
                "weekly" "" on \
                "monthly" "" off \
                3>&1 1>&2 2>&3)
            EXPORT_COMMITS=$(dialog --checklist "Enable automatic export of commit logs:" 10 50 1 \
                "ExportCommits" "" $EXPORT_COMMITS 3>&1 1>&2 2>&3)
            ;;

        5)  # Notifications & Logging
            VERBOSE_LOG=$(dialog --checklist "Verbose output:" 10 50 1 \
                "Verbose" "" $VERBOSE_LOG 3>&1 1>&2 2>&3)
            POPUP_DIALOGS=$(dialog --checklist "Popup dialogs for actions:" 10 50 1 \
                "Popups" "" $POPUP_DIALOGS 3>&1 1>&2 2>&3)
            LOG_FILE=$(dialog --inputbox "Log file path:" 10 60 "$LOG_FILE" 3>&1 1>&2 2>&3)
            ;;

        6)  # CLI Behavior
            DEFAULT_EDITOR=$(dialog --inputbox "Default editor for Git:" 8 50 "$DEFAULT_EDITOR" 3>&1 1>&2 2>&3)
            CONFIRM_DESTRUCTIVE=$(dialog --checklist "Confirmation before destructive actions:" 10 50 1 \
                "Confirm" "" $CONFIRM_DESTRUCTIVE 3>&1 1>&2 2>&3)
            AUTO_COMPLETION=$(dialog --checklist "Enable auto-completion:" 10 50 1 \
                "Autocomplete" "" $AUTO_COMPLETION 3>&1 1>&2 2>&3)
            ;;

        7)  # AI & Autogeneration Settings
            AI_MODEL=$(dialog --radiolist "Select AI model:" 10 50 3 \
                "GPT-2" "" on \
                "GPT-3" "" off \
                "Other" "" off \
                3>&1 1>&2 2>&3)
            AI_SUGGESTIONS=$(dialog --checklist "Enable AI suggestions for PRs, changelogs, branch names:" 10 50 1 \
                "AISuggestions" "" $AI_SUGGESTIONS 3>&1 1>&2 2>&3)
            AI_TEMPERATURE=$(dialog --inputbox "AI creativity/temperature (0.0-1.0):" 8 40 "$AI_TEMPERATURE" 3>&1 1>&2 2>&3)
            ;;

        8)  # Miscellaneous
            SHOW_HIDDEN_FILES=$(dialog --checklist "Show hidden files in file manager:" 10 50 1 \
                "HiddenFiles" "" $SHOW_HIDDEN_FILES 3>&1 1>&2 2>&3)
            DEFAULT_BRANCH=$(dialog --inputbox "Default branch for new repos:" 8 50 "$DEFAULT_BRANCH" 3>&1 1>&2 2>&3)
            COLORIZE_OUTPUT=$(dialog --checklist "Enable colorized output for Git:" 10 50 1 \
                "Colorize" "" $COLORIZE_OUTPUT 3>&1 1>&2 2>&3)
            ;;

        9)  # Exit
            save_settings
            break
            ;;
    esac
done

# Save settings on exit
save_settings
