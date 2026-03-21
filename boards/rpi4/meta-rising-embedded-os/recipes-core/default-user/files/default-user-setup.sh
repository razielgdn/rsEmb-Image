#!/bin/sh
# Create a default user at first boot using settings from /etc/default-user.conf.
# This script is intended to run as a one-shot systemd service. It reads the
# target username, password, and optional group memberships from the config file,
# validates the values, creates the user if they do not already exist, sets the
# password, and writes a stamp file so the service does not run again on subsequent boots.

# Exit immediately on errors and treat unset variables as errors.
set -eu

# Path to the configuration file that defines the default user credentials and groups.
CFG="/etc/default-user.conf"

# Directory and stamp file used to track whether setup has already been completed.
STAMP_DIR="/var/lib/default-user"
STAMP_FILE="${STAMP_DIR}/configured"

# Abort silently if the configuration file is missing; nothing to do.
if [ ! -f "$CFG" ]; then
    echo "default-user-setup: missing $CFG"
    exit 0
fi

# Source the configuration file to import DEFAULT_USER, DEFAULT_PASSWORD, DEFAULT_GROUPS.
# shellcheck source=/dev/null
. "$CFG"

# Read credentials and group list from the sourced config, defaulting to empty strings.
USER_NAME="${DEFAULT_USER:-}"
USER_PASS="${DEFAULT_PASSWORD:-}"
USER_GROUPS="${DEFAULT_GROUPS:-}"

# Abort if the mandatory username or password fields are empty.
if [ -z "$USER_NAME" ] || [ -z "$USER_PASS" ]; then
    echo "default-user-setup: missing DEFAULT_USER or DEFAULT_PASSWORD"
    exit 0
fi

# Abort if the config still contains the default placeholder values to prevent
# accidental creation of an insecure user on a production image.
if [ "$USER_NAME" = "user-default" ] || [ "$USER_PASS" = "<change-me>" ]; then
    echo "default-user-setup: placeholder credentials detected; skipping"
    exit 0
fi

# Create the user only if they do not already exist on the system.
if ! id "$USER_NAME" >/dev/null 2>&1; then
    GROUP_ARGS=""

    # If a group list was provided, validate each entry against /etc/group and
    # build a comma-separated list of groups that actually exist on this image.
    if [ -n "$USER_GROUPS" ]; then
        VALID_GROUPS=""
        OLD_IFS="$IFS"
        IFS=','
        for grp in $USER_GROUPS; do
            # Include the group only if it is defined in /etc/group.
            if grep -q "^${grp}:" /etc/group; then
                if [ -z "$VALID_GROUPS" ]; then
                    VALID_GROUPS="$grp"
                else
                    VALID_GROUPS="${VALID_GROUPS},${grp}"
                fi
            fi
        done
        IFS="$OLD_IFS"

        # Build the useradd -G argument only when at least one valid group was found.
        if [ -n "$VALID_GROUPS" ]; then
            GROUP_ARGS="-G ${VALID_GROUPS}"
        fi
    fi

    # Create the user with a home directory and /bin/sh as the login shell.
    # Include supplementary group membership when available.
    if [ -n "$GROUP_ARGS" ]; then
        useradd -m -s /bin/sh $GROUP_ARGS "$USER_NAME"
    else
        useradd -m -s /bin/sh "$USER_NAME"
    fi
fi

# Set (or update) the user's password using chpasswd.
echo "${USER_NAME}:${USER_PASS}" | chpasswd

# Write the stamp file so the systemd one-shot service does not repeat on next boot.
install -d "$STAMP_DIR"
touch "$STAMP_FILE"

echo "default-user-setup: user ${USER_NAME} configured"
