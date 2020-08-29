# ip=239.239.239.239
# private_key=~/.ssh/private_key.pem
# ssh -p 22 -i ${private_key} ubuntu@${ip}
#  Are you sure you want to continue connecting (yes/no)? yes

ubuntu_codename=`lsb_release -c -s`

if [ "$ubuntu_codename" = "bionic" ] ; then
    # Ubuntu 18.04
    NVIDIA_DRIVER=440.82
else
    NVIDIA_DRIVER=440.82
fi

set -e

sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -yq

# Prepare for NVidia drivers install
sudo apt-get install -y gcc make pkg-config xserver-xorg-dev linux-headers-$(uname -r) xterm
# xterm is needed for xinit

if [ "$ubuntu_codename" = "bionic" ] ; then
    # Ubuntu 18.04 - to fix following error:
    # ./metashape: error while loading shared libraries: libGLU.so.1: cannot open shared object file: No such file or directory
    sudo apt-get install -y libglu1-mesa
fi

# Install Lubuntu/Xubuntu/anything
sudo apt-get install -y lubuntu-desktop

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

# Fix /etc/X11/xorg.conf:
# 1. Add line with BusID in section Device (taken from output of lspci | egrep -h "VGA|3D controller")
# For EC2 g3 and p3 also:
# 2. Delete whole section ServerLayout (comment it with # symbol)
# 3. Delete whole section Screen (comment it with # symbol)
sudo /usr/bin/python2.7 fix_xorg_conf.py /etc/X11/xorg.conf

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
