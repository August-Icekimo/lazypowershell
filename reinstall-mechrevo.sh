# First time sync and update
 sudo apt upgrade -y
 sudo update-alternatives --config editor && sudo visudo
# get vi and NOPASSWD:ALL for sudoers

# Install ssh relate packages
sudo apt install -y openssh-server sshguard mosh

# Install KVM QEMU relate packages
sudo apt install -y qemu-kvm qemu-utils seabios ovmf cpu-checker libvirt-clients libvirt-daemon-system  bridge-utils virt-manager
export USERNAME=$USER
sudo usermod -aG libvirt $USERNAME && sudo usermod -aG libvirt-qemu $USERNAME 
echo "Show current KVM status:" && kvm-ok

# Install other packages
# sudo add-apt-repository ppa:danielrichter2007/grub-customizer
sudo apt install -y grub-customizer 
# # sudo add-apt-repository -r ppa:danielrichter2007/grub-customizer
sudo apt install -y python python3 wget curl
# Gnome tools & power management
sudo apt install -y gnome-disk-utility gparted pm-utils
# sudo apt install libguestfs-tools
# sudo apt install pulseaudio pulseaudio-module-bluetooth pavucontrol bluez-firmware

# Install VSCode & Git
sudo apt install software-properties-common apt-transport-https wget
wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" -y
sudo apt update && sudo apt install -y code git
# git config --global user.name "August Icekimo"
# git config --global user.email august.icekimo@gmail.com

# Install Sound & Video programes
sudo apt install -y audacious audacity ffmpeg
sudo wget https://yt-dl.org/downloads/latest/youtube-dl -O /usr/local/bin/youtube-dl
sudo chmod a+rx /usr/local/bin/youtube-dl

# Install OpenShot
sudo add-apt-repository ppa:openshot.developers/ppa -y
sudo apt update && sudo apt install -y openshot-qt blender inkscape gimp
# Also Install Other Openshot Goodfriends: Blender Inkscape & GIMP
# Install GIMP another way
# sudo add-apt-repository -y ppa:otto-kesselgulasch/gimp
# sudo apt install ppa-purge && sudo ppa-purge ppa:otto-kesselgulasch/gimp
# sudo apt full-upgrade && apt list --upgradable
mkdir -p ~$USERNAME/.config/GIMP/2.10
wget https://raw.githubusercontent.com/doctormo/GimpPs/master/menurc -O ~$USERNAME/.config/GIMP/2.10/menurc

# Install OBS Studio
sudo apt update && sudo apt install -y obs-studio

# Refernce for AMD GPU Driver, for my Ryzen 7 HDMI output
# sudo lshw -C video
# wget https://repo.radeon.com/amdgpu-install/latest/ubuntu/jammy/amdgpu-install_5.4.50400-1_all.deb
# dpkg -i amdgpu-install_5.4.50400-1_all.deb
# amdgpu-install --usecase=graphics,opencl --opencl=rocr,legacy --vulkan=amdvlk,pro

# Install Budgie macOS theme
sudo add-apt-repository ppa:ubuntubudgie/backports && sudo apt-get update
sudo apt install -y mojave-gtk-theme mcmojave-circle fcitx-chewing whitesur-gtk-theme whitesur-icon-theme


##LINE Notify 發行存取權杖（開發人員用）
export line_token=""
function notify()
{
    curl -X POST -H 'Authorization: Bearer $line_token' https://notify-api.line.me/api/notify -F "message=$*"
}