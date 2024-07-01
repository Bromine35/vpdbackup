file_path="/run/replit/socks/vpdbackup/vpd_ro.txt"

while IFS= read -r line; do
    key=$(echo "$line" | cut -d':' -f1)
    value=$(echo "$line" | cut -d':' -f2 | tr -d '[:space:]')

    echo "Key: $key"
    echo "Value: $value"
done < "$file_path"