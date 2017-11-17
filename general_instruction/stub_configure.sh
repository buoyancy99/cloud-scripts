# ip=239.239.239.239
# private_key=~/.ssh/private_key.pem
# ssh -p 22 -i ${private_key} ubuntu@${ip}
#  Are you sure you want to continue connecting (yes/no)? yes

NVIDIA_DRIVER=384.59

sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -yq

# Prepare for NVidia drivers install
sudo apt-get install -y gcc make pkg-config xserver-xorg-dev linux-headers-$(uname -r) xterm
# xterm is needed for xinit

# Install Lubuntu/Xubuntu/anything
sudo apt-get install -y lubuntu-desktop

# Installing NVidia driver
curl -O http://us.download.nvidia.com/XFree86/Linux-x86_64/${NVIDIA_DRIVER}/NVIDIA-Linux-x86_64-${NVIDIA_DRIVER}.run
chmod +x NVIDIA-Linux-x86_64-${NVIDIA_DRIVER}.run
sudo ./NVIDIA-Linux-x86_64-${NVIDIA_DRIVER}.run --no-questions --accept-license --no-precompiled-interface --ui=none
echo ""
echo "************************************************************************************************"
echo "*                                                                                              *"
echo "* May be you see this warning above:                                                           *"
echo "*  - WARNING: Unable to find a suitable destination to install 32-bit compatibility libraries. *"
echo "* This is OK.                                                                                  *"
echo "*                                                                                              *"
echo "************************************************************************************************"
echo ""
rm NVIDIA-Linux-x86_64-${NVIDIA_DRIVER}.run

# Preparation for virtualgl like in https://virtualgl.org/Documentation/HeadlessNV
sudo nvidia-xconfig -a --use-display-device=None --virtual=1280x1024

echo ""
echo "********************************************************************************"
echo "*                                                                              *"
echo "* May be you see this warning above:                                           *"
echo "*  - WARNING: Unable to locate/open X configuration file.                      *"
echo "* This is OK.                                                                  *"
echo "*                                                                              *"
echo "********************************************************************************"
echo ""

lspci | grep VGA
# Ensure it prints:
#
#  g2 instance:
#   00:02.0 VGA compatible controller: Cirrus Logic GD 5446
#   00:03.0 VGA compatible controller: NVIDIA Corporation GK104GL [GRID K520] (rev a1)
#
#  g3 instance:
#   00:02.0 VGA compatible controller: Cirrus Logic GD 5446
#   00:1e.0 VGA compatible controller: NVIDIA Corporation GM204GL [Tesla M60] (rev a1)

echo ""
echo "***************************************************************************************"
echo "*                                                                                     *"
echo "* YOU NEED TO EDIT /etc/X11/xorg.conf MANUALLY!!!!                                    *"
echo "* Or use scripts with automatic xorg.conf fixing in directory for your instance type  *"
echo "*                                                                                     *"
echo "***************************************************************************************"
echo ""

exit 1

# YOU NEED TO EDIT /etc/X11/xorg.conf:
#
# You can use nano for example:
# sudo nano /etc/X11/xorg.conf
# ... edit file ...
# Press Ctrl+O -> Enter
# Press Ctrl+X
#
# 1. Delete whole section ServerLayout (or comment it with # symbol)
# 2. Delete whole section Screen (or comment it with # symbol)
# 3. Add line with BusID in such way in section Device:
#
# BEFORE:
#
#Section "Device"
#    Identifier     "Device0"
#    Driver         "nvidia"
#    VendorName     "NVIDIA Corporation"
#    BoardName      <BOARD_NAME>
#EndSection
#
# AFTER:
#
#Section "Device"
#    Identifier     "Device0"
#    Driver         "nvidia"
#    VendorName     "NVIDIA Corporation"
#    BoardName      <BOARD_NAME>
#    BusID          <BUS_ID>
#EndSection
#
# Where
#  on g2 instance: BOARD_NAME="GRID K520" BUS_ID="PCI:0:3:0"
#  on g3 instance: BOARD_NAME="Tesla M60" BUS_ID="PCI:0:30:0" (because 00:1e.0 output from lspci is in hexadecimal, but xorg.conf expects decimal)

# Install VirtualGL
wget https://sourceforge.net/projects/virtualgl/files/2.5.2/virtualgl_2.5.2_amd64.deb/download -O virtualgl_2.5.2_amd64.deb
sudo dpkg -i virtualgl*.deb
rm virtualgl*.deb

# Install TurboVNC
wget https://sourceforge.net/projects/turbovnc/files/2.1.1/turbovnc_2.1.1_amd64.deb/download -O turbovnc_2.1.1_amd64.deb
sudo dpkg -i turbovnc*.deb
rm turbovnc*.deb

# Configure VirtualGL
sudo service lightdm stop
sudo /opt/VirtualGL/bin/vglserver_config -config +s +f -t

echo ""
echo "********************************************************************************"
echo "*                                                                              *"
echo "* May be you see these lines above:                                            *"
echo "*  - rmmod: ERROR: Module nvidia is in use by: nvidia_modeset                  *"
echo "*  - IMPORTANT NOTE: Your system uses modprobe.d to set device permissions.    *"
echo "* This is OK - just means that reboot required.                                *"
echo "*                                                                              *"
echo "********************************************************************************"
echo ""

echo ""
echo "******************************************************************"
echo "*                                                                *"
echo "* Rebooting for changes to take effect!                          *"
echo "*                                                                *"
echo "******************************************************************"
echo ""

sudo reboot