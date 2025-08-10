#!/bin/sh

CACHE_FILE="$HOME/.cache/aghh/repocache.txt"

# Run the repo finder script initially (optional)
refresh_repo_list() {
  ./findGitRepos.sh
  dialog --msgbox "Repo list refreshed." 10 50
}

# Show the repo selection menu and save choice
select_repo() {
  if [ ! -f "$CACHE_FILE" ]; then
    dialog --msgbox "Cache file not found. Run refresh first." 10 50
    return
  fi

  MENU_ITEMS=""
  while IFS= read -r repo_path; do
    repo_name=$(basename "$repo_path")
    MENU_ITEMS="$MENU_ITEMS $repo_name ''"
  done < "$CACHE_FILE"

  FOOTER="Select a repo by navigating and pressing Enter.

[1] Refresh Repo List   [2] Select Repo   [q] Quit"

  CHOICE=$(dialog --title "aghh Git Repo Selector" --menu "$FOOTER" 25 70 15 $MENU_ITEMS 3>&1 1>&2 2>&3)
  exitstatus=$?

  if [ $exitstatus = 0 ]; then
    dialog --msgbox "You chose: $CHOICE" 10 50
  else
    dialog --msgbox "No repo selected." 10 50
  fi
}

# Main menu loop with footer prompt for keys
main_menu() {
  while true; do
    clear
    FOOTER="Press a key:

[1] Refresh Repo List   [2] Select Repo   [q] Quit"

    # Show the footer prompt inside an inputbox to capture key press
    CHOICE=$(dialog --title "aghh Main Menu" --inputbox "$FOOTER" 10 70 3>&1 1>&2 2>&3)
    exitstatus=$?

    clear
    if [ $exitstatus != 0 ]; then
      break
    fi

    case "$CHOICE" in
      1)
        refresh_repo_list
        ;;
      2)
        select_repo
        ;;
      q|Q)
        break
        ;;
      *)
        dialog --msgbox "Invalid choice, try again." 10 50
        ;;
    esac
  done

  clear
}

# Start program
main_menu

