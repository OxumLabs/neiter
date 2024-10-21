#!/bin/bash

# Set variables
URL="https://github.com/OxumLabs/neit/releases/download/0.0.38.1/neit"
DWNLD_FOLD="/usr/local/bin"
NEIT_BIN="neit"
USER_BASHRC="$HOME/.bashrc"

# Function to pause for user input
pause() {
    read -p "Press [Enter] key to continue..."
}

# Function to print messages with color
print_message() {
    echo -e "\033[1;32m$1\033[0m"  # Green text
}

# Function to print error messages in red
print_error() {
    echo -e "\033[1;31mError: $1\033[0m"  # Red text
}

# Function to show a spinner while waiting
spinner() {
    local pid=$1
    local delay=0.1
    local spin='/-\|'
    local i=0

    while ps -p $pid > /dev/null; do
        local temp=${spin:i++%${#spin}:1}
        echo -ne "\r$temp"
        sleep $delay
    done
    echo -ne "\r"  # Clear the spinner
}

# Check if the script is run with sudo
if [ "$EUID" -ne 0 ]; then
    print_error "Please run this script as root (use sudo)."
    pause
    exit 1
fi

# Check if Neit already exists and remove it
if [ -f "$DWNLD_FOLD/$NEIT_BIN" ]; then
    print_message "Found existing Neit installation. Removing..."
    if rm -f "$DWNLD_FOLD/$NEIT_BIN"; then
        print_message "Old Neit binary removed."
    else
        print_error "Failed to remove old Neit binary."
        pause
        exit 1
    fi
fi

# Download the Neit binary
print_message "Downloading Neit from $URL..."
{
    curl -L "$URL" -o "$DWNLD_FOLD/$NEIT_BIN" &
    spinner $!  # Show spinner while downloading
}
if [ $? -ne 0 ]; then
    print_error "Failed to download Neit. Please check the URL or your internet connection."
    pause
    exit 1
fi

chmod +x "$DWNLD_FOLD/$NEIT_BIN"
print_message "Neit downloaded successfully to $DWNLD_FOLD/$NEIT_BIN."

# Function to install dependencies with customized output
install_dependencies() {
    print_message "Attempting to install Clang and LLD..."

    # Try to install with multiple package managers
    if command -v apt-get > /dev/null; then
        print_message "Using apt-get to install Clang and LLD..."
        echo "Please wait while Clang and LLD are being installed..."
        
        # Customized apt-get output with spinner
        {
            apt-get update -qq && apt-get install -y clang lld -qq
        } &> >(while read -r line; do
            echo -e "\033[1;34m$line\033[0m"  # Blue text for apt output
        done) & spinner $!

    elif command -v dnf > /dev/null; then
        print_message "Using dnf to install Clang and LLD..."
        {
            dnf install -y clang lld
        } &> >(while read -r line; do
            echo -e "\033[1;34m$line\033[0m"  # Blue text for dnf output
        done) & spinner $!

    elif command -v pacman > /dev/null; then
        print_message "Using pacman to install Clang and LLD..."
        {
            pacman -Sy --noconfirm clang lld
        } &> >(while read -r line; do
            echo -e "\033[1;34m$line\033[0m"  # Blue text for pacman output
        done) & spinner $!

    elif command -v zypper > /dev/null; then
        print_message "Using zypper to install Clang and LLD..."
        {
            zypper install -y clang lld
        } &> >(while read -r line; do
            echo -e "\033[1;34m$line\033[0m"  # Blue text for zypper output
        done) & spinner $!

    elif command -v eopkg > /dev/null; then  # Solus
        print_message "Using eopkg to install Clang and LLD..."
        {
            eopkg install -y clang lld
        } &> >(while read -r line; do
            echo -e "\033[1;34m$line\033[0m"  # Blue text for eopkg output
        done) & spinner $!

    elif command -v apk > /dev/null; then  # Alpine
        print_message "Using apk to install Clang and LLD..."
        {
            apk add clang lld
        } &> >(while read -r line; do
            echo -e "\033[1;34m$line\033[0m"  # Blue text for apk output
        done) & spinner $!

    else
        print_error "Linux distribution not recognized. Please install Clang and LLD manually."
        pause
        return
    fi

    if [ $? -ne 0 ]; then
        print_error "Failed to install Clang and LLD. Please check your package manager."
        pause
        exit 1
    fi

    print_message "Clang and LLD installed successfully."
}

# Function to set PATH
set_path() {
    print_message "Adding $DWNLD_FOLD to your PATH..."
    if ! grep -q "$DWNLD_FOLD" "$USER_BASHRC"; then
        echo "export PATH=\$PATH:$DWNLD_FOLD" >> "$USER_BASHRC"
        print_message "Path added. Please run 'source $USER_BASHRC' to update your current session."
    else
        print_message "$DWNLD_FOLD is already in your PATH."
    fi
}

# Main execution
install_dependencies
set_path

# Reload the shell (optional)
print_message "You may need to reload your shell or open a new terminal session."
pause

print_message "Installation completed successfully."
