#!/usr/bin/env bash

#
# Setup and update package managers
#

sudo apt update -y
sudo apt upgrade -y

sudo apt install flatpak -y

sudo apt install plasma-discover-backend-flatpak -y

flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

#
# System
#

sudo timedatectl set-timezone Europe/Vilnius

sudo apt install zsh wget curl vlc qbittorrent fastfetch htop vim neovim ranger git kate tree -y

# Setup global git config
git config --global user.name "Edvinas Bureika"
git config --global user.email "edvinasbureika@gmail.com"

chsh -s "$(command -v zsh)"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools install.sh)" "" --unattended


plugins_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"

mkdir -p "$plugins_dir"

[[ ! -d "$plugins_dir/zsh-autosuggestions" ]] && \
    git clone https://github.com/zsh-users/zsh-autosuggestions "$plugins_dir/zsh-autosuggestions"

[[ ! -d "$plugins_dir/zsh-syntax-highlighting" ]] && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$plugins_dir/zsh-syntax-highlighting"


#
# Install tools
#

sudo apt install git -y

#
# Virtualization
#

sudo apt install -y qemu-kvm libvirt-daemon-system libvirt-clients \
virt-manager virt-viewer spice-vdagent bridge-utils

sudo systemctl enable libvirtd
sudo systemctl start libvirtd

sudo usermod -aG libvirt,kvm $USER

sudo virsh net-start default
sudo virsh net-autostart default


#
# Apps
#

flatpak install -y flathub org.libreoffice.LibreOffice org.fooyin.fooyin org.mozilla.Thunderbird com.google.Chrome org.mozilla.firefox com.bitwarden.desktop

#
# Directories
#

cd ~

mkdir -p Binaries/Applications
mkdir -p Binaries/Games

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
# Fonts
#

sudo apt install fonts-font-awesome

mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts

wget https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
unzip JetBrainsMono.zip -d JetBrainsMono
rm JetBrainsMono.zip

wget https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip
unzip FiraCode.zip -d FiraCode
rm FiraCode.zip

fc-cache -fv

#
# SSH key generation
#
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N "" -q
cat ~/.ssh/id_ed25519.pub
