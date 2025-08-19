#!/bin/bash
declare -A MENU_MAP_SHOW=(
    [1]="View All Files"
    [2]="Automation Menu"
    [3]="Settings"
    [4]="Backup & Export"
    [5]="Dev Tools"
    [6]="Insights & Analysis"
    [7]="Conflict Helper"
    [8]="Exit"
)
declare -A MENU_MAP=(
    [1]="Menu Options/FileManager/fileManager.sh"
    [2]="Menu Options/Automation/automationMenu.sh"
    [3]="Menu Options/Settings/settings.sh"
    [4]="Menu Options/BackupExport/backupExport.sh"
    [5]="Menu Options/DevTools/devTools.sh"
    [6]="Menu Options/Analytics/insightsAnalysis.sh"
    [7]="Menu Options/Conflict/conflictHelper.sh"
    [8]="exit"
)

CACHE_DIR="$HOME/.cache/aghh"
REPO_LIST="$CACHE_DIR/repocache.txt"
CACHE_FILE="$HOME/.cache/aghh/repocache.txt"
