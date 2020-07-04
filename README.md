# Cloud scripts

These scripts can configure Ubuntu on AWS EC2 GPU instances & your own headless machines to support running OpenGL applications via VirtualGL.

Please note that these scripts are tested on Amazon EC2 g2, g3, p2 and p3 instances, but they can work without or with a little changes on instances of other hosting providers.

# How to use

Connect to instance with Ubuntu via ssh:

```bash
ip=239.239.239.239
private_key=~/.ssh/private_key.pem

ssh -p 22 -i ${private_key} ubuntu@${ip}
```

Configure everything with script (log will be saved to cloud-scripts/configure.log):

```bash
git clone https://github.com/agisoft-llc/cloud-scripts
cd cloud-scripts
chmod +x configure.sh
./configure.sh 2>&1 | tee configure.log
```

Wait a while (~7 minutes) when instance will be rebooted, then reconnect:

```bash
ssh -p 22 -i ${private_key} ubuntu@${ip}
```

To check if installed correctly, run nvidia-smi and see if Xorg is running. 
To run an OpenGL appilication, you need to setup environment variable DISPLAY. For example, to run glxgears,
```
export DISPLAY=:0.0
glxgears
```
