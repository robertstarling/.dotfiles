set -x
echo "Remapping caps lock to ctrl"
sudo sed -i '/XKBOPTIONS/c\\XKBOPTIONS="ctrl:nocaps"' /etc/default/keyboard
sudo dpkg-reconfigure -f noninteractive keyboard-configuration
set +x
