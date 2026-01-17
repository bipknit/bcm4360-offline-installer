#!/bin/bash

# ==============================================================================
# CONFIGURATION
# ==============================================================================
PKG_DIR="./pkgs"
RPM_SEQUENCE=(
    "libzstd-1.5.7-2.fc43.x86_64.rpm"
    "libzstd-devel-1.5.7-2.fc43.x86_64.rpm"
    "zlib-ng-compat-2.2.5-2.fc43.x86_64.rpm"
    "zlib-ng-compat-devel-2.2.5-2.fc43.x86_64.rpm"
    "make-4.4.1-11.fc43.x86_64.rpm"
    "m4-1.4.20-2.fc43.x86_64.rpm"
    "kernel-headers-6.17.0-63.fc43.x86_64.rpm"
    "libxcrypt-devel-4.4.38-8.fc43.x86_64.rpm glibc-devel-2.42-4.fc43.x86_64.rpm"
    "flex-2.6.4-20.fc43.x86_64.rpm"
    "fakeroot-libs-1.37.1-3.fc43.x86_64.rpm"
    "fakeroot-1.37.1-3.fc43.x86_64.rpm"
    "bison-3.8.2-11.fc43.x86_64.rpm"
    "--replacefiles openssl-libs-3.5.4-1.fc43.x86_64.rpm"
    "openssl-devel-3.5.4-1.fc43.x86_64.rpm"
    "gcc-15.2.1-2.fc43.x86_64.rpm"
    "elfutils-libelf-devel-0.193-3.fc43.x86_64.rpm"
    "kmodtool-1.1-14.fc43.noarch.rpm"
    "dwz-0.16-2.fc43.x86_64.rpm"
    "debugedit-5.2-3.fc43.x86_64.rpm"
    "patch-2.8-2.fc43.x86_64.rpm"
    "systemd-rpm-macros-258-1.fc43.noarch.rpm"
    "elfutils-libelf-devel-0.193-3.fc43.x86_64.rpm"
    "kernel-devel-6.17.1-300.fc43.x86_64.rpm"
    "kernel-devel-matched-6.17.1-300.fc43.x86_64.rpm"
    "python3-rpmautospec-core-0.1.5-8.fc43.noarch.rpm"
    "python3-rpmautospec-0.8.3-2.fc43.noarch.rpm"
    "python3-utils-3.9.1-2.fc43.noarch.rpm"
    "python3-progressbar2-4.5.0-5.fc43.noarch.rpm"
    # End of standard deps, start of deps of redhat-rpm-conf
    "annobin-docs-12.99-1.fc43.noarch.rpm"
    "annobin-plugin-gcc-12.99-1.fc43.x86_64.rpm"
    "gcc-plugin-annobin-15.2.1-2.fc43.x86_64.rpm"
    "ansible-srpm-macros-1-18.1.fc43.noarch.rpm"
    "add-determinism-0.6.0-2.fc43.x86_64.rpm"
    "build-reproducibility-srpm-macros-0.6.0-2.fc43.noarch.rpm"
    "efi-srpm-macros-6-4.fc43.noarch.rpm"
    "filesystem-srpm-macros-3.18-50.fc43.noarch.rpm"
    "fpc-srpm-macros-1.3-15.fc43.noarch.rpm"
    "gap-srpm-macros-2-1.fc43.noarch.rpm"
    "ghc-srpm-macros-1.9.2-3.fc43.noarch.rpm"
    "gnat-srpm-macros-6-8.fc43.noarch.rpm"
    "java-srpm-macros-1-7.fc43.noarch.rpm"
    "kernel-srpm-macros-1.0-27.fc43.noarch.rpm"
    "lua-srpm-macros-1-16.fc43.noarch.rpm"
    "ocaml-srpm-macros-11-2.fc43.noarch.rpm"
    "openblas-srpm-macros-2-20.fc43.noarch.rpm"
    "package-notes-srpm-macros-0.5-14.fc43.noarch.rpm"
    "perl-srpm-macros-1-60.fc43.noarch.rpm"
    "pyproject-srpm-macros-1.18.4-1.fc43.noarch.rpm"
    "qt5-srpm-macros-5.15.17-2.fc43.noarch.rpm"
    "qt6-srpm-macros-6.9.2-1.fc43.noarch.rpm"
    "rust-srpm-macros-26.4-1.fc43.noarch.rpm"
    "tree-sitter-srpm-macros-0.4.2-1.fc43.noarch.rpm"
    "zig-srpm-macros-1-5.fc43.noarch.rpm"
    "gpgverify-2.2-3.fc43.noarch.rpm"
    "go-srpm-macros-3.8.0-1.fc43.noarch.rpm forge-srpm-macros-0.4.0-3.fc43.noarch.rpm fonts-srpm-macros-2.0.5-23.fc43.noarch.rpm python-srpm-macros-3.14-5.fc43.noarch.rpm redhat-rpm-config-343-11.fc43.noarch.rpm"
    #end of redhat rpm conf
    "rpm-build-6.0.0-1.fc43.x86_64.rpm"
    "rpmdevtools-9.6-13.fc43.noarch.rpm"
    "akmods-0.6.2-3.fc43.noarch.rpm"
    "akmod-wl-6.30.223.271-59.fc43.x86_64.rpm kmod-wl-6.30.223.271-59.fc43.x86_64.rpm broadcom-wl-6.30.223.271-27.fc43.noarch.rpm"
)

