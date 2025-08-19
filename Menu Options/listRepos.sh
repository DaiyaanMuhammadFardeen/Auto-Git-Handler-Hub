#!/bin/sh

. ./globals.sh

refresh_repo_list() {
    bash "$(dirname "$0")/findGitRepos.sh"
    dialog --msgbox "Repo list refreshed." 10 50
}

select_repo() {
    if [ ! -f "$CACHE_FILE" ]; then
        dialog --msgbox "Cache file not found. Run refresh first." 10 50
        return 1
    fi

    MENU_ITEMS=""
    while IFS= read -r repo_path; do
        repo_name=$(basename "$repo_path")
        MENU_ITEMS="$MENU_ITEMS $repo_path $repo_name"
    done < "$CACHE_FILE"

    CHOICE=$(dialog --title "Select Git Repo" --menu "Choose a repository:" 35 110 25 $MENU_ITEMS 3>&1 1>&2 2>&3)
    exitstatus=$?

    if [ "$exitstatus" = 0 ]; then
        echo "$CHOICE" > ~/.cache/aghh/lastRepoUsed.txt
        echo "$CHOICE"  # Output selected repo path
        return 0
    else
        return 1
    fi
}

# Run refresh first if cache missing
[ ! -f "$CACHE_FILE" ] && refresh_repo_list

select_repo
