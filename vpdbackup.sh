backup_dir=$(mktemp -d)

vpd -i RW_VPD -l > "$backup_dir/vpd_rw.txt"
vpd -i RO_VPD -l > "$backup_dir/vpd_ro.txt"

echo $backup_dir