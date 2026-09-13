#!/bin/bash
set -euo pipefail

export PATH="$PATH:/opt/homebrew/bin:/usr/local/bin"
for tool in m1ddc jq; do
    command -v "$tool" >/dev/null || { echo 'Install dependencies: brew install m1ddc jq' >&2; exit 1; }
done
command -v osacompile >/dev/null || { echo 'This installer requires macOS (osacompile).' >&2; exit 1; }

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
launcher="$HOME/.local/bin/switch-monitors"
zshrc="${ZDOTDIR:-$HOME}/.zshrc"
mkdir -p -- "$HOME/.local/bin" "$HOME/Applications" "$(dirname -- "$zshrc")"

# Keep the repository script's own location intact for its relative JSON path.
printf '#!/bin/bash\nexec /bin/bash %q "$@"\n' "$script_dir/switch-monitors.sh" > "$launcher"
chmod +x "$launcher"

path_line='[[ ":$PATH:" == *":$HOME/.local/bin:"* ]] || export PATH="$HOME/.local/bin:$PATH"'
if [[ ! -f $zshrc ]] || ! grep -Fqx -- "$path_line" "$zshrc"; then
    printf '\n%s\n' "$path_line" >> "$zshrc"
fi

for pc in 1 2; do
    osacompile -o "$HOME/Applications/Switch to PC $pc.app" <<EOF
on run
    set launcher to (POSIX path of (path to home folder)) & ".local/bin/switch-monitors"
    try
        do shell script "/bin/bash " & quoted form of launcher & " $pc"
    on error messageText
        display alert "Switch to PC $pc failed" message messageText as critical
    end try
end run
EOF
done

echo 'Installed Switch to PC 1 / PC 2 in ~/Applications. Find them in Spotlight or drag them to the Dock.'
echo 'Open a new terminal to use switch-monitors 1 or switch-monitors 2.'
