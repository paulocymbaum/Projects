#!/bin/bash
# filepath: /home/paulo-yapper/Documents/Documentacao Dev/Portfolio/git-automation.

# Configuration
GITHUB_USERNAME="paulocymbaum"
REPO_PATH=$(pwd)
GITHUB_REPO_URL="https://github.com/paulocymbaum/Projects.git"

# Store previous repositories for easy switching
REPO_HISTORY_FILE="$HOME/.git_automation_repo_history"
touch "$REPO_HISTORY_FILE" 2>/dev/null

# Add credential helper variables
CREDENTIAL_CACHE_TIMEOUT="3600"  # Cache credentials for 1 hour

# Text formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_usage() {
    echo -e "${BLUE}Git Automation Tool${NC}"
    echo ""
    echo "Usage: $(basename $0) [command] [options]"
    echo ""
    echo "Commands:"
    echo "  commit [file/pattern] [message]    Commit specified file(s) with message"
    echo "  pu [message]                     Commit any changes, then pu to remote repository"
    echo "  branch [name] [base_branch]        Create and checkout a new branch"
    echo "  rollback [file/commit] [message]   Rollback a file or to a specific commit, then commit"
    echo "  status                             ow the repository status"
    echo "  help                               ow this help message"
    echo "  pull                               Pull changes from remote repository"
    echo "  merge [branch]                     Merge specified branch into current branch"
    echo "  tag [name] [message]               Create a new tag with optional message"
    echo "  sta [save|pop|list]              Manage git staes"
    echo "  log [options]                      ow commit logs with enhanced formatting"
    echo "  cleanup                            Clean up merged branches and optimize repository"
    echo "  init                               Initialize repository and set remote to your portfolio"
    echo "  auth                               Set up Git credentials for puing"
    echo "  force-pu [message]               Force pu to remote (use with caution)"
    echo "  set-repo [url]                     Update the repository URL"
    echo "  checkout [branch]                  Checkout or interactively select a branch"
}

provide_rollback_hint() {
    local operation="$1"
    local target="$2"
    local message="$3"
    
    echo -e "\n${YELLOW}If you need to undo this operation, run:${NC}"
    
    case "$operation" in
        "commit")
            echo -e "${BLUE}./git-automation. rollback HEAD~1 \"Undo: $message\"${NC}"
            ;;
        "merge")
            echo -e "${BLUE}./git-automation. rollback HEAD~1 \"Undo merge with $target\"${NC}"
            echo -e "${BLUE}./git-automation. force-pu \"Revert merge on remote\"${NC}"
            ;;
        "branch-delete")
            echo -e "${BLUE}./git-automation. branch $target $(git rev-parse --abbrev-ref HEAD)${NC}"
            ;;
        "tag-delete")
            if git rev-parse "$target" >/dev/null 2>&1; then
                local tag_commit=$(git rev-parse "$target")
                echo -e "${BLUE}./git-automation. tag $target \"Restored deleted tag\" $tag_commit${NC}"
            fi
            ;;
        "pu")
            echo -e "${BLUE}./git-automation. rollback HEAD~1 \"Undo: $message\"${NC}"
            echo -e "${BLUE}./git-automation. force-pu \"Revert pued changes\"${NC}"
            ;;
        "rollback")
            local current_commit=$(git rev-parse HEAD)
            echo -e "${BLUE}./git-automation. rollback $current_commit \"Return to state before rollback\"${NC}"
            ;;
        *)
            echo -e "${BLUE}./git-automation. status${NC} to check current state"
            echo -e "${BLUE}./git-automation. log${NC} to find a commit to return to"
            ;;
    esac
}

