#!/bin/bash
declare -A MENU_MAP_SHOW=(
  [1]="View All Files"
  [2]="Automation Menu"
  [3]="Commit & Push"
  [4]="Branch Management"
  [5]="Settings"
  [6]="Backup & Export"
  [7]="Dev Tools"
  [8]="Insights & Analysis"
  [9]="Conflict Helper"
  [10]="Exit"
)
declare -A MENU_MAP=(
  [1]="Menu Options/FileManager/fileManager.sh"
  [2]="Menu Options/Automation/automationMenu.sh"
  [3]="Menu Options/CommitMenu/commitPush.sh"
  [4]="Menu Options/BranchMenu/branchManagement.sh"
  [5]="Menu Options/Settings/settings.sh"
  [6]="Menu Options/BackupExport/backupExport.sh"
  [7]="Menu Options/DevTools/devTools.sh"
  [8]="Menu Options/Analytics/insightsAnalysis.sh"
  [9]="Menu Options/Conflict/conflictHelper.sh"
  [10]="exit"
)

CACHE_DIR="$HOME/.cache/aghh"
REPO_LIST="$CACHE_DIR/repocache.txt"
CACHE_FILE="$HOME/.cache/aghh/repocache.txt"
