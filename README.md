# GitHub Issue Automation Script

This project automates the creation of GitHub issues from a CSV file using the GitHub CLI (`gh`). It is designed to streamline project planning by allowing you to define issues in a structured format and create them in bulk.

## Prerequisites

1. **GitHub CLI**: Ensure the GitHub CLI (`gh`) is installed on your system. You can install it from [GitHub CLI Installation Guide](https://cli.github.com/).
2. **Authentication**: Log in to the GitHub CLI by running:
   ```bash
   gh auth login
   ```
   Make sure you have the necessary permissions to create issues and labels in the target repository.
3. **CSV File**: Prepare a CSV file named `issues.csv` in the following format:
   ```csv
   title,body,assignees,labels,milestone
   "Issue Title","Issue description","assignee1,assignee2","label1,label2","Milestone Name"
   ```

## Setup

1. Clone this repository or copy the script to your local machine.
2. Place the `issues.csv` file in the same directory as the script.
3. Open the script (`script.sh`) and update the `REPO` variable to point to your target GitHub repository:
   ```bash
   REPO="YourUsername/YourRepository"
   ```

## Usage

1. Make the script executable:
   ```bash
   chmod +x script.sh
   ```
2. Run the script:
   ```bash
   ./script.sh
   ```
3. Follow the prompts to create issues.

## Features

- **Label Creation**: Automatically creates missing labels defined in the CSV file.
- **Bulk Issue Creation**: Reads issues from the CSV file and creates them in the specified repository.

## CSV Format

The `issues.csv` file should have the following columns:

- `title`: The title of the issue.
- `body`: A detailed description of the issue.
- `assignees`: Comma-separated GitHub usernames to assign the issue to.
- `labels`: Comma-separated labels to apply to the issue.

Example:
```csv
title,body,assignees,labels,milestone
"Implement Feature X","Description of feature X","user1,user2","feature,backend","Milestone 1"
"Fix Bug Y","Description of bug Y","user3","bug,frontend","Milestone 2"
```

## Example `issues.csv`

An example `issues.csv` file is provided in this repository as `issues.example.csv`. You can use it as a template by copying it to your working directory and renaming it to `issues.csv`:

```bash
cp issues.example.csv issues.csv
```

Modify the contents of `issues.csv` to suit your project needs.

## Troubleshooting

- **Authentication Errors**: Ensure you are logged in to the GitHub CLI and have the correct permissions.
- **Label Not Found**: The script will automatically create missing labels. If a label already exists, it will skip creation.
- **CSV Parsing Issues**: Ensure the CSV file is properly formatted with no extra commas or missing fields.

## Limitations

- The script does not currently support milestones. If milestones are included in the CSV, they will be ignored.
- Ensure the repository is accessible and you have the necessary permissions to create issues and labels.

## License

This project is open-source and available under the MIT License.