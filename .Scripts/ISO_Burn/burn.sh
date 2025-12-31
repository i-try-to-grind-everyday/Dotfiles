#!/usr/bin/env bash

set -Eeuo pipefail

error() {
    echo "❌ Error: $1" >&2
    exit 1
}

show_help() {
    cat <<EOF
Usage: format_iso.sh <disk> <iso>

Arguments:
  <disk>   Target USB or disk to write the ISO (e.g., /dev/sdb)
  <iso>    Path to the ISO file (e.g., archlinux-x86_64.iso)

Options:
  -h, --help, ?     Show this help message

Example:
  format_iso.sh /dev/sdb ~/Downloads/archlinux-x86_64.iso

Notes:
  - This will ERASE all data on the target disk.
  - Use only on removable USB drives, not your system disk.
  - The ISO is written in a UEFI-compatible way.
EOF
}

# --- Help check ---
if [[ $# -eq 0 ]] || [[ "$1" =~ ^(-h|--help|\?)$ ]]; then
    show_help
    exit 0
fi

# --- Argument check ---
[[ $# -eq 2 ]] || error "Invalid number of arguments. Use --help for usage."

DISK="$1"
ISO="$2"

# --- Basic validations ---
[[ -b "$DISK" ]] || error "$DISK is not a block device"
[[ -f "$ISO" ]]  || error "ISO file not found"

# --- Refuse root disk ---
ROOT_DISK="$(lsblk -no pkname "$(findmnt -n -o SOURCE /)")"
[[ "$DISK" == "/dev/$ROOT_DISK" ]] && error "Refusing to wipe root disk"

# --- Warn user ---
echo "⚠️  THIS WILL ERASE: $DISK"
echo "ISO: $ISO"
read -rp "Type YES to continue: " CONFIRM
[[ "$CONFIRM" == "YES" ]] || error "Aborted by user"

# --- Unmount any mounted partitions ---
sudo umount "${DISK}"* 2>/dev/null || true

# --- Write ISO ---
sudo dd if="$ISO" of="$DISK" bs=4M status=progress oflag=sync

# --- Flush writes ---
sync
echo "✅ Done. You can now boot in UEFI mode."

