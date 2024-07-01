#!/bin/bash

backup_dir=$(mktemp -d)

# random binary that just returns "hi"
./vpd > "$backup_dir/vpd_rw.txt"
./vpd > "$backup_dir/vpd_ro.txt"

bye() { echo "Exiting..."; exit 0; }
wrong_option() { echo "Wrong option."; exit 1; }

function usb_ro() { # yes im lazy i won't do it automatically
    clear
    echo -e "\033[0;31mNOTE: Firmware Write-Protect MUST be off for this to apply again.\033[0m"
    echo "Here's a list of your storage devices: "
    lsblk
    echo "Which mountpoint should the recovery be stored in? "
        mkdir -p /tmp/vpdnomount
    echo -e "\033[0;31mPress CTRL+c, run \"sudo mount /dev/NAME_PARTITION /tmp/vpdnomount\" if nothing usable has been mounted yet, and re-run this script.\033[0m"
    echo "An empty answer will be assumed to be / as the backup directory."
    read -r ans
        mkdir -p "$ans/vpdbackup"
    cp "$backup_dir/vpd_ro.txt" "$ans/vpdbackup/vpd_ro.txt"
    clear
    echo "Done.. RO.VPD is stored in $ans/vpdbackup/vpd_ro.txt, you should be able to find the file within the drive/partition outside of ChromeOS."
    echo 'Choose "Apply" in the main menu to apply this backup.'
}

function usb_rw() { # yes im lazy i won't do it automatically
    clear
    echo "Here's a list of your storage devices: "
    lsblk
    echo "Which mountpoint should the recovery be stored in? "
        mkdir -p /tmp/vpdnomount
    echo -e "\033[0;31mPress CTRL+c, run \"sudo mount /dev/NAME_PARTITION /tmp/vpdnomount\" if nothing usable has been mounted yet, and re-run this script.\033[0m"
    echo "An empty answer will be assumed to be / as the backup directory."
    read -r ans
        mkdir -p "$ans/vpdbackup"
    cp "$backup_dir/vpd_rw.txt" "$ans/vpdbackup/vpd_rw.txt"
    clear
    echo "Done.. RO.VPD is stored in $ans/vpdbackup/vpd_ro.txt, you should be able to find the file within the drive/partition outside of ChromeOS."
    echo 'Choose "Apply" in the main menu to apply this backup.'
}

function clearmotto() {
    clear
    echo "VPDBackup - For now, files can be found in $backup_dir"
}

options=("Back up RO/RW VPD to USB" "Apply RW/RO VPD" "Quit VPDBackup")

function backup_vpd {
    echo -ne "
BACKUP

1) Read Write VPD (RW.VPD) to USB
2) Read-only VPD (RO.VPD) to USB
3) Exit

Enter your choice:  "
    read -r ans
    case $ans in
    1)
        usb_rw
        ;;
    2)
        usb_ro
        ;;
    3)
        bye
        ;;
    *)
        wrong_option
        ;;
    esac
}

function apply_vpd {
    echo -ne "
APPLY

1) Read Write VPD (RW.VPD) from USB
2) Read-only VPD (RO.VPD) from USB
3) Exit

Enter your choice:  "
    read -r ans
    case $ans in
    1)
        apply_usb_rw
        ;;
    2)
        apply_usb_ro
        ;;
    3)
        bye
        ;;
    *)
        wrong_option
        ;;
    esac
}

function apply_usb_rw {
    clear
    echo "Here's a list of your storage devices: "
    lsblk
    echo "Which mountpoint/partition is the VPD backup stored in? "
        mkdir -p /tmp/vpdnomount
    echo -e "\033[0;31mPress CTRL+c, and run \"sudo mount /dev/NAME_PARTITION /tmp/vpdnomount\" if your recovery partition hasn't been mounted yet, and re-run this script.\033[0m"
    echo "An empty answer will be assumed to be / as the backup directory."
    read -r ans
    file_path=("$ans/vpdbackup/vpd_rw.txt")
    clear
    while IFS= read -r line; do
        key=$(echo "$line" | cut -d'=' -f1)
        value=$(echo "$line" | cut -d'=' -f2)
        value=$(echo "$value" | xargs)

        vpd -i RW_VPD -s "$key=$value"
    done < "$file_path"
    clear
    echo "Done... the file was parsed and vpd values were applied."
    bye
}

function apply_usb_ro {
    clear
    echo "Here's a list of your storage devices: "
    lsblk
    echo "Which mountpoint/partition is the VPD backup stored in? "
        mkdir -p /tmp/vpdnomount
    echo -e "\033[0;31mPress CTRL+c, and run \"sudo mount /dev/NAME_PARTITION /tmp/vpdnomount\" if your recovery partition hasn't been mounted yet, and re-run this script.\033[0m"
    echo "An empty answer will be assumed to be / as the backup directory."
    read -r ans
    file_path=("$ans/vpdbackup/vpd_ro.txt")
    clear
    while IFS= read -r line; do
        key=$(echo "$line" | cut -d'=' -f1)
        value=$(echo "$line" | cut -d'=' -f2)
        value=$(echo "$value" | xargs)

        vpd -i RW_VPD -s "$key=$value"
    done < "$file_path"
    clear
    echo "Done... the file was parsed and vpd values were applied."
    bye
}

main_menu() {
    echo -ne "
MAIN

1) Back up RO/RW VPD to USB
2) Apply RW/RO VPD
3) Quit VPDBackup

Enter your choice:  "
    read -r ans
    case $ans in
    1)
        clearmotto
        backup_vpd
        ;;
    2)
        clearmotto
        apply_vpd
        ;;
    3)
        bye
        ;;
    *)
        wrong_option
        ;;
    esac
}

clearmotto
main_menu