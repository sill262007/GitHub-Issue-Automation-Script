#!/bin/bash

# Ensure you have authenticated with GitHub CLI
# gh auth login

# Set your repository
REPO="AD-Archer/Launchpad_Student_Form"

# Define a single-byte unit separator (ASCII 0x1E) as the field separator
FIELD_SEPARATOR=$'\x1e'

# Check if issues.csv exists
if [ ! -f issues.csv ]; then
    echo "Error: issues.csv not found in the current directory ($(pwd))!"
    exit 1
fi

echo "This script will create GitHub issues based on 'issues.csv'."
echo "Target repository: $REPO"
echo "IMPORTANT:"
echo "1. Ensure 'gh' CLI is installed and you are authenticated (run 'gh auth login')."
echo "2. Verify the REPO variable above is set to your correct GitHub repository (e.g., YourUser/YourRepo)."
echo "3. Ensure milestones listed in 'issues.csv' exist in the repository, or issue creation may fail for those."
echo ""
read -p "Press Enter to continue, or Ctrl+C to abort."

echo ""
echo "Bootstrapping labels..."
# Bootstrap labels
tail -n +2 issues.csv \
  | grep '^"' \
  | sed -e 's/^"//' -e 's/"$//' \
  | awk -F'","' '{print $4}' \
  | tr ',' '\n' \
  | sort -u \
  | while read -r lbl; do
    if [[ -n "$lbl" ]] && ! gh label view "$lbl" --repo "$REPO" >/dev/null 2>&1; then
      echo "Creating label: $lbl"
      gh label create "$lbl" --repo "$REPO" --color ededed
    fi
done

echo ""
echo "Starting issue creation..."

# Read the CSV file line by line, skipping the header
# The `|| [[ -n "$line" ]]` ensures the last line is processed even if it doesn't end with a newline
tail -n +2 issues.csv | while IFS= read -r line || [[ -n "$line" ]];
do
  # Skip empty or whitespace-only lines
  if [[ -z "${line// }" ]]; then # Removes all spaces and checks if empty
    continue
  fi

  # Transform the line:
  # 1. Remove leading quote from the start of the line: sed 's/^"//'
  # 2. Remove trailing quote from the end of the line: sed 's/"$//'
  # 3. Replace all occurrences of '","' with the FIELD_SEPARATOR
  processed_line=$(echo "$line" | sed -e 's/^"//' -e 's/"$//' -e "s/\",\"/$FIELD_SEPARATOR/g")

  # Now, read the fields using the new separator into an array
  IFS="$FIELD_SEPARATOR" read -r -a fields <<< "$processed_line"
  
  # Assign fields from array
  # Ensure we have enough fields before trying to access them
  # Minimal check for 5 fields, though more robust checking might be needed for truly malformed lines
  if [ "${#fields[@]}" -lt 5 ]; then
    echo "WARNING: Skipping line due to insufficient fields after parsing. Line content: $line"
    echo "  Processed line: $processed_line"
    echo "  Parsed fields count: ${#fields[@]}"
    continue
  fi

  title="${fields[0]}"
  body="${fields[1]}"
  assignees="${fields[2]}"
  labels="${fields[3]}"
  milestone_name="${fields[4]}"

  # Ensure labels exist; if not, create them
  if [ -n "$labels" ]; then
    IFS=',' read -r -a label_array <<< "$labels"
    for lbl in "${label_array[@]}"; do
      if ! gh label view "$lbl" --repo "$REPO" >/dev/null 2>&1; then
        echo "Label '$lbl' not found. Creating..."
        # Create the label with a default color
        gh label create "$lbl" --repo "$REPO" --color "ededed"
      fi
    done
  fi

  # Construct gh command arguments
  gh_command_args=(--repo "$REPO" --title "$title" --body "$body")
  
  if [ -n "$assignees" ]; then
    # For multiple assignees, they should be comma-separated in the CSV, e.g., "user1,user2"
    gh_command_args+=(--assignee "$assignees")
  fi
  
  if [ -n "$labels" ]; then
    # For multiple labels, they should be comma-separated in the CSV, e.g., "bug,ui"
    gh_command_args+=(--label "$labels")
  fi

  # Create the issue
  output=$(gh issue create "${gh_command_args[@]}" 2>&1)
  exit_status=$?
  
  if [ $exit_status -ne 0 ]; then
    echo "ERROR: Failed to create issue with title: \"$title\""
    echo "  gh CLI output: $output"
    echo "  Ensure milestone '$milestone_name' (if specified) exists in repo '$REPO'."
  else
    echo "Successfully created issue: \"$title\""
    echo "  URL: $output" # gh issue create outputs the URL on success
  fi
done

echo "----------------------------------------"
echo "Script finished."
