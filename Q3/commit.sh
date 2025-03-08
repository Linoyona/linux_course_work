#!/bin/bash


if [ ! -f Q3/bugs.csv ]; then
  echo "Error: CSV file does not exist"
  exit 1
fi


branch_name=$(git rev-parse --abbrev-ref HEAD)


bug_info=$(grep "$branch_name" Q3/bugs.csv)


if [ -z "$bug_info" ]; then
  echo "Error: No data found for branch $branch_name"
  exit 1
fi


BUGID=$(echo "$bug_info" | cut -d',' -f1)
DESCRIPTION=$(echo "$bug_info" | cut -d',' -f2)
DEVELOPER_NAME=$(echo "$bug_info" | cut -d',' -f4)
BUG_PRIORITY=$(echo "$bug_info" | cut -d',' -f5)


current_time=$(date "+%Y-%m-%d %H:%M:%S")


commit_message="BugID:$BUGID:$current_time:$branch_name:$DEVELOPER_NAME:$BUG_PRIORITY:$DESCRIPTION"


if [ $# -gt 0 ]; then
  commit_message="$commit_message:$1"
fi


git add .
git commit -m "$commit_message"
git push


if [ $? -ne 0 ]; then
  echo "Error: Commit or Push failed"
  exit 1
fi

echo "Commit and push successful"