select_branch() {
    local prompt_msg="$1"
    local default_branch="$2"
    
    local branches=()
    local i=1
    
    echo -e "${YELLOW}Available branches:${NC}"
    
    while read -r branch; do
        branches+=("$branch")
        if [[ "$branch" == "$default_branch" ]]; then
            echo -e "  ${i}) ${GREEN}$branch${NC} (default)"
        else
            echo -e "  ${i}) $branch"
        fi
        ((i++))
    done < <(git branch --format='%(refname:ort)' | sort)
    
    if [ ${#branches[@]} -eq 0 ]; then
        echo -e "${RED}No branches found${NC}"
        return 1
    fi
    
    echo ""
    read -p "$prompt_msg [$default_branch]: " selection
    
    if [ -z "$selection" ]; then
        echo "$default_branch"
        return 0
    fi
    
    if [[ "$selection" =~ ^[0-9]+$ ]] && [ "$selection" -ge 1 ] && [ "$selection" -le ${#branches[@]} ]; then
        echo "${branches[$selection-1]}"
        return 0
    else
        if git ow-ref --verify --quiet refs/heads/"$selection"; then
            echo "$selection"
            return 0
        else
            echo -e "${RED}Invalid selection. Using default: $default_branch${NC}"
            echo "$default_branch"
            return 0
        fi
    fi
}

select_repository() {
    local current_url=$(git remote get-url origin 2>/dev/null || echo "Not set")
    local repos=()
    
    echo -e "${YELLOW}Current repository: $current_url${NC}"
    echo -e "${YELLOW}Recent repositories:${NC}"
    
    repos+=("$current_url")
    echo -e "  1) $current_url (current)"
    
    local i=2
    while read -r repo; do
        if [ "$repo" != "$current_url" ] && [ -n "$repo" ]; then
            repos+=("$repo")
            echo -e "  $i) $repo"
            ((i++))
        fi
    done < "$REPO_HISTORY_FILE"
    
    echo -e "  $i) Enter new URL"
    
    echo ""
    read -p "Select repository [default: 1]: " selection
    
    if [ -z "$selection" ]; then
        echo "$current_url"
        return 0
    fi
    
    if [[ "$selection" =~ ^[0-9]+$ ]]; then
        if [ "$selection" -ge 1 ] && [ "$selection" -lt "$i" ]; then
            echo "${repos[$selection-1]}"
            return 0
        elif [ "$selection" -eq "$i" ]; then
            read -p "Enter new repository URL: " new_url
            if [ -n "$new_url" ]; then
                echo "$new_url" > "$REPO_HISTORY_FILE.tmp"
                cat "$REPO_HISTORY_FILE" >> "$REPO_HISTORY_FILE.tmp"
                mv "$REPO_HISTORY_FILE.tmp" "$REPO_HISTORY_FILE"
                echo "$new_url"
                return 0
            else
                echo -e "${RED}No URL provided. Using current: $current_url${NC}"
                echo "$current_url"
                return 0
            fi
        fi
    fi
    
    echo -e "${RED}Invalid selection. Using current repository.${NC}"
    echo "$current_url"
    return 0
}

confirm_changes() {
    local action="$1"
    local details="$2"
    
    echo -e "${YELLOW}About to $action:${NC}"
    echo -e "$details"
    echo ""
    read -p "Proceed? [y/N]: " confirm
    
    if [[ $confirm != [yY] ]]; then
        echo -e "${YELLOW}Operation cancelled.${NC}"
        return 1
    fi
    
    return 0
}

git_commit() {
    local files="$1"
    local message="$2"
    
    if [ -z "$files" ] || [ -z "$message" ]; then
        echo -e "${RED}Error: Missing arguments${NC}"
        echo "Usage: $(basename $0) commit [file/pattern] [message]"
        exit 1
    fi
    
    echo -e "${YELLOW}These files will be committed:${NC}"
    git status --porcelain $files
    
    confirm_changes "commit these files" "Message: $message" || exit 0
    
    echo -e "${YELLOW}Adding files: $files${NC}"
    git add $files
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error: Failed to add files${NC}"
        exit 1
    fi
    
    echo -e "${YELLOW}Committing with message: $message${NC}"
    git commit -m "$message"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Successfully committed changes${NC}"
        provide_rollback_hint "commit" "" "$message"
    else
        echo -e "${RED}Error: Failed to commit changes${NC}"
        exit 1
    fi
}

git_pu() {
    local message="$1"
    local current_branch=$(git rev-parse --abbrev-ref HEAD)
    
    if [ -n "$(git status --porcelain)" ]; then
        echo -e "${YELLOW}The following files will be committed and pued:${NC}"
        git status --porcelain
        
        if [ -z "$message" ]; then
            read -p "Enter commit message [Auto-commit before pu]: " message
            if [ -z "$message" ]; then
                message="Auto-commit before pu on $(date)"
            fi
        fi
        
        confirm_changes "commit and pu these changes" "Message: $message" || exit 0
        
        echo -e "${YELLOW}Committing with message: $message${NC}"
        git add .
        git commit -m "$message"
        
        if [ $? -ne 0 ]; then
            echo -e "${RED}Error: Failed to auto-commit before pu${NC}"
            exit 1
        fi
        echo -e "${GREEN}Successfully committed changes${NC}"
    else
        echo -e "${YELLOW}No changes to commit. Puing branch '$current_branch'${NC}"
    fi
    
    echo -e "${YELLOW}Commits that will be pued:${NC}"
    git log @{u}..HEAD --oneline 2>/dev/null || echo -e "${YELLOW}This appears to be the first pu for this branch${NC}"
    
    confirm_changes "pu to $GITHUB_REPO_URL" "Branch: $current_branch" || exit 0
    
    echo -e "${YELLOW}Puing branch '$current_branch' to $GITHUB_REPO_URL...${NC}"
    echo -e "${YELLOW}If prompted, enter your GitHub credentials${NC}"
    
    git push origin $current_branch
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Successfully pued to remote${NC}"
        provide_rollback_hint "pu" "" "$message"
    else
        echo -e "${RED}Error: Failed to pu to remote${NC}"
        echo -e "${YELLOW}Possible solutions:${NC}"
        echo -e "1. Run './git-automation. auth' to set up credentials"
        echo -e "2. If you need to overwrite remote changes: './git-automation. force-pu'"
        echo -e "3. If this is your first pu: git pu -u origin $current_branch"
        exit 1
    fi
}

git_force_pu() {
    local message="$1"
    local current_branch=$(git rev-parse --abbrev-ref HEAD)
    
    echo -e "${YELLOW}Commits that will force-pued (overwriting remote history):${NC}"
    git log @{u}..HEAD --oneline 2>/dev/null || echo -e "${YELLOW}This appears to be the first pu for this branch${NC}"
    
    echo -e "${RED}WARNING: Force pu will overwrite remote repository history!${NC}"
    echo -e "${RED}This can cause data loss if others have pulled these changes.${NC}"
    
    confirm_changes "FORCE PU to $GITHUB_REPO_URL" "Branch: $current_branch" || exit 0
    
    if [ -n "$(git status --porcelain)" ]; then
        if [ -z "$message" ]; then
            message="Auto-commit before force pu on $(date)"
        fi
        
        echo -e "${YELLOW}Uncommitted changes detected, committing first...${NC}"
        git add .
        git commit -m "$message"
    fi
    
    local current_commit=$(git rev-parse HEAD)
    
    echo -e "${YELLOW}Force puing branch '$current_branch' to remote...${NC}"
    git pu --force origin $current_branch
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Successfully force pued to remote${NC}"
        echo -e "${YELLOW}If you need to undo this force pu, you might need to contact repository administrators.${NC}"
    else
        echo -e "${RED}Error: Force pu failed${NC}"
        echo -e "${YELLOW}Try running './git-automation. auth' first${NC}"
        exit 1
    fi
}

git_branch() {
    local branch_name="$1"
    local base_branch="$2"
    
    if [ -z "$branch_name" ]; then
        echo -e "${RED}Error: Missing branch name${NC}"
        echo "Usage: $(basename $0) branch [name] [base_branch]"
        exit 1
    fi
    
    if [ -z "$base_branch" ]; then
        base_branch=$(select_branch "Select base branch for '$branch_name'" "main")
    fi
    
    confirm_changes "create new branch '$branch_name'" "Based on: $base_branch" || exit 0
    
    echo -e "${YELLOW}Creating branch '$branch_name' from '$base_branch'...${NC}"
    
    git checkout $base_branch
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error: Could not checkout base branch $base_branch${NC}"
        exit 1
    fi
    
    git pull origin $base_branch
    if [ $? -ne 0 ]; then
        echo -e "${YELLOW}Warning: Failed to pull latest changes from $base_branch${NC}"
    fi
    
    git checkout -b $branch_name
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Successfully created and checked out branch '$branch_name'${NC}"
    else
        echo -e "${RED}Error: Failed to create branch '$branch_name'${NC}"
        exit 1
    fi
}

git_checkout() {
    local branch="$1"
    
    if [ -z "$branch" ]; then
        branch=$(select_branch "Select branch to checkout" "main")
    fi
    
    if [ -n "$(git status --porcelain)" ]; then
        echo -e "${YELLOW}Uncommitted changes detected. Options:${NC}"
        echo "1) Sta changes"
        echo "2) Keep working (might cause conflicts)"
        echo "3) Cancel checkout"
        
        read -p "Select option [1-3]: " option
        
        case $option in
            1)
                git sta pu -m "Auto-sta before checkout to $branch"
                echo -e "${YELLOW}Changes staed. Use 'git sta pop' to recover them later.${NC}"
                ;;
            2)
                echo -e "${YELLOW}Keeping changes. Checkout will fail if there are conflicts.${NC}"
                ;;
            3|*)
                echo -e "${YELLOW}Checkout cancelled.${NC}"
                exit 0
                ;;
        esac
    fi
    
    echo -e "${YELLOW}Checking out branch '$branch'...${NC}"
    git checkout $branch
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Successfully checked out branch '$branch'${NC}"
    else
        echo -e "${RED}Error: Failed to checkout branch '$branch'${NC}"
        exit 1
    fi
}

git_rollback() {
    local target="$1"
    local message="$2"
    
    if [ -z "$target" ]; then
        echo -e "${RED}Error: Missing rollback target${NC}"
        echo "Usage: $(basename $0) rollback [file/commit] [message]"
        exit 1
    fi
    
    if [ -z "$message" ]; then
        message="Rollback of $target on $(date)"
    fi
    
    local current_commit=$(git rev-parse HEAD)
    
    if [ -f "$target" ]; then
        echo -e "${YELLOW}Rolling back file: $target${NC}"
        
        echo -e "${YELLOW}Changes that will be discarded:${NC}"
        git diff "$target"
        
        confirm_changes "rollback file $target" "All changes to this file will be lost!" || exit 0
        
        git checkout -- "$target"
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Successfully rolled back $target${NC}"
            
            echo -e "${YELLOW}Committing rollback...${NC}"
            git add "$target"
            git commit -m "$message"
            
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}Successfully committed rollback${NC}"
                echo -e "${YELLOW}If you need to undo this rollback, run:${NC}"
                echo -e "${BLUE}./git-automation. rollback $current_commit \"Undo rollback\"${NC}"
            else
                echo -e "${RED}Error: Failed to commit rollback${NC}"
                exit 1
            fi
        else
            echo -e "${RED}Error: Failed to rollback $target${NC}"
            exit 1
        fi
    else
        echo -e "${YELLOW}Rolling back to commit: $target${NC}"
        
        echo -e "${YELLOW}Commits that will be discarded:${NC}"
        git log --oneline $target..HEAD
        
        confirm_changes "rollback to commit $target" "ALL CHANGES AFTER THIS COMMIT WILL BE LOST!" || exit 0
        
        git reset --hard $target
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Successfully rolled back to commit $target${NC}"
            
            echo -e "${YELLOW}Committing rollback state...${NC}"
            git commit -m "$message" --allow-empty
            
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}Successfully committed rollback state${NC}"
                echo -e "${YELLOW}Original state was at commit $current_commit${NC}"
                echo -e "${YELLOW}To examine the discarded changes: git log $target..$current_commit${NC}"
            else
                echo -e "${RED}Error: Failed to commit rollback state${NC}"
                exit 1
            fi
            
            echo -e "${YELLOW}Warning: This was a hard reset. Use 'git pu --force' if you need to update remote.${NC}"
        else
            echo -e "${RED}Error: Failed to rollback to commit $target${NC}"
            exit 1
        fi
    fi
}

