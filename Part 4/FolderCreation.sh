#!/usr/bin/env bash
# File name: FolderCreation.sh
# Author: Billy Tran
# Student ID: A00332627

set -euo pipefail

# --- Helper: require root ---
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root (use sudo)." >&2
  exit 1
fi

# --- Define base path and departments ---
BASE_DIR="/EmployeeData"

# Use exact names requested (spaces included); map to lowercase group names without spaces.
# Directory names must be quoted when containing spaces.
declare -A DEPT_GROUP_MAP=(
  ["HR"]="hr"
  ["IT"]="it"
  ["Finance"]="finance"
  ["Executive"]="executive"
  ["Administrative"]="admin"
  ["Call Centre"]="callcentre"
)

# Sensitive departments (special permissions: 760)
SENSITIVE_DEPTS=("Executive" "HR")

# --- Create department groups if missing ---
for dept in "${!DEPT_GROUP_MAP[@]}"; do
  grp="${DEPT_GROUP_MAP[$dept]}"
  if ! getent group "$grp" >/dev/null; then
    groupadd "$grp"
    echo "Created group: $grp"
  fi
done

# --- Create base directory ---
created_count=0
if [[ ! -d "$BASE_DIR" ]]; then
  mkdir -p "$BASE_DIR"
  ((created_count++))
fi

# Ensure base directory owned by root and readable
chown root:root "$BASE_DIR"
chmod 755 "$BASE_DIR"

# --- Create each department folder, set ownership and permissions recursively ---
for dept in "HR" "IT" "Finance" "Executive" "Administrative" "Call Centre"; do
  dir_path="$BASE_DIR/$dept"
  grp="${DEPT_GROUP_MAP[$dept]}"

  # Create directory if absent
  if [[ ! -d "$dir_path" ]]; then
    mkdir -p "$dir_path"
    ((created_count++))
    echo "Created: $dir_path"
  fi

  # Ownership: root user, department group
  chown -R "root:$grp" "$dir_path"

  # Permissions: recursive (-R) as specified
  is_sensitive=false
  for s in "${SENSITIVE_DEPTS[@]}"; do
    if [[ "$dept" == "$s" ]]; then
      is_sensitive=true
      break
    fi
  done

  if $is_sensitive; then
    # User=rwx, Group=rw-, Other=---
    chmod -R 760 "$dir_path"
  else
    # User=rwx, Group=rw-, Other=r--
    chmod -R 764 "$dir_path"
  fi
done

# --- Final message ---
echo "Total folders created in this run: $created_count"
