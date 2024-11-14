# !/bin/bash
# ----------------------------------------------------------------------
# Function to recursively list entries in a group (or subgroup)
# ----------------------------------------------------------------------
# Globals:
#   DATABASE_PATH: Path to the KeePassXC database
#   KEYFILE_PATH: Path to the KeePassXC keyfile
#   KEEPASSXC_GROUP: Group to list entries from
# Usage:
#   do_kbdx_list_secrets "${group_path}"
do_kbdx_list_secrets() {
    DEFAULT_KEEPASSXC_GROUP="/Root"
    local group_path=${1:-$KEEPASSXC_GROUP}
    # List groups and entries under the current group path
    keepassxc-cli ls --no-password ${DATABASE_PATH} "${group_path}" --key-file=${KEYFILE_PATH} | while read line; do
        # Check if line is a group
        if [[ $line == */ ]]; then
            # Recursively list entries in this subgroup
            new_group_path="${group_path}/${line}"
            do_kbdx_list_secrets "${new_group_path%/}" # Remove trailing slash
        else
            # Print details of the entry
            do_log "INFO Entry: ${group_path}/${line}"
            # Uncomment the next lines if you want to show entry details
            username=$(keepassxc-cli show --no-password --quiet ${DATABASE_PATH} "${group_path}/${line}" --key-file=${KEYFILE_PATH} --attributes=UserName)
            echo keepassxc-cli show --no-password --quiet ${DATABASE_PATH} "${group_path}/${line}" --key-file=${KEYFILE_PATH} --attributes=Password \| xclip -selection clipboard
            quit_on "Error copying password to clipboard for ${group_path}/${line}"
            #password=$(keepassxc-cli show --no-password --quiet ${DATABASE_PATH} "${group_path}/${line}" --key-file=${KEYFILE_PATH} --attributes=Password)
            do_log "INFO Username: $username"
            #echo "Password: $password"
            echo ""
        fi
    done

    export EXIT_CODE="0"
}
