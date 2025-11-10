#!/bin/bash

###Debian###

#Substituir a sources list do arquivo "nano /etc/apt/sources.list.d/debian.sources" com o texto abaixo sem comentar as linhas deb:

#https://wiki.debian.org/SourcesList

#Após substituição executar o seguinte comando:
#sudo rm /var/lib/apt/lists/lock

##Execução do arquivo de atualização no terminal##
#/home/robsonnakane/Documentos/'Atualização Debian.sh'

#Edição do arquivo no terminal#
#nano /home/robsonnakane/Documentos/'Atualização Debian.sh'

###Atualização completa do sistema###
systemctl stop packagekit;
sudo apt autoremove -y;
sudo apt update -y;
sudo apt full-upgrade -y;

##instalação dos programas nativos##
#sudo apt install screenfetch -y; sudo apt install simple-scan -y; sudo apt install btop -y; sudo apt install gnome-boxes -y; sudo apt install kitty -y;

##Pesquisar o número da última versão com sudo apt search openjdk##
#sudo apt install openjdk-xx-jdk -y;

##instalação dos programas Flatpak##
#sudo apt install flatpak -y; flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo; flatpak install flathub com.spotify.Client -y; flatpak install flathub org.videolan.VLC -y; flatpak install flathub com.valvesoftware.Steam -y; flatpak install flathub us.zoom.Zoom -y; flatpak install flathub org.onlyoffice.desktopeditors -y; flatpak install flathub com.skype.Client -y; flatpak install flathub com.adobe.Flash-Player-Projector -y; flatpak install flathub org.raspberrypi.rpi-imager -y; flatpak install flathub com.google.Chrome -y; flatpak install flathub org.gnome.Firmware -y; flatpak install flathub org.kde.kdenlive -y; flatpak install flathub org.inkscape.Inkscape -y; flatpak install flathub org.mozilla.Thunderbird -y; flatpak install flathub org.fedoraproject.MediaWriter -y; flatpak install flathub org.gnome.gedit -y; flatpak install flathub org.atheme.audacious -y; flatpak install flathub ca.littlesvr.asunder -y; flatpak install flathub ar.com.tuxguitar.TuxGuitar -y; flatpak install flathub org.gnome.DejaDup -y;

##Atualização do Flatpak##
flatpak update -y;

sudo systemctl reboot
