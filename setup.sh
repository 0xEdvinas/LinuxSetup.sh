#!/bin/bash

#
# SYSTEM
#

# Update the system
sudo dnf update -y
flatpak update -y

# Enable RPM fusion(free and non-free) and refresh
sudo dnf install \
https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y
sudo dnf groupupdate core -y

# Add flathub repo for flatpaks
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Install all the codecs
sudo dnf install gstreamer1-plugins-base gstreamer1-plugins-good gstreamer1-plugins-bad-free gstreamer1-plugins-bad-freeworld gstreamer1-plugins-ugly gstreamer1-libav ffmpeg ffmpeg-libs ffmpeg-free lame libdvdcss -y

#
# APPS
#

# Install my must have software
sudo dnf install vlc qbittorrent fastfetch htop vim neovim ranger git -y

#
# DEV
#

# Dev tools
sudo dnf install python3 python3-pip -y

#
# VIRTUALIZATION
#

# QEMU and virt-manager for virtual machines
sudo dnf install qemu-kvm libvirt virt-manager virt-viewer spice-vdagent -y
sudo dnf group install --with-optional virtualization -y

# Enable and start libvirtd
sudo systemctl enable libvirtd
sudo systemctl start libvirtd

# Add user to libvirt and kvm groups
sudo usermod -aG libvirt,kvm $USER

#
# FILESYSTEM
#
cd ~

mkdir -p Personal/IDs
mkdir -p Personal/ProfessionalPhotos
mkdir -p Personal/Finance

mkdir -p Programming/Personal
mkdir -p Programming/Freelance
mkdir -p Programming/Learning
mkdir -p Programming/Tools
mkdir -p Programming/Experiments
mkdir -p Programming/Archive

mkdir -p Torrents/Complete
mkdir -p Torrents/Incomplete

mkdir -p ISO

mkdir -p Books/Audio
mkdir -p Books/Text

mkdir -p tmp/

#
# CONFIG LOADING
#

# Import my nvim config from my github page
rm -rf ~/.config/nvim
git clone https://github.com/0xEdvinas/.nvim.git ~/.config/nvim

# Install hyperland
echo "Do you want to install HyperLand and its config? (y/n)"
read -r install_hyperland
if [[ "$install_hyperland" == "y" || "$install_hyperland" == "Y" ]]; then
    echo "Installing HyperLand..."
fi

# Install QEMU Hooks
echo "Do you want to install Single Gpu Passthrough QEMU hooks? (y/n)"
read -r qemu_hooks
if [[ "$qemu_hooks" == "y" || "$qemu_hooks" == "Y" ]]; then
    echo "Installing QEMU Hooks"
fi