git_set_repo() {
    local new_url="$1"
    
    if [ -z "$new_url" ]; then
        new_url=$(select_repository)
    fi
    
    local current_url=$(git remote get-url origin 2>/dev/null || echo "Not set")
    if [ "$new_url" = "$current_url" ]; then
        echo -e "${YELLOW}Repository URL unchanged: $new_url${NC}"
        return 0
    fi
    
    confirm_changes "set repository URL" "$new_url" || exit 0
    
    echo -e "${YELLOW}Updating repository URL to: $new_url${NC}"
    
    GITHUB_REPO_URL="$new_url"
    
    if git remote | grep -q "^origin$"; then
        git remote set-url origin "$new_url"
    else
        git remote add origin "$new_url"
    fi
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Repository URL updated successfully${NC}"
        
        if [ -n "$new_url" ]; then
            echo "$new_url" > "$REPO_HISTORY_FILE.tmp"
            cat "$REPO_HISTORY_FILE" >> "$REPO_HISTORY_FILE.tmp"
            mv "$REPO_HISTORY_FILE.tmp" "$REPO_HISTORY_FILE"
        fi
        
        sed -i "s|^GITHUB_REPO_URL=.*$|GITHUB_REPO_URL=\"$new_url\"|" "$0"
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Script updated with new repository URL${NC}"
        else
            echo -e "${YELLOW}Warning: Could not update script file. Changes will only apply to this session.${NC}"
        fi
    else
        echo -e "${RED}Failed to update repository URL${NC}"
        exit 1
    fi
}

