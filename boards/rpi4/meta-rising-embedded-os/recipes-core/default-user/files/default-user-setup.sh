#!/bin/sh
# Create a default user at boot from /etc/default-user.conf.

set -eu

CFG="/etc/default-user.conf"
STAMP_DIR="/var/lib/default-user"
STAMP_FILE="${STAMP_DIR}/configured"

if [ ! -f "$CFG" ]; then
    echo "default-user-setup: missing $CFG"
    exit 0
fi

# shellcheck source=/dev/null
. "$CFG"

USER_NAME="${DEFAULT_USER:-}"
USER_PASS="${DEFAULT_PASSWORD:-}"
USER_GROUPS="${DEFAULT_GROUPS:-}"

if [ -z "$USER_NAME" ] || [ -z "$USER_PASS" ]; then
    echo "default-user-setup: missing DEFAULT_USER or DEFAULT_PASSWORD"
    exit 0
fi

if [ "$USER_NAME" = "user-default" ] || [ "$USER_PASS" = "<change-me>" ]; then
    echo "default-user-setup: placeholder credentials detected; skipping"
    exit 0
fi

if ! id "$USER_NAME" >/dev/null 2>&1; then
    GROUP_ARGS=""
    if [ -n "$USER_GROUPS" ]; then
        VALID_GROUPS=""
        OLD_IFS="$IFS"
        IFS=','
        for grp in $USER_GROUPS; do
            if grep -q "^${grp}:" /etc/group; then
                if [ -z "$VALID_GROUPS" ]; then
                    VALID_GROUPS="$grp"
                else
                    VALID_GROUPS="${VALID_GROUPS},${grp}"
                fi
            fi
        done
        IFS="$OLD_IFS"

        if [ -n "$VALID_GROUPS" ]; then
            GROUP_ARGS="-G ${VALID_GROUPS}"
        fi
    fi

    if [ -n "$GROUP_ARGS" ]; then
        useradd -m -s /bin/sh $GROUP_ARGS "$USER_NAME"
    else
        useradd -m -s /bin/sh "$USER_NAME"
    fi
fi

echo "${USER_NAME}:${USER_PASS}" | chpasswd

install -d "$STAMP_DIR"
touch "$STAMP_FILE"

echo "default-user-setup: user ${USER_NAME} configured"
