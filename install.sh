#!/bin/bash

# install.sh
# Sets up dotfiles symlinks.

CONFIG_DIR="$HOME/.config"
SHARE_DIR="$HOME/.local/share"
YOLO=false
DRY_RUN=false

# Colors for pretty output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERR]${NC} $1"; }
log_dry() { echo -e "${YELLOW}[DRY-RUN]${NC} $1"; }

usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  --yolo      Overwrite existing configurations without asking (NO BACKUP)."
    echo "  --dry-run   Simulate the installation without making changes."
    echo "  --help      Show this help message."
    exit 0
}

# Parse arguments
for arg in "$@"; do
    case "$arg" in
        --yolo)
            YOLO=true
            ;;
        --dry-run)
            DRY_RUN=true
            ;;
        --help)
            usage
            ;;
    esac
done

# Function to link a source to a destination
link_item() {
    local source="$1"
    local dest="$2"
    local name=$(basename "$source")

    # check if source exists
    if [ ! -e "$source" ]; then
        log_error "Source $source does not exist. Skipping."
        return
    fi
    
    # Resolve absolute path for source
    source="$(readlink -f "$source")"

    # Check if destination exists
    if [ -e "$dest" ] || [ -L "$dest" ]; then
        # Check if it's already a symlink to the correct place
        if [ -L "$dest" ] && [ "$(readlink -f "$dest")" == "$source" ]; then
            log_success "$name is already correctly linked."
            return
        fi

        # Collision detected
        if [ "$DRY_RUN" = true ]; then
             if [ "$YOLO" = true ]; then
                log_dry "Collision for $name. Would overwrite (--yolo)."
             else
                log_dry "Collision for $name. Would ask user."
             fi
             return
        fi

        if [ "$YOLO" = true ]; then
            log_warn "Collision for $name. --yolo: Overwriting."
            rm -rf "$dest"
            ln -s "$source" "$dest"
            log_success "Linked $name"
            return
        else
            log_warn "$dest already exists."
            echo -ne "  What do you want to do? [s]kip, [o]verwrite, [b]ackup? "
            read -r choice
            case "$choice" in
                o|O)
                    rm -rf "$dest"
                    ln -s "$source" "$dest"
                    log_success "Overwrote and linked $name"
                    ;;
                b|B)
                    mv "$dest" "${dest}.bak.$(date +%s)"
                    ln -s "$source" "$dest"
                    log_success "Backed up and linked $name"
                    ;;
                *)
                    log_info "Skipping $name"
                    ;;
            esac
            return
        fi
    fi

    # No collision, just link
    if [ "$DRY_RUN" = true ]; then
        log_dry "Would link $source -> $dest"
        return
    fi

    ln -s "$source" "$dest"
    log_success "Linked $name"
}

# Function to link a file with elevated privileges (pkexec)
link_with_privilege() {
    local source="$1"
    local dest="$2"
    local name=$(basename "$source")

    log_info "Processing system file: $name"

    # Resolve absolute path for source because pkexec runs in a different context
    local abs_source="$(readlink -f "$source")"

    if [ "$DRY_RUN" = true ]; then
        log_dry "Would use sudo to link $abs_source -> $dest"
        return
    fi
    
    # We use a single sudo call per file for clarity, or we could batch them if passed as array
    # But adhering to 'simple arguments', we do one at a time.
    log_warn "Need root privileges to link $name to $dest."
    sudo ln -sf "$abs_source" "$dest"

    if [ $? -eq 0 ]; then
        log_success "Linked $name (privileged)"
    else
        log_error "Failed to link $name"
    fi
}

# --- Main Execution ---

# Ensure target parent directories exist
if [ "$DRY_RUN" = true ]; then
    log_dry "Would ensure directory exists: $CONFIG_DIR"
    log_dry "Would ensure directory exists: $SHARE_DIR"
else
    mkdir -p "$CONFIG_DIR"
    mkdir -p "$SHARE_DIR"
fi

# List of folders to ignore in the root directory
IGNORE_DIRS=(".git" ".")

log_info "Processing dotfiles..."
for dir in ./*/; do
    dirname=$(basename "$dir")
    
    # Check if directory is in ignore list
    skip=false
    for ignore in "${IGNORE_DIRS[@]}"; do
        if [ "$dirname" == "$ignore" ]; then
            skip=true
            break
        fi
    done

    if [ "$skip" = true ]; then
        continue
    fi

    # Determine target based on directory name
    if [[ "$dirname" == "icons" || "$dirname" == "applications" ]]; then
        link_item "$dir" "$SHARE_DIR/$dirname"
    elif [[ "$dirname" == "quickshell" ]]; then
        link_item "$dir" "$CONFIG_DIR/$dirname"
        
        # Link specific Quickshell system files
        # Using absolute paths is handled inside the function via readlink -f
        link_with_privilege "./quickshell/90-android.rules" "/etc/udev/rules.d/90-android.rules"
        link_with_privilege "./quickshell/adBat.sh" "/usr/local/bin/adBat.sh"
        
    else
        link_item "$dir" "$CONFIG_DIR/$dirname"
    fi
done

log_info "Done!"
