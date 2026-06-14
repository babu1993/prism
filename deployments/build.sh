#!/usr/bin/env bash

if ! command -v git >/dev/null 2>&1; then
	echo "git is not installed. Attempting installation..."

	if command -v apt-get >/dev/null 2>&1; then
		if [ "${EUID:-$(id -u)}" -ne 0 ]; then
			sudo apt-get update && sudo apt-get install -y git
		else
			apt-get update && apt-get install -y git
		fi
	elif command -v dnf >/dev/null 2>&1; then
		if [ "${EUID:-$(id -u)}" -ne 0 ]; then
			sudo dnf install -y git
		else
			dnf install -y git
		fi
	elif command -v yum >/dev/null 2>&1; then
		if [ "${EUID:-$(id -u)}" -ne 0 ]; then
			sudo yum install -y git
		else
			yum install -y git
		fi
	elif command -v pacman >/dev/null 2>&1; then
		if [ "${EUID:-$(id -u)}" -ne 0 ]; then
			sudo pacman -Sy --noconfirm git
		else
			pacman -Sy --noconfirm git
		fi
	elif command -v zypper >/dev/null 2>&1; then
		if [ "${EUID:-$(id -u)}" -ne 0 ]; then
			sudo zypper --non-interactive install git
		else
			zypper --non-interactive install git
		fi
	elif command -v apk >/dev/null 2>&1; then
		if [ "${EUID:-$(id -u)}" -ne 0 ]; then
			sudo apk add git
		else
			apk add git
		fi
	else
		echo "Error: unsupported package manager. Please install git manually."
		exit 1
	fi

	if ! command -v git >/dev/null 2>&1; then
		echo "Error: git installation failed."
		exit 1
	fi
fi

echo "git is installed: $(git --version)"

REPO_URL="https://github.com/babu1993/prism.git"
CHECKOUT_DIR="babu1993-prism"
FORCE_CHECKOUT="false"

for arg in "$@"; do
	case "$arg" in
		--force-checkout)
			FORCE_CHECKOUT="true"
			;;
	esac
done

if [ "$FORCE_CHECKOUT" = "true" ] && [ -d "$CHECKOUT_DIR/.git" ]; then
	echo "Force checkout enabled. Replacing existing repository in $CHECKOUT_DIR..."
	rm -rf "$CHECKOUT_DIR"
fi

if [ ! -d "$CHECKOUT_DIR/.git" ]; then
	echo "Checking out repository from $REPO_URL into $CHECKOUT_DIR..."
	git clone "$REPO_URL" "$CHECKOUT_DIR"
else
	echo "Repository already checked out at $CHECKOUT_DIR (use --force-checkout to re-clone)"
fi
