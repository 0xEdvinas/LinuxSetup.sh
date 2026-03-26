#!/bin/bash

#
# SYSTEM
#

# Set timezone
sudo timedatectl set-timezone Europe/Vilnius

# Set system language to English but formats to Lithuanian
mkdir -p ~/.config

cat <<EOF > ~/.config/locale.conf
LANG=C.UTF-8
LC_NUMERIC=lt_LT.UTF-8
LC_TIME=lt_LT.UTF-8
LC_MONETARY=lt_LT.UTF-8
LC_PAPER=lt_LT.UTF-8
LC_MEASUREMENT=lt_LT.UTF-8
LC_ADDRESS=lt_LT.UTF-8
LC_IDENTIFICATION=lt_LT.UTF-8
LC_NAME=lt_LT.UTF-8
LC_TELEPHONE=lt_LT.UTF-8
EOF

# Keyboard layouts KDE SPECIFIC!!!
mkdir -p ~/.config

cat <<EOF > ~/.config/kxkbrc
[Layout]
DisplayNames=
LayoutList=us,lt,ru
Use=true
VariantList=
Options=grp:win_space_toggle
EOF

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

sudo dnf install wget unzip -y

# Fonts
sudo dnf install fontawesome-fonts -y

mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts

wget https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
unzip JetBrainsMono.zip -d JetBrainsMono
rm JetBrainsMono.zip

wget https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip
unzip FiraCode.zip -d FiraCode
rm FiraCode.zip

fc-cache -fv
cd ~

# zsh
sudo dnf install zsh -y
chsh -s $(which zsh)
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# ZSH plugins
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

#
# APPS
#

# Debloat
sudo dnf remove firefox libreoffice\* -y
sudo dnf remove akregator dragon elisa-player mediawriter kmahjongg kmines kmouth kpat krfb neochat krdc kwrite


# Install my must have software
sudo dnf install vlc fooyin qbittorrent fastfetch htop vim neovim ranger git kate -y

flatpak install flathub com.google.Chrome org.mozilla.firefox com.bitwarden.desktop org.libreoffice.LibreOffice -y

#
# DEV
#

# Remove old docker packages
sudo dnf remove docker \
                docker-client \
                docker-client-latest \
                docker-common \
                docker-latest \
                docker-latest-logrotate \
                docker-logrotate \
                docker-engine -y

# Required tools
sudo dnf -y install dnf-plugins-core -y

# Docker official repo
sudo dnf config-manager addrepo --from-repofile=https://download.docker.com/linux/fedora/docker-ce.repo

# Install docker engine
sudo dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# Start and enable docker
sudo systemctl start docker
sudo systemctl enable docker

# Run docker without sudo
sudo usermod -aG docker $USER

flatpak install flathub com.visualstudio.code com.google.AndroidStudio com.jetbrains.PyCharm-Professional com.jetbrains.IntelliJ-IDEA-Community com.jetbrains.WebStorm com.jetbrains.CLion com.jetbrains.Rider com.jetbrains.DataGrip com.jetbrains.PhpStorm com.jetbrains.RustRover com.jetbrains.GoLand cc.arduino.IDE2 io.dbeaver.DBeaverCommunity -y

# Py
sudo dnf install python3 python3-pip -y

# C++/C
sudo dnf install \
    gcc gcc-c++ binutils glibc-devel glibc-headers libstdc++-devel libstdc++-static \
    make automake autoconf libtool pkgconf pkgconf-pkg-config \
    gdb lldb \
    cmake ninja-build \
    cppcheck clang clang-tools-extra clang-format clang-tidy \
    valgrind perf \
    zlib-devel openssl-devel libcurl-devel \
    libatomic libatomic_ops-devel \
    gtest-devel gmock-devel catch-devel -y

    # Setup global git config
git config --global user.name "Edvinas Bureika"
git config --global user.email "edvinasbureika@gmail.com"

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

# Autostart network
sudo virsh net-start default
sudo virsh net-autostart default

#
# FILESYSTEM
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
# CONFIG LOADING
#

# Import my nvim config from my github page
rm -rf ~/.config/nvim
git clone https://github.com/0xEdvinas/nvim.git ~/.config/nvim

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


#
# SSH key gen at the end for github
#
