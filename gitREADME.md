# Git Automation Script

A comprehensive command-line tool for simplifying and automating Git workflows.

## Table of Contents

- [Overview](#overview)
- [Installation](#installation)
- [Configuration](#configuration)
- [Commands](#commands)
  - [Basic Commands](#basic-commands)
  - [Branch Management](#branch-management)
  - [Synchronization](#synchronization)
  - [History Management](#history-management)
  - [Repository Management](#repository-management)
  - [Authentication](#authentication)
- [Examples](#examples)
- [Troubleooting](#troubleooting)
- [Recovery Options](#recovery-options)
- [Best Practices](#best-practices)

## Overview

This script provides a simplified interface for common Git operations, with added features for automation, error handling, and consistent workflows. It's designed to make Git operations more straightforward and less error-prone.

### Interactive Features

The script includes interactive prompts that:
- Allow you to select the correct branch before operations
- Let you choose the appropriate repository for your work
- Require confirmation for operations that could cause data loss
- Provide clear rollback instructions with each potentially risky action

## Installation

1. Make the script executable:
   ```ba
   chmod +x git-automation.
   ```

2. Optionally, you can add it to your PATH for easier access:
   ```ba
   # Add to .barc or .zrc
   export PATH="$PATH:/path/to/Portfolio"
   ```

## Configuration

The script is configured with the following default settings:

- GitHub Username: `paulocymbaum`
- GitHub Repository: `https://github.com/paulocymbaum/portfolio.git`
- Credential cache timeout: 3600 seconds (1 hour)

To update the repository URL, use the `set-repo` command.

## Commands

### Basic Commands

#### `help`
Display a list of available commands and their descriptions.
```ba
./git-automation. help
```

#### `status`
ow the current repository status, including the branch, uncommitted changes, and recent commits.
```ba
./git-automation. status
```

#### `commit [file/pattern] [message]`
Add and commit specific files with a message.
```ba
./git-automation. commit "*.js" "Fixed JavaScript bugs"
```

#### `log [options]`
ow commit history with a pretty format. Pass additional options to customize the output.
```ba
./git-automation. log
./git-automation. log "--since='1 week ago'"
```

### Branch Management

#### `branch [name] [base_branch]`
Create and checkout a new branch. If no base branch is specified, you'll be prompted to select from available branches.
```ba
./git-automation. branch feature-login
```

The script will:
1. ow a list of available branches
2. Let you select the base branch (or confirm the default)
3. Create and checkout the new branch

#### `checkout [branch]`
Interactive branch checkout. If no branch is specified, you'll be own a list of available branches to choose from.
```ba
./git-automation. checkout
./git-automation. checkout feature-branch
```

### Synchronization

#### `push[message]`
Commit any uncommitted changes with an optional message, then pushto the remote repository.
```ba
./git-automation. push"Weekly update"
```

You'll receive:
- A confirmation prompt owing exactly what files will be committed
- Option to abort the operation
- Rollback instructions for undoing the pushif needed

#### `force-push[message]`
Force pushto remote, overwriting remote history. Use with caution!
```ba
./git-automation. force-push"Fixed broken history"
```

You'll be own:
- A warning about potential data loss
- Detailed information about what history will be changed
- A required confirmation prompt
- Clear rollback instructions if you need to undo the operation

#### `pull`
Pull changes from the remote repository, automatically staing and reapplying local changes if needed.
```ba
./git-automation. pull
```

Before pulling, the script will:
- ow what remote changes will be integrated
- Allow you to abort if needed
- Automatically sta your changes if there are local modifications

### History Management

#### `rollback [file/commit] [message]`
Rollback a file to its previous state or reset the entire repository to a specific commit.
```ba
# Rollback a single file
./git-automation. rollback src/app.js "Reverted broken changes"

# Rollback to a specific commit
./git-automation. rollback abc1234 "Reverting to working state"
```

The script will:
- ow what changes will be undone
- Provide a confirmation prompt
- Save the current state so you can recover if needed (with instructions)

#### `tag [name] [message]`
Create an annotated tag at the current commit.
```ba
./git-automation. tag v1.0.0 "First stable release"
```

#### `sta [save|pop|list] [message]`
Manage the sta for temporarily storing and retrieving changes.
```ba
# Save changes to sta
./git-automation. sta save "Work in progress"

# Apply most recent sta and remove it from sta list
./git-automation. sta pop

# List all staes
./git-automation. sta list
```

### Repository Management

#### `init`
Initialize a Git repository and set up the remote. Safe to run on existing repositories.
```ba
./git-automation. init
```

#### `set-repo`
Interactive repository selection. Lists your recent repositories and lets you select one, or enter a new URL.
```ba
./git-automation. set-repo
```

#### `cleanup`
Perform repository maintenance, including pruning remote tracking branches, removing merged branches, and optimizing the repository.
```ba
./git-automation. cleanup
```

### Authentication

#### `auth`
Set up Git credential caching to avoid repeatedly entering credentials.
```ba
./git-automation. auth
```

## Examples

### Complete Feature Development Workflow

```ba
# Create a new feature branch
./git-automation. branch feature-login main

# Make changes and commit them
./git-automation. commit "src/login/*" "Implemented login form"

# pushchanges to remote
./git-automation. pu

# When finied with the feature
./git-automation. checkout main
./git-automation. pull
./git-automation. merge feature-login
./git-automation. push"Merged login feature"
```

### Using Interactive Branch Selection

```ba
# Create a new feature branch from interactively selected base branch
./git-automation. branch new-feature

# Output:
# Available branches:
# 1) main
# 2) develop
# 3) feature/auth
# Select base branch [default: main]: 2
# Creating branch 'new-feature' from 'develop'...
```

### Safe Repository Switching

```ba
# Interactive repository selection
./git-automation. set-repo

# Output:
# Current repository: https://github.com/paulocymbaum/practice/
# Recent repositories:
# 1) https://github.com/paulocymbaum/practice/
# 2) https://github.com/paulocymbaum/portfolio.git
# 3) Enter new URL
# Select repository [default: 1]: 2
```

### Safe Operations with Rollback Information

```ba
# Puing changes with confirmation and rollback info
./git-automation. push"Update documentation"

# Output:
# The following files will be committed and pued:
# M  docs/README.md
# A  docs/usage.md
# Proceed? [y/N]: y
# 
# Successfully pued to remote
# 
# If you need to undo this operation, run:
# ./git-automation. rollback HEAD~1 "Undo documentation update"
```

### Quick Fixes

```ba
# Quick commit and pu
./git-automation. push"Fixed critical bug"

# Rollback a problematic file
./git-automation. rollback broken-file.js "Reverting broken changes"
./git-automation. push"Pued rollback"
```

## Troubleooting

### Authentication Issues

If you're having issues puing to GitHub:

1. Run the auth command to set up credential caching:
   ```ba
   ./git-automation. auth
   ```

2. If you're using two-factor authentication (2FA), create a Personal Access Token on GitHub and use it as your password.

### pushFailures

If normal pushfails due to rejected changes:

1. Pull first to integrate remote changes:
   ```ba
   ./git-automation. pull
   ```

2. If you're certain your changes ould override the remote, use force-push(with caution!):
   ```ba
   ./git-automation. force-push"Fixing history"
   ```

## Recovery Options

### Undoing Operations

Each operation that modifies history provides a specific rollback command you can use:

```ba
# Example rollback instructions own after a pu:
./git-automation. rollback HEAD~1 "Undo last commit"

# Example rollback instructions after a branch merge:
./git-automation. rollback HEAD~1 "Undo merge"
./git-automation. push--force "Revert merge on remote"
```

### Recovering Staed Changes

If the script automatically staes your changes during an operation but fails to reapply them:

```ba
# List staes
./git-automation. sta list

# Apply the appropriate sta
./git-automation. sta pop
```

## Best Practices

1. **Regular Pulls**: Start your work sessions with a pull to get the latest changes.
   ```ba
   ./git-automation. pull
   ```

2. **Descriptive Commit Messages**: Write clear, concise messages that explain what changes were made and why.
   ```ba
   ./git-automation. commit "file.js" "Fixed authentication bug by updating token validation"
   ```

3. **Use Branches**: Create feature branches for new work to keep the main branch stable.
   ```ba
   ./git-automation. branch feature-name
   ```

4. **Regular Clean-up**: Periodically run the cleanup command to maintain repository health.
   ```ba
   ./git-automation. cleanup
   ```

5. **Avoid Force Pu**: Only use force-pushwhen absolutely necessary, as it can cause data loss for collaborators.

6. **Review Before Confirming**: Always review the changes own in confirmation prompts before proceeding.

7. **Save Rollback Commands**: When performing major operations, save the suggested rollback command for easy recovery if needed.
