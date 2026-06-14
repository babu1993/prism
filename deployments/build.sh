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

if ! command -v gcc >/dev/null 2>&1 || ! command -v g++ >/dev/null 2>&1 || ! command -v make >/dev/null 2>&1; then
	echo "Build essentials are not fully installed. Attempting installation..."

	if command -v apt-get >/dev/null 2>&1; then
		if [ "${EUID:-$(id -u)}" -ne 0 ]; then
			sudo apt-get update && sudo apt-get install -y build-essential
		else
			apt-get update && apt-get install -y build-essential
		fi
	elif command -v dnf >/dev/null 2>&1; then
		if [ "${EUID:-$(id -u)}" -ne 0 ]; then
			sudo dnf groupinstall -y "Development Tools" || sudo dnf install -y make gcc gcc-c++
		else
			dnf groupinstall -y "Development Tools" || dnf install -y make gcc gcc-c++
		fi
	elif command -v yum >/dev/null 2>&1; then
		if [ "${EUID:-$(id -u)}" -ne 0 ]; then
			sudo yum groupinstall -y "Development Tools" || sudo yum install -y make gcc gcc-c++
		else
			yum groupinstall -y "Development Tools" || yum install -y make gcc gcc-c++
		fi
	elif command -v pacman >/dev/null 2>&1; then
		if [ "${EUID:-$(id -u)}" -ne 0 ]; then
			sudo pacman -Sy --noconfirm base-devel
		else
			pacman -Sy --noconfirm base-devel
		fi
	elif command -v zypper >/dev/null 2>&1; then
		if [ "${EUID:-$(id -u)}" -ne 0 ]; then
			sudo zypper --non-interactive install -t pattern devel_basis
		else
			zypper --non-interactive install -t pattern devel_basis
		fi
	elif command -v apk >/dev/null 2>&1; then
		if [ "${EUID:-$(id -u)}" -ne 0 ]; then
			sudo apk add build-base
		else
			apk add build-base
		fi
	else
		echo "Error: unsupported package manager. Please install build essentials manually."
		exit 1
	fi

	if ! command -v gcc >/dev/null 2>&1 || ! command -v g++ >/dev/null 2>&1 || ! command -v make >/dev/null 2>&1; then
		echo "Error: build essentials installation failed."
		exit 1
	fi
fi

echo "build essentials are installed: gcc=$(gcc --version | head -n 1), g++=$(g++ --version | head -n 1), make=$(make --version | head -n 1)"

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

cd "$CHECKOUT_DIR" || { echo "Failed to change directory to $CHECKOUT_DIR"; exit 1; }
cd src/ngnix || { echo "Failed to change directory to src/ngnix"; exit 1; }
echo "Building Nginx..."