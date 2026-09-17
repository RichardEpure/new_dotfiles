# Shared by the macOS and Ubuntu installers; source this file, don't execute it.
select_install_mode() {
	local mode="${1:-}" choice
	if [ "$#" -gt 1 ]; then mode=invalid; fi
	case "$mode" in
		--all) printf 'all\n' ;;
		--agents) printf 'agents\n' ;;
		--dotfiles) printf 'dotfiles\n' ;;
		"")
			printf 'Select what to install:\n1. All\n2. Agent harnesses\n3. Dotfiles only\n' >&2
			while read -r -p 'Choice: ' choice; do
				case "$choice" in
					1) printf 'all\n'; return ;;
					2) printf 'agents\n'; return ;;
					3) printf 'dotfiles\n'; return ;;
					*) printf 'Enter 1, 2, or 3.\n' >&2 ;;
				esac
			done
			return 1
			;;
		*)
			printf 'Usage: %s [--all|--agents|--dotfiles]\n' "$0" >&2
			return 2
			;;
	esac
}

install_agent_harnesses() {
	local private_root repository_root expected_root
	private_root="$(dirname -- "$1")/opencode-config"

	if [ -e "$private_root" ] || [ -L "$private_root" ]; then
		repository_root="$(git -C "$private_root" rev-parse --show-toplevel 2>/dev/null)" || {
			printf '%s exists but is not a Git repository.\n' "$private_root" >&2
			return 1
		}
		expected_root="$(cd -- "$private_root" && pwd -P)" || return 1
		if [ "$(cd -- "$repository_root" && pwd -P)" != "$expected_root" ]; then
			printf '%s is not the root of its Git repository.\n' "$private_root" >&2
			return 1
		fi
		git -C "$private_root" pull --ff-only || {
			printf 'Failed to update %s. Commit or stash local changes and retry.\n' "$private_root" >&2
			return 1
		}
	elif command -v gh >/dev/null 2>&1; then
		gh repo clone RichardEpure/opencode-config "$private_root" || {
			printf 'Failed to clone the agent harness repository. Check GitHub authentication.\n' >&2
			return 1
		}
	else
		git clone git@github.com:RichardEpure/opencode-config.git "$private_root" || {
			printf 'Failed to clone the agent harness repository. Check SSH authentication.\n' >&2
			return 1
		}
	fi

	# The private installer owns which harnesses are deployed (currently both by default).
	bash "$private_root/setup.sh"
}
