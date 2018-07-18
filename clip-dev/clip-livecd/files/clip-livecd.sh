export HOME="/root"
export PS1='\[\033[01;31m\]clip-livecd\[\033[01;34m\] \W \$\[\033[00m\] '
cd "${HOME}"
echo "Support d'installation CLIP ($(stat -c %y /var/db | sed -r 's/^([-0-9]+).*/\1/' 2>/dev/null))"
