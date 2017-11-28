#!/bin/bash
# Obtained from https://gist.github.com/Strubbl/95248a843b896849b56dbb627752e447
# See also https://aur.archlinux.org/packages/gnucash/#comment-622668

set -e
set -u
set -o xtrace

sudo mount -o remount,exec,suid ~
mkdir ~/source/chroot -p
cd ~/source
sudo mkarchroot chroot/root base-devel
git clone "https://aur.archlinux.org/goffice0.8.git"
git clone "https://aur.archlinux.org/webkitgtk.git"
git clone "https://aur.archlinux.org/gnucash.git"
cd goffice0.8/
makechrootpkg -T -r ../chroot/
sudo cp *.pkg.tar.xz /var/cache/pacman/pkg/.
cd ../webkitgtk/
makechrootpkg -T -r ../chroot/
sudo cp *.pkg.tar.xz /var/cache/pacman/pkg/.
cd ../gnucash/
makechrootpkg -T -r ../chroot/ -I ../goffice0.8/goffice0.8-0.8.17-4-x86_64.pkg.tar.xz -I ../webkitgtk/webkitgtk2-2.4.11-6-x86_64.pkg.tar.xz
sudo cp *.pkg.tar.xz /var/cache/pacman/pkg/.
yes 'j' | sudo pacman -U gnucash*.pkg.tar.xz ../webkitgtk/webkitgtk2*.pkg.tar.xz ../goffice0.8/goffice0.8*.pkg.tar.xz
