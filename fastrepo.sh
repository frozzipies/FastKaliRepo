#!/bin/bash

# Check if the script is run as root
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
  echo "2. Update & Upgrade Repository"
  echo "3. Update Repository"
  echo "4. Back to Old Repository"
  echo "5. Exit"
  read -p "Enter your choice: " choice

  # Process the user's choice
  case $choice in
    1)
      speed_up_repository
      ;;
    2)
      update_and_upgrade_repository
      ;;
    3)
      update_repository
      ;;
    4)
      revert_to_old_repository
      ;;
    5)
      echo "Exiting."
      exit 0  # Exit the script
      ;;
    *)
      echo "Invalid choice. Please try again."
      ;;
  esac
done
