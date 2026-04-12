#!/usr/bin/env bash
set -euo pipefail

readonly CONFIG_DIR="$HOME/.config"
readonly FONT_DIR="$HOME/.local/share/fonts"
readonly TEMP_DIR="$HOME/tmp"
readonly NVIM_REPO_URL="https://github.com/0xEdvinas/nvim.git"
readonly DOTFILES_REPO_URL="https://github.com/0xEdvinas/dotfiles.git"

require_fedora() {
    if [[ -r /etc/os-release ]]; then
        # shellcheck disable=SC1091
        source /etc/os-release
    fi

    if [[ "${ID:-}" != "fedora" ]]; then
        echo "This script currently targets Fedora only."
        exit 1
    fi
}

write_locale_config() {
    mkdir -p "$CONFIG_DIR"

    cat <<'EOF' > "$CONFIG_DIR/locale.conf"
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
}

write_keyboard_config() {
    mkdir -p "$CONFIG_DIR"

    cat <<'EOF' > "$CONFIG_DIR/kxkbrc"
[Layout]
DisplayNames=
LayoutList=us,lt,ru
Use=true
VariantList=
Options=grp:win_space_toggle
EOF
}

fedora_update_system() {
    sudo timedatectl set-timezone Europe/Vilnius
    sudo dnf update -y
    flatpak update -y
}

fedora_enable_repositories() {
    sudo dnf install -y \
        "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
        "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"
    sudo dnf groupupdate core -y
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
}

fedora_install_fonts() {
    sudo dnf install -y wget unzip fontawesome-fonts

    mkdir -p "$FONT_DIR"
    pushd "$FONT_DIR" >/dev/null

    for font_name in JetBrainsMono FiraCode; do
        wget "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${font_name}.zip"
        unzip "${font_name}.zip" -d "$font_name"
        rm "${font_name}.zip"
    done

    popd >/dev/null
    fc-cache -fv
}

fedora_setup_zsh() {
    sudo dnf install -y zsh
    chsh -s "$(command -v zsh)"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
}

fedora_install_zsh_plugins() {
    local plugins_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"

    mkdir -p "$plugins_dir"

    if [[ ! -d "$plugins_dir/zsh-autosuggestions" ]]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions "$plugins_dir/zsh-autosuggestions"
    fi

    if [[ ! -d "$plugins_dir/zsh-syntax-highlighting" ]]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting "$plugins_dir/zsh-syntax-highlighting"
    fi
}

fedora_remove_debloat_packages() {
    sudo dnf remove -y firefox 'libreoffice*'
    sudo dnf remove -y akregator dragon elisa-player mediawriter kmahjongg kmines kmouth kpat krfb neochat krdc kwrite
}

fedora_install_daily_apps() {
    sudo dnf install -y vlc fooyin qbittorrent fastfetch htop vim neovim ranger git kate
    flatpak install -y flathub com.google.Chrome org.mozilla.firefox com.bitwarden.desktop org.libreoffice.LibreOffice
}

fedora_setup_docker() {
    sudo dnf remove -y \
        docker \
        docker-client \
        docker-client-latest \
        docker-common \
        docker-latest \
        docker-latest-logrotate \
        docker-logrotate \
        docker-engine

    sudo dnf install -y dnf-plugins-core
    sudo dnf config-manager addrepo --from-repofile=https://download.docker.com/linux/fedora/docker-ce.repo
    sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo systemctl enable --now docker
    sudo usermod -aG docker "$USER"
}

fedora_install_dev_tools() {
    flatpak install -y flathub \
        com.visualstudio.code \
        com.google.AndroidStudio \
        com.jetbrains.PyCharm-Professional \
        com.jetbrains.IntelliJ-IDEA-Community \
        com.jetbrains.WebStorm \
        com.jetbrains.CLion \
        com.jetbrains.Rider \
        com.jetbrains.DataGrip \
        com.jetbrains.PhpStorm \
        com.jetbrains.RustRover \
        com.jetbrains.GoLand \
        cc.arduino.IDE2 \
        io.dbeaver.DBeaverCommunity

    sudo dnf install -y python3 python3-pip
    sudo dnf install -y \
        gcc gcc-c++ binutils glibc-devel glibc-headers libstdc++-devel libstdc++-static \
        make automake autoconf libtool pkgconf pkgconf-pkg-config \
        gdb lldb \
        cmake ninja-build \
        cppcheck clang clang-tools-extra clang-format clang-tidy \
        valgrind perf \
        zlib-devel openssl-devel libcurl-devel \
        libatomic libatomic_ops-devel \
        gtest-devel gmock-devel catch-devel

    git config --global user.name "Edvinas Bureika"
    git config --global user.email "edvinasbureika@gmail.com"
}

fedora_setup_virtualization() {
    sudo dnf install -y qemu-kvm libvirt virt-manager virt-viewer spice-vdagent
    sudo dnf group install --with-optional virtualization -y
    sudo systemctl enable --now libvirtd
    sudo usermod -aG libvirt,kvm "$USER"

    if ! sudo virsh net-info default | grep -q '^Active: *yes$'; then
        sudo virsh net-start default
    fi

    sudo virsh net-autostart default
}

create_filesystem_layout() {
    mkdir -p "$HOME"/{Binaries/{Applications,Games},Personal/{IDs,ProfessionalPhotos,Finance},Programming/{Personal,Freelance,Learning,Tools,Experiments,Archive},Torrents/{Complete,Incomplete},ISO,Books/{Audio,Text},tmp}
}

clone_or_update_repo() {
    local repo_url="$1"
    local destination="$2"

    if [[ -d "$destination/.git" ]]; then
        git -C "$destination" pull --ff-only
    else
        rm -rf "$destination"
        git clone "$repo_url" "$destination"
    fi
}

fedora_load_configs() {
    clone_or_update_repo "$NVIM_REPO_URL" "$CONFIG_DIR/nvim"

    mkdir -p "$TEMP_DIR"
    pushd "$TEMP_DIR" >/dev/null
    clone_or_update_repo "$DOTFILES_REPO_URL" "$TEMP_DIR/dotfiles"
    chmod +x ./dotfiles/setup.sh
    ./dotfiles/setup.sh
    popd >/dev/null
}

fedora_install_optional_components() {
    local answer

    read -r -p "Do you want to install HyperLand and its config? (y/n) " answer
    if [[ "$answer" == [yY] ]]; then
        echo "Installing HyperLand..."
    fi

    read -r -p "Do you want to install Single Gpu Passthrough QEMU hooks? (y/n) " answer
    if [[ "$answer" == [yY] ]]; then
        echo "Installing QEMU Hooks"
    fi
}

setup_fedora() {
    fedora_update_system
    write_locale_config
    write_keyboard_config
    fedora_enable_repositories
    fedora_install_fonts
    fedora_setup_zsh
    fedora_install_zsh_plugins
    fedora_remove_debloat_packages
    fedora_install_daily_apps
    fedora_setup_docker
    fedora_install_dev_tools
    fedora_setup_virtualization
    create_filesystem_layout
    fedora_load_configs
    fedora_install_optional_components
}

main() {
    require_fedora
    setup_fedora
}

main "$@"