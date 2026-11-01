#!/bin/bash

###Debian###
###Atualização completa do sistema###

set -euo pipefail
##O comando "set -euo" faz o script parar imediatamente caso qualquer comando dentro dele retorne um erro (exit code diferente de 0).(-e → para no erro) (-u → trata variáveis não definidas como erro) (-o pipefail → considera falha em pipe () se qualquer comando falhar

echo ">>Ajuste sobre escala fora do padrão"
##Editar no tty disponível:
#sudo nano /etc/default/grub
#GRUB_CMDLINE_LINUX_DEFAULT="quiet nomodeset"
#GRUB_GFXMODE=1280x1024 ( confirmar antes a resolução correta )
#GRUB_GFXPAYLOAD_LINUX=keep
#sudo update-grub
#sudo reboot -i

echo ">>Adicionar o usuário no arquivo sudoers pelo terminal:"
#su - 
#usermod -aG sudo robsonnakane

echo ">>Instalção dos pacotes na base do sistema"
#sudo apt install distrobox curl openjdk-25-jre flatpak apt-listbugs apt-listchanges -y

echo ">>Instalação do certificado digital (pós instalação, direto no terminal)"
#wget https://github.com/karakun/OpenWebStart/releases/download/v1.14.0/OpenWebStart_linux_1_14_0.deb
#sudo apt install ./OpenWebStart_linux_1_14_0.deb
#javaws https://gestaoar.certisign.com.br/instalador/instalador-certisign.jnlp

echo ">>Login Tailscale (pós instalação, direto no terminal)"
#curl -fsSL https://tailscale.com/install.sh | sh
#systemctl enable --now tailscaled
#sudo tailscale up --ssh --accept-dns --force-reauth

echo ">>Instalação de programas no distrobox"
#distrobox create --name archlinux --image archlinux:latest; distrobox enter archlinux -- sudo pacman -S --noconfirm fastfetch; distrobox enter archlinux -- sudo pacman -S --noconfirm simple-scan; distrobox enter archlinux -- sudo pacman -S --noconfirm kdenlive; distrobox enter archlinux -- sudo pacman -S --noconfirm inkscape; distrobox enter archlinux -- sudo pacman -S --noconfirm thunderbird; distrobox enter archlinux -- sudo pacman -S --noconfirm audacious; distrobox enter archlinux -- sudo pacman -S --noconfirm gimp; distrobox enter archlinux -- sudo pacman -S --noconfirm vlc; distrobox enter archlinux -- sudo pacman -S --noconfirm transmission-gtk; distrobox enter archlinux -- sudo pacman -S --noconfirm rpi-imager; distrobox enter archlinux -- sudo pacman -S --noconfirm gwenview; distrobox enter archlinux -- sudo pacman -S --noconfirm kate; distrobox enter archlinux -- sudo pacman -S --noconfirm yt-dlp; 

echo ">>Exportação dos pacotes instalados no distrobox"
#distrobox enter archlinux -- distrobox-export --app simple-scan; distrobox enter archlinux -- distrobox-export --app kdenlive; distrobox enter archlinux -- distrobox-export --app inkscape; distrobox enter archlinux -- distrobox-export --app thunderbird; distrobox enter archlinux -- distrobox-export --app audacious; distrobox enter archlinux -- distrobox-export --app gimp; distrobox enter archlinux -- distrobox-export --app vlc; distrobox enter archlinux -- distrobox-export --app transmission-gtk; distrobox enter archlinux -- distrobox-export --app rpi-imager; distrobox enter archlinux -- distrobox-export --app gwenview; distrobox enter archlinux -- distrobox-export --app kate;

echo ">>Instalação dos programas Flatpak"
#flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo;
#flatpak install flathub com.spotify.Client -y; flatpak install flathub us.zoom.Zoom -y; flatpak install flathub org.onlyoffice.desktopeditors -y; flatpak install flathub com.adobe.Flash-Player-Projector -y; flatpak install flathub com.github.IsmaelMartinez.teams_for_linux -y; flatpak install flathub org.fedoraproject.MediaWriter -y; flatpak install flathub org.kde.kget -y; flatpak install flathub org.videolan.VLC -y; flatpak install flathub net.mkiol.SpeechNote -y; flatpak install flathub com.saivert.pwvucontrol -y; flatpak install flathub io.github.dvlv.boxbuddyrs -y; flatpak install flathub org.telegram.desktop -y; flatpak install flathub com.obsproject.Studio -y; flatpak install flathub org.audacityteam.Audacity -y; flatpak install flathub com.github.tchx84.Flatseal -y; flatpak install flathub com.google.ChromeDev -y; flatpak install flathub com.mattjakeman.ExtensionManager -y;
echo "$?"

echo ">>Atualização do Flatpak"
flatpak update -y && \
echo "$?"

echo ">>Atualização dos pacotes instalados via distrobox"
distrobox enter archlinux -- sudo pacman -Syyuu --noconfirm && \

echo ">>Limpeza do cache archlinux"
distrobox enter archlinux -- sudo pacman -Scc --noconfirm && \
echo "$?"

##Baixar um vídeo em melhor qualidade:##
#distrobox enter archlinux -- yt-dlp URL
    ##Baixar só áudio (MP3):
#distrobox enter archlinux -- yt-dlp -x --audio-format mp3 URL

##Importação dos arquivos transferidos via Tailscale (/var/lib/tailscale/files)
#sudo tailscale file get ~/

echo ">>APT Update"
sudo apt update -y && \
echo "$?"
echo ">>APT Upgrade"
sudo apt upgrade -y && \
echo "$?"
echo ">>Lista dos pacotes com bugs"
sudo dpkg --configure -a
echo "$?"
echo ">>Caso tenha algum pacote listado, apt-listbugs e escolher a opção 'p' para pinar os pacotes com bugs"
echo ">>Verifica o cache e busca dependências quebradas"
sudo apt-get check
echo "$?"
echo ">>Garante que nenhuma dependência ficou órfã ou corrompida"
sudo apt install -f
echo "$?"
echo ">>APT Autoremove"
sudo apt autoremove -y && \
echo "$?"
echo ">>Se no resumo tiver atualização, reiniciar. Caso contrário digite: exit e pressione enter.<<"
