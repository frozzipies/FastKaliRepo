#!/bin/bash

# Root Checker
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root. Please use 'sudo' or log in as root."
  exit 1
fi

# Function to clear the terminal
clear_terminal() {
  clear
}

# Custom text to be displayed before the menu
custom_text() {
  echo ""
  echo " _____         _     _  __     _ _   ____                  "
  echo "|  ___|_ _ ___| |_  | |/ /__ _| (_) |  _ \ ___ _ __   ___  "
  echo "| |_ / _\` / __| __| | ' // _\` | | | | |_) / _ \ '_ \ / _ \ "
  echo "|  _| (_| \__ \ |_  | . \ (_| | | | |  _ <  __/ |_) | (_) |"
  echo "|_|  \__,_|___/\__| |_|\_\__,_|_|_| |_| \_\___| .__/ \___/ "
  echo "                                              |_|          "
  echo ""
}

# Function to fix the Kali Linux repository
speed_up_repository() {
  # Backup the original sources.list file if it hasn't been backed up yet
  if [ ! -f /etc/apt/sources.list.bak ]; then
    cp /etc/apt/sources.list /etc/apt/sources.list.bak
    echo "Original sources.list file has been backed up as sources.list.bak."
  else
    echo "Backup of the original sources.list file (sources.list.bak) already exists."
  fi

  # Define the new repository lines
  new_lines=(
    "deb https://mirrors.ocf.berkeley.edu/kali/ kali-rolling main contrib non-free"
    "# For source package access, uncomment the following line"
    "# deb-src https://mirrors.ocf.berkeley.edu/kali/ kali-rolling main contrib non-free"
  )

  # Create a temporary file to store the modified content
  temp_file=$(mktemp)

  # Loop through the original sources.list file, commenting out each line
  while IFS= read -r line; do
    echo "# $line" >> "$temp_file"
  done < "/etc/apt/sources.list"

  # Append the new lines to the temporary file
  for new_line in "${new_lines[@]}"; do
    echo "$new_line" >> "$temp_file"
  done

  # Overwrite the original sources.list file with the modified content
  mv "$temp_file" "/etc/apt/sources.list"

  # Cleanup temporary file
  rm -f "$temp_file"

  # Clean the package cache
  sudo apt clean

  # Clear the terminal
  clear_terminal

  # Display the custom text
  custom_text

  echo "Repository configuration updated, and package cache cleaned."
}

# Function to add Kali repository to non-Kali distros
add_kali_repository_non_kali() {
  echo "Install Kali Repo"

  set -x  # Enable command echoing

  # Update repositories
  echo "Running: sudo apt update"
  sudo apt update

  # Upgrade packages
  echo "Running: sudo apt upgrade"
  sudo apt upgrade
  echo "Running: sudo apt dist-upgrade"
  sudo apt dist-upgrade

  # Install required packages
  echo "Running: sudo apt install curl wget gnupg git"
  sudo apt install curl wget gnupg git

  # Add Kali Linux repository key
  echo "Running: wget -q -O - https://archive.kali.org/archive-key.asc | sudo apt-key add"
  wget -q -O - https://archive.kali.org/archive-key.asc | sudo apt-key add

  # Add Kali Linux repository to sources list
  echo "Running: sudo sh -c \"echo 'deb https://http.kali.org/kali kali-rolling main non-free contrib' > /etc/apt/sources.list.d/kali.list\""
  sudo sh -c "echo 'deb https://http.kali.org/kali kali-rolling main non-free contrib' > /etc/apt/sources.list.d/kali.list"

  # Set package preferences for Kali Linux
  echo "Running: sudo sh -c \"echo 'Package: *' > /etc/apt/preferences.d/kali.pref; echo 'Pin: release a=kali-rolling' >> /etc/apt/preferences.d/kali.pref; echo 'Pin-Priority: 50' >> /etc/apt/preferences.d/kali.pref\""
  sudo sh -c "echo 'Package: *' > /etc/apt/preferences.d/kali.pref; echo 'Pin: release a=kali-rolling' >> /etc/apt/preferences.d/kali.pref; echo 'Pin-Priority: 50' >> /etc/apt/preferences.d/kali.pref"

  # Download and install Kali Linux archive keyring
  echo "Running: wget http://http.kali.org/kali/pool/main/k/kali-archive-keyring/kali-archive-keyring_2022.1_all.deb"
  wget http://http.kali.org/kali/pool/main/k/kali-archive-keyring/kali-archive-keyring_2022.1_all.deb
  echo "Running: sudo dpkg -i kali-archive-keyring_2022.1_all.deb"
  sudo dpkg -i kali-archive-keyring_2022.1_all.deb
  echo "Running: rm kali-archive-keyring_2022.1_all.deb"
  rm kali-archive-keyring_2022.1_all.deb

  # Update repositories again
  echo "Running: sudo apt update"
  sudo apt update
  echo "Running: sudo apt update --fix-missing"
  sudo apt update --fix-missing

  # Fix any broken dependencies
  echo "Running: sudo apt install -f"
  sudo apt install -f
  echo "Running: sudo apt --fix-broken install"
  sudo apt --fix-broken install

  # Upgrade packages
  echo "Running: sudo apt upgrade"
  sudo apt upgrade

  set +x  # Disable command echoing
}

# Function to update the repository
update_repository() {
  sudo apt update
  # Clear the terminal
  clear_terminal

  # Display the custom text
  custom_text

  echo "Repository has been updated."
}

# Function to update and upgrade the repository
update_and_upgrade_repository() {
  sudo apt update && sudo apt upgrade -y
  # Clear the terminal
  clear_terminal

  # Display the custom text
  custom_text

  echo "Repository has been updated and upgraded."
}

# Function to revert to the old repository
revert_to_old_repository() {
  if [ -f /etc/apt/sources.list.bak ]; then
    cp /etc/apt/sources.list.bak /etc/apt/sources.list
    # Clear the terminal
    clear_terminal

    # Display the custom text
    custom_text

    echo "Repository has been reverted to the old configuration from sources.list.bak."
  else
    # Clear the terminal
    clear_terminal

    # Display the custom text
    custom_text

    echo "No backup of the original sources.list file found. Cannot revert."
  fi
}

# Function to clear the terminal and display the custom text
clear_terminal
custom_text

# Start an infinite loop to keep the script running
while true; do
  # Display the menu and get user input
  echo "Choose an option:"
  echo "1. Speed up your Kali Repository"
  echo "2. Add Kali Repository (for non-Kali Distro)"
  echo "3. Update & Upgrade Repository"
  echo "4. Update Repository"
  echo "5. Back to Old Repository"
  echo "6. Exit"
  read -p "Enter your choice: " choice

  # Process the user's choice
  case $choice in
    1)
      speed_up_repository
      ;;
    2)
      add_kali_repository_non_kali
      ;;
    3)
      update_and_upgrade_repository
      ;;
    4)
      update_repository
      ;;
    5)
      revert_to_old_repository
      ;;
    6)
      echo "Exiting."
      exit 0  # Exit the script
      ;;
    *)
      echo "Invalid choice. Please try again."
      ;;
  esac
done
