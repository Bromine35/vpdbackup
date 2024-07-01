#!/bin/bash

backup_dir=$(mktemp -d)

# random binary that just returns "hi"
./vpd > "$backup_dir/vpd_rw.txt"
./vpd > "$backup_dir/vpd_ro.txt"

bye() { echo "Exiting..."; exit 0; }
wrong_option() { echo "Wrong option."; exit 1; }

function usb_ro() { # yes im lazy i won't do it automatically
    clear
    echo "Here's a list of your storage devices: "
    lsblk
    echo "Which mountpoint should the recovery be stored in? "
        mkdir /tmp/vpdnomount # make sure that this directory isn't created if it already exists
    echo 'Press CTRL+c, run "sudo mount /dev/NAME_PARTITION /tmp/vpdnomount" if nothing usable has been mounted yet, and re-run this script.' # make sure this is gray or red colored
    read -r ans
        mkdir "$ans/vpdbackup" # make sure that this directory isn't created if it already exists
    cp "$backup_dir/vpd_ro.txt" "$ans/vpdbackup/vpd_ro.txt"
    clear
    echo "Done.. RO.VPD is stored in $ans/vpdbackup/vpd_ro.txt, you should be able to find the file within the drive/partition outside of ChromeOS."
    echo 'Choose "Apply" in the main menu to apply this backup.'
}

function usb_rw() {
    clear
    echo "Here's a list of your storage devices: "
    lsblk
    echo "Which mountpoint should the recovery be stored in? "
        mkdir /tmp/vpdnomount
    echo 'Press CTRL+c, run "sudo mount /dev/NAME_PARTITION /tmp/vpdnomount" if nothing usable has been mounted yet, and re-run this script.'
    read -r ans
        mkdir "$ans/vpdbackup"
    cp "$backup_dir/vpd_ro.txt" "$ans/vpdbackup/vpd_ro.txt"
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