# Driver blacklist configuration
BLACKLIST_FILE="/etc/modprobe.d/broadcom-wl-blacklist.conf"
CONFLICTING_MODS=("b43" "b43legacy" "ssb" "bcma" "brcmfmac")

# ==============================================================================
# FUNCTIONS
# ==============================================================================

log() { echo -e "\e[32m[INFO]\e[0m $1"; }
warn() { echo -e "\e[33m[WARN]\e[0m $1"; }
error() { echo -e "\e[31m[ERROR]\e[0m $1"; exit 1; }

check_requirements() {
    if [[ $EUID -ne 0 ]]; then error "Run as root (sudo)."; fi
    if [ ! -d "$PKG_DIR" ]; then error "Directory '$PKG_DIR' not found."; fi
}

install_rpms() {
    log "Starting sequential installation..."
    
    for ITEM in "${RPM_SEQUENCE[@]}"; do
        FILES_TO_INSTALL=""
        read -ra PARTS <<< "$ITEM"
        
        for PART in "${PARTS[@]}"; do
            if [[ "$PART" == --* ]]; then
                FILES_TO_INSTALL="$FILES_TO_INSTALL $PART"
                continue
            fi
            if [ ! -f "$PKG_DIR/$PART" ]; then
                error "File not found: $PKG_DIR/$PART"
            fi
            FILES_TO_INSTALL="$FILES_TO_INSTALL $PKG_DIR/$PART"
        done

        log "Processing: $ITEM"
        rpm -ivh --replacepkgs --replacefiles --reinstall --oldpackage $FILES_TO_INSTALL
        
        if [ $? -ne 0 ]; then
            error "Failed to install $ITEM"
        fi
    done
}

configure_modules() {
    log "Unloading conflicting modules..."
    
    # 1. Unload conflicting modules if loaded
    for mod in "${CONFLICTING_MODS[@]}"; do
        if lsmod | grep -q "^$mod"; then
            modprobe -r "$mod" 2>/dev/null || warn "Could not unload $mod"
        fi
    done
    
    if lsmod | grep -q "^wl"; then
        modprobe -r wl 2>/dev/null
    fi

    # 2. Create persistent blacklist
    log "Updating blacklist..."
    {
        echo "# Generated by installer.sh"
        for mod in "${CONFLICTING_MODS[@]}"; do
            echo "blacklist $mod"
        done
    } > "$BLACKLIST_FILE"
}

refresh_system_and_load() {
    log "Refreshing system modules and services..."

    # 1. Update module dependencies
    log "Running depmod -a..."
    depmod -a

    # 2. Force akmods to build just in case the pre-compiled kmod doesn't match the live kernel
    if command -v akmods &> /dev/null; then
        log "Checking/Building kernel modules via akmods..."
        akmods --force || warn "akmods build returned non-zero, hoping kmod-wl suffices."
    fi

    # 3. Load the wl module
    log "Loading wl module..."
    modprobe wl
    
    # Wait a moment for hardware initialization
    sleep 2
    
    if ! lsmod | grep -q "^wl"; then
        error "FAILED: wl module did not load."
    else
        log "SUCCESS: wl module is loaded."
    fi

    # 4. Trigger udev to settle devices
    udevadm settle

    # 5. Restart NetworkManager to pick up the new interface
    log "Restarting NetworkManager..."
    systemctl restart NetworkManager
    
    log "Waiting for NetworkManager to initialize..."
    sleep 5
    
    if systemctl is-active --quiet NetworkManager; then
        log "NetworkManager restarted successfully."
    else
        warn "NetworkManager might not be running correctly. Check 'systemctl status NetworkManager'."
    fi
}

# ==============================================================================
# RUN
# ==============================================================================
check_requirements
install_rpms
configure_modules
refresh_system_and_load

log "Installation Complete. Check your Wi-Fi settings."
