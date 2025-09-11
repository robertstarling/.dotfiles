# Source files from .dotnet/bash_aliases/
for f in ~/.dotnet/.bash_aliases/*; do
    [ -f "$f" ] && source "$f"
done
