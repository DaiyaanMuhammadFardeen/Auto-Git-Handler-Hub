#!/bin/sh

CACHE_FILE="$HOME/.cache/aghh/lastRepoUsed.txt"

if [ ! -f "$CACHE_FILE" ]; then
  echo "No selected repo found. Please select a repository first."
  exit 1
fi

REPO_PATH=$(cat "$CACHE_FILE")

# Validate repo path
if [ ! -d "$REPO_PATH" ]; then
  echo "Stored repo path '$REPO_PATH' is not a valid directory."
  exit 1
fi

CUR_DIR="$REPO_PATH"

while true; do
  MENU_ITEMS=()

  if [ "$CUR_DIR" != "$REPO_PATH" ]; then
    MENU_ITEMS+=(".." "Go up one directory")
  fi

  for d in "$CUR_DIR"/*/; do
    [ -d "$d" ] || continue
    DIRNAME=$(basename "$d")
    MENU_ITEMS+=("$DIRNAME" "Directory")
  done

  for f in "$CUR_DIR"/*; do
    [ -f "$f" ] || continue
    FILENAME=$(basename "$f")
    MENU_ITEMS+=("$FILENAME" "File")
  done

  if [ "${#MENU_ITEMS[@]}" -eq 0 ]; then
    dialog --msgbox "No files or directories found in $CUR_DIR" 10 50
    if [ "$CUR_DIR" = "$REPO_PATH" ]; then
      exit 0
    else
      CUR_DIR=$(dirname "$CUR_DIR")
      continue
    fi
  fi

  CHOICE=$(dialog --clear --title "File Manager: $CUR_DIR" \
    --menu "Select file or directory:" 30 80 20 \
    "${MENU_ITEMS[@]}" \
    3>&1 1>&2 2>&3)
  EXITSTATUS=$?

  if [ $EXITSTATUS -ne 0 ]; then
    exit 10
  fi

  if [ "$CHOICE" = ".." ]; then
    if [ "$CUR_DIR" != "$REPO_PATH" ]; then
      CUR_DIR=$(dirname "$CUR_DIR")
    fi
  else
    if [ -d "$CUR_DIR/$CHOICE" ]; then
      CUR_DIR="$CUR_DIR/$CHOICE"
    else
      dialog --title "Viewing file: $CHOICE" --textbox "$CUR_DIR/$CHOICE" 30 80
    fi
  fi
done
