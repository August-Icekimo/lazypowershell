# First time sync and update
# sudo apt upgrade -y
# sudo update-alternatives --config editor && sudo visudo
# get vi and NOPASSWD:ALL for sudoers

# Install ssh relate packages
sudo apt install -y openssh-server sshguard mosh

# Install KVM QEMU relate packages
sudo apt install -y qemu-kvm qemu-utils seabios ovmf cpu-checker libvirt-clients libvirt-daemon-system  bridge-utils virt-manager
sudo usermod -aG libvirt $USER && sudo usermod -aG libvirt-qemu $USER 
kvm-ok

# Install other packages
sudo apt install -y grub-customizer python python3 wget curl

# Install VSCode
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
mkdir -p ~$USER/.config/GIMP/2.10
wget https://raw.githubusercontent.com/doctormo/GimpPs/master/menurc -O ~$USER/.config/GIMP/2.10/menurc

# Install OBS Studio
sudo apt update && sudo apt install -y obs-studio

# sudo apt install libguestfs-tools
# sudo apt install pulseaudio pulseaudio-module-bluetooth pavucontrol bluez-firmware

# Refernce for AMD GPU Driver, for my Ryzen 7 4800H HDMI output
# sudo lshw -C video
# xz -d amdgpu-pro-20.20-1098277-ubuntu-20.04.tar.xz 
# tar xvf amdgpu-pro-20.20-1098277-ubuntu-20.04.tar 
# cd amdgpu-pro-20.20-1098277-ubuntu-20.04/;ls
# ./amdgpu-install --opencl=pal,legacy
sudo add-apt-repository ppa:ubuntubudgie/backports && sudo apt-get update
sudo apt install -y mojave-gtk-theme mcmojave-circle fcitx-chewing whitesur-gtk-theme whitesur-icon-theme
sudo apt install -y gnome-disk-utility gparted