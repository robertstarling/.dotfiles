set -x
echo "Setting background image"

bg_file="file://$BG_DIR/rainbow-aurora.jpg"
gsettings set org.gnome.desktop.background picture-uri  "'$bg_file'"
set +x
