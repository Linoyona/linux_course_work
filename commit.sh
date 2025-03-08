#!/bin/bash

# --- Define CSV file name ---
CSV_FILE="bugs.csv"

# --- Validation 1: Check if the CSV file exists ---
if [[ ! -f "$CSV_FILE" ]]; then
  echo "Error: CSV file not found! Please make sure the CSV file is in the same directory as the script."
  exit 1
fi

# --- Get the current branch name ---
BRANCH_NAME=$(git symbolic-ref --short HEAD)

# --- Get the developer's name from Git config ---
DEVELOPER_NAME=$(git config user.name)

# --- Get the current date and time ---
CURRENT_DATE=$(date "+%Y-%m-%d %H:%M:%S")

# --- Search for relevant data in the CSV file based on the current branch ---
BUGID=$(grep "$BRANCH_NAME" "$CSV_FILE" | cut -d ',' -f 1)
DESCRIPTION=$(grep "$BRANCH_NAME" "$CSV_FILE" | cut -d ',' -f 2)
PRIORITY=$(grep "$BRANCH_NAME" "$CSV_FILE" | cut -d ',' -f 5)

# --- Validation 2: Check if data was found in the CSV file ---
if [[ -z "$BUGID" || -z "$DESCRIPTION" || -z "$PRIORITY" ]]; then
  echo "Error: No data found for branch $BRANCH_NAME in the CSV file."
  exit 1
fi

# --- Create the commit message ---
COMMIT_MESSAGE="BugID:$BUGID:$CURRENT_DATE:$BRANCH_NAME:$DEVELOPER_NAME:$PRIORITY:$DESCRIPTION"

# --- If there is an additional description from the developer, add it to the commit message ---
if [[ -n "$1" ]]; then
  COMMIT_MESSAGE="$COMMIT_MESSAGE:$1"
fi

# --- Stage the changes, commit, and push to GitHub ---
git add .
if git commit -m "$COMMIT_MESSAGE"; then
  echo "Commit successful!"
else
  echo "Error: There was an error during commit."
  exit 1
fi

# --- Push the changes to GitHub ---
if git push; then
  echo "Push successful!"
else
  echo "Error: There was an error during push."
  exit 1
fi

# --- Display the commit message ---
echo "Commit description: $COMMIT_MESSAGE"

