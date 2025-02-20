#!/usr/bin/env bash
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
BRAVE_USE_FLASH_IF_AVAILABLE="${BRAVE_USE_FLASH_IF_AVAILABLE:-true}"

# Allow users to override command-line options
USER_FLAGS_FILE="$XDG_CONFIG_HOME/brave-flags.conf"
if [[ -f $USER_FLAGS_FILE ]]; then
   USER_FLAGS="$(cat $USER_FLAGS_FILE | sed 's/#.*//')"
fi

if [[ ! (-r /proc/sys/kernel/unprivileged_userns_clone && $(< /proc/sys/kernel/unprivileged_userns_clone) == 1 && -n $(zcat /proc/config.gz | grep CONFIG_USER_NS=y) ) ]]; then
    >&2 echo "User namespaces are not detected as enabled on your system, Brave will run with the sandbox disabled"
    SANDBOX_FLAG="--no-sandbox"
fi

BRAVE_PEPPER_FLASH_SO=${BRAVE_PEPPER_FLASH_SO:-/usr/lib/PepperFlash/libpepflashplayer.so}
if [[ -f $BRAVE_PEPPER_FLASH_SO && $BRAVE_USE_FLASH_IF_AVAILABLE == "true" ]]; then
   BRAVE_PEPPER_FLASH_VERSION=${BRAVE_PEPPER_FLASH_VERSION:-$(LANG=C pacman -Qi pepper-flash | grep Version | sed 's/.*: //; s/\-[^-]*$//')}
   PEPPER_FLASH_FLAG="--ppapi-flash-path=$BRAVE_PEPPER_FLASH_SO --ppapi-flash-version=$BRAVE_PEPPER_FLASH_VERSION"
fi

# OR true included because Brave currently segfaults when a second 
# window is opened from running the brave binary.
# GH Issue: https://github.com/brave/brave-browser/issues/4142
# NOTE: Replace with an exec call once we don't have to work around
# this bug by having the browser be a subprocess of this script
/usr/lib/brave-bin/brave $@ $SANDBOX_FLAG $PEPPER_FLASH_FLAG $USER_FLAGS || true