check_git_repo() {
    if [ ! -d .git ]; then
        echo -e "${RED}Error: Not a git repository${NC}"
        echo "Please run this script from the root of your git repository."
        exit 1
    fi
}

git_auth() {
    echo -e "${YELLOW}Setting up Git authentication...${NC}"
    
    git config --global credential.helper "cache --timeout=$CREDENTIAL_CACHE_TIMEOUT"
    
    echo -e "${YELLOW}Please enter your GitHub credentials when prompted${NC}"
    echo -e "${YELLOW}Credentials will be cached for $CREDENTIAL_CACHE_TIMEOUT seconds${NC}"
    
    git fetch origin
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Authentication successful. Credentials cached.${NC}"
    else
        echo -e "${RED}Authentication failed.${NC}"
        echo "If you're using 2FA, you ould create a personal access token and use it as your password."
        echo "Visit: https://github.com/settings/tokens to create a token."
        exit 1
    fi
}

git_init() {
    echo -e "${YELLOW}Initializing repository...${NC}"

    if [ ! -d .git ]; then
        git init
        echo -e "${GREEN}Git repository initialized.${NC}"
    else
        echo -e "${YELLOW}Repository already initialized.${NC}"
    fi

    # Check if remote 'origin' exists
    if git remote | grep -q "^origin$"; then
        current_remote_url=$(git remote get-url origin)
        if [ "$current_remote_url" == "$GITHUB_REPO_URL" ]; then
            echo -e "${GREEN}Remote 'origin' already set to $GITHUB_REPO_URL.${NC}"
        else
            echo -e "${YELLOW}Remote 'origin' currently points to: $current_remote_url${NC}"
            read -r -p "Do you want to update it to $GITHUB_REPO_URL? (y/N): " confirm_update_remote
            if [[ "$confirm_update_remote" =~ ^[Yy]$ ]]; then
                git remote set-url origin "$GITHUB_REPO_URL"
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}Remote 'origin' updated to $GITHUB_REPO_URL.${NC}"
                else
                    echo -e "${RED}Failed to update remote 'origin' URL.${NC}"
                    exit 1
                fi
            else
                echo -e "${YELLOW}Remote 'origin' URL not changed. Current remote is $current_remote_url.${NC}"
            fi
        fi
    else
        # Remote 'origin' does not exist, add it
        echo -e "${YELLOW}Adding remote 'origin' with URL: $GITHUB_REPO_URL${NC}"
        git remote add origin "$GITHUB_REPO_URL"
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Remote 'origin' added and set to $GITHUB_REPO_URL.${NC}"
        else
            echo -e "${RED}Failed to add remote 'origin'.${NC}"
            exit 1
        fi
    fi
}

# Main script
# We can skip the git repo check for init and auth commands
if [ "$1" = "init" ]; then
    git_init
    exit 0
elif [ "$1" = "auth" ]; then
    git_auth
    exit 0
fi

check_git_repo

case "$1" in
    "commit")
        git_commit "$2" "$3"
        ;;
    "pu")
        git_pu "$2"
        ;;
    "force-pu")
        git_force_pu "$2"
        ;;
    "branch")
        git_branch "$2" "$3"
        ;;
    "rollback")
        git_rollback "$2" "$3"
        ;;
    "status")
        git_status
        ;;
    "pull")
        git_pull
        ;;
    "merge")
        git_merge "$2"
        ;;
    "tag")
        git_tag "$2" "$3"
        ;;
    "sta")
        git_sta "$2" "$3"
        ;;
    "log")
        git_log "$2"
        ;;
    "cleanup")
        git_cleanup
        ;;
    "set-repo")
        git_set_repo "$2"
        ;;
    "checkout")
        git_checkout "$2"
        ;;
    "help"|"")
        print_usage
        ;;
    *)
        echo -e "${RED}Error: Unknown command $1${NC}"
        print_usage
        exit 1
        ;;
esac

exit 0