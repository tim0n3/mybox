#!/bin/bash

# Check for root or sudo permissions
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root or with sudo."
    exit
fi

# Check system type
system=`uname -s`

# Function to install system security updates
function update_system {
    if [[ $system == "Linux" ]]; then
        distro=`cat /etc/*-release | grep -o "ID=.*" | awk -F'=' '{print $2}'`
        if [[ $distro == "debian" || $distro == "rhel" ]]; then
            echo "Updating system..."
            apt-get update && apt-get upgrade -y
        else
            echo "System update not supported for this distribution"
        fi
    else
        echo "System update not supported for this OS"
    fi
}

# Function to install Plex Media Server
function install_plex {
    echo "Installing Plex Media Server..."
    if command -v apt-get > /dev/null; then
        apt-get install plexmediaserver -y
    elif command -v yum > /dev/null; then
        yum install plexmediaserver -y
    else
        echo "Please manually install Plex Media Server from https://www.plex.tv/media-server-downloads/"
    fi
}

# Function to install Transmission
function install_transmission {
    echo "Installing Transmission..."
    if command -v apt-get > /dev/null; then
        apt-get install transmission-daemon transmission-cli transmission-common transmission-web -y
    elif command -v yum > /dev/null; then
        yum install transmission-daemon transmission-cli transmission-common transmission-web -y
    else
        echo "Transmission installation not supported for this package manager"
    fi
    systemctl start transmission-daemon
}

# Function to add new user and chroot-jail
function add_user {
    echo "Adding new user..."
    echo "Enter new username:"
    read username
    echo "Enter new user password:"
    read -s password
    useradd -m $username
    echo "$username:$password" | chpasswd
    chown root:root /home/$username
    chmod 755 /home/$username
    echo "User added and chroot-jailed to /home/$username"
}

# Function to install netdata
function install_netdata {
    echo "Installing Netdata..."
    if command -v apt-get > /dev/null; then
        apt-get install netdata -y
    elif command -v yum > /dev/null; then
        yum install netdata -y
    else
        echo "Netdata installation not supported for this package manager"
    fi
    systemctl start netdata
}

# Function to delete user
function delete_user {
    echo "Enter username to delete:"
    read user_to_delete
    userdel $user_to_delete
    echo "User $user_to_delete deleted."
}

function check_distribution {
    distro=$(uname -a)
    if [[ "$distro" == *"Debian"* ]]; then
        # NCurses menu to display options
        while true; do
            choice=$(whiptail --title "System Setup Menu" --menu "Select an option:" 15 60 7 \
            "1" "Install system security updates" \
            "2" "Install Plex Media Server" \
            "3" "Install Transmission" \
            "4" "Add new user and chroot-jail" \
            "5" "Install Netdata" \
            "6" "Delete user" \
            "7" "Exit"  3>&1 1>&2 2>&3)

            case $choice in
                1) update_system;;
                2) install_plex;;
                3) install_transmission;;
                4) add_user;;
                5) install_netdata;;
                6) delete_user;;
                7) exit;;
                *) echo "Invalid option. Please try again.";;
            esac
        done
    elif [[ "$distro" == *"Red Hat"* ]]; then
        # NCurses menu to display options
        while true; do
            choice=$(dialog --title "System Setup Menu" --menu "Select an option:" 15 60 7 \
            "1" "Install system security updates" \
            "2" "Install Plex Media Server" \
            "3" "Install Transmission" \
            "4" "Add new user and chroot-jail" \
            "5" "Install Netdata" \
            "6" "Delete user" \
            "7" "Exit"  3>&1 1>&2 2>&3)

            case $choice in
                1) update_system;;
                2) install_plex;;
                3) install_transmission;;
                4) add_user;;
                5) install_netdata;;
                6) delete_user;;
                7) exit;;
                *) echo "Invalid option. Please try again.";;
            esac
        done
    fi