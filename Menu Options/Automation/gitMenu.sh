#!/bin/bash

CACHE_FILE="$1"

# Check if cache file exists
if [ -z "$CACHE_FILE" ] || [ ! -f "$CACHE_FILE" ]; then
    dialog --msgbox "No last used repository found." 10 50
    exit 1
fi

REPO_PATH=$(cat "$CACHE_FILE")

# Check if repo exists and is a git repository
if [ ! -d "$REPO_PATH/.git" ]; then
    dialog --msgbox "Directory $REPO_PATH is not a Git repository." 10 50
    exit 1
fi

cd "$REPO_PATH" || exit 1

while true; do
    CHOICE=$(dialog --clear \
        --title "Git Operations" \
        --menu "Select an operation for $REPO_PATH" 20 70 10 \
        1 "Status" \
        2 "Pull from branch" \
        3 "Push to branch" \
        4 "Switch branch" \
        5 "Checkout previous commit" \
        6 "Show log" \
        7 "Back" \
        3>&1 1>&2 2>&3)

    EXIT_STATUS=$?
    clear

    if [ $EXIT_STATUS -ne 0 ] || [ "$CHOICE" = "7" ]; then
        break
    fi

    case $CHOICE in
        1) # Status
            OUTPUT=$(git status)
            dialog --msgbox "$OUTPUT" 30 90
            ;;

        2) # Pull from branch (remote)
            MENU_ITEMS=()
            while IFS= read -r branch; do
                branch_clean=$(echo "$branch" | sed 's|origin/||')
                MENU_ITEMS+=("$branch_clean" "$branch_clean")
            done < <(git branch -r | grep -v '->')
            
            BRANCH=$(dialog --menu "Select remote branch to pull from:" 20 60 15 "${MENU_ITEMS[@]}" 3>&1 1>&2 2>&3)
            if [ -n "$BRANCH" ]; then
                OUTPUT=$(git pull origin "$BRANCH" 2>&1)
                dialog --msgbox "$OUTPUT" 30 90
            fi
            ;;

        3) # Push to branch (local)
            MENU_ITEMS=()
            while IFS= read -r branch; do
                MENU_ITEMS+=("$branch" "$branch")
            done < <(git branch --format="%(refname:short)")
            
            BRANCH=$(dialog --menu "Select branch to push to:" 20 60 15 "${MENU_ITEMS[@]}" 3>&1 1>&2 2>&3)
            if [ -n "$BRANCH" ]; then
                OUTPUT=$(git push origin "$BRANCH" 2>&1)
                dialog --msgbox "$OUTPUT" 30 90
            fi
            ;;

        4) # Switch branch
            MENU_ITEMS=()
            while IFS= read -r branch; do
                MENU_ITEMS+=("$branch" "$branch")
            done < <(git branch --format="%(refname:short)")
            
            BRANCH=$(dialog --menu "Select branch to switch to:" 20 60 15 "${MENU_ITEMS[@]}" 3>&1 1>&2 2>&3)
            if [ -n "$BRANCH" ]; then
                OUTPUT=$(git checkout "$BRANCH" 2>&1)
                dialog --msgbox "$OUTPUT" 30 90
            fi
            ;;

        5) # Checkout previous commit
            COMMITS=$(git log --oneline -n 20)
            MENU_ITEMS=()
            while IFS= read -r line; do
                HASH=$(echo "$line" | awk '{print $1}')
                MSG=$(echo "$line" | cut -d' ' -f2-)
                MENU_ITEMS+=("$HASH" "$MSG")
            done <<< "$COMMITS"
            
            COMMIT=$(dialog --menu "Select commit to checkout:" 30 100 20 "${MENU_ITEMS[@]}" 3>&1 1>&2 2>&3)
            if [ -n "$COMMIT" ]; then
                OUTPUT=$(git checkout "$COMMIT" 2>&1)
                dialog --msgbox "$OUTPUT" 30 90
            fi
            ;;

        6) # Show log
            OUTPUT=$(git log --oneline --graph --decorate -n 30)
            dialog --msgbox "$OUTPUT" 40 100
            ;;
    esac
done

