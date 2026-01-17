# bcm4360-offline-installer
An installer to get that damn bcm4360 working

This install script is working and tested on x86_64 fedora 43 KDE
Instructions
### Clone this repository
### Reassemble the parts.
```bash
cat pkgs_partaa pkgs_partab | tar -xzf -
```
### place the installer.sh in the same directory as the pkgs folder
### give execute permission
### run the installer.sh as sudo
```bash
sudo ./installer.sh
```
