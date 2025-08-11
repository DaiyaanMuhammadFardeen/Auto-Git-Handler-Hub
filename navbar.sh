#!/bin/bash
source ./globals.sh

# Build dialog arguments dynamically
MENU_ARGS=()
for key in "${!MENU_MAP[@]}"; do
  MENU_ARGS+=("$key" "${MENU_MAP[$key]}")
done

# Sort keys numerically (dialog menu expects sorted input)
IFS=$'\n' sorted=($(sort -n <<<"${MENU_ARGS[*]}"))
unset IFS

# Actually, sorting array pairs is tricky; instead sort keys and add pairs in order:
sorted_keys=($(printf "%s\n" "${!MENU_MAP[@]}" | sort -n))
MENU_ARGS=()
for key in "${sorted_keys[@]}"; do
  MENU_ARGS+=("$key" "${MENU_MAP[$key]}")
done

CHOICE=$(dialog --title "Main Navigation" --menu "Select an option:" 20 60 12 "${MENU_ARGS[@]}" 3>&1 1>&2 2>&3)

echo "$CHOICE"
