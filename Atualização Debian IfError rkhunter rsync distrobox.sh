#!/bin/bash

###Debian###
###Atualização completa do sistema###

set -euo pipefail
##O comando "set -euo" faz o script parar imediatamente caso qualquer comando dentro dele retorne um erro (exit code diferente de 0).(-e → para no erro) (-u → trata variáveis não definidas como erro) (-o pipefail → considera falha em pipe () se qualquer comando falhar

fastfetch && \
echo "Data de instalação do sistema"
stat /var/home/$USER | grep -E "Criação|Birth"

echo "Instalção dos pacotes na base do sistema"
sudo apt install rkhunter chkrootkit distrobox curl openjdk-25-jre flatpak -y && \ echo "$?"

echo "Instalação do certificado digital"
wget https://github.com/karakun/OpenWebStart/releases/download/v1.14.0/OpenWebStart_linux_1_14_0.deb && \ echo "$?"
sudo apt install ./OpenWebStart_linux_1_14_0.deb && \ echo "$?"
javaws https://gestaoar.certisign.com.br/instalador/instalador-certisign.jnlp && \ echo "$?"

echo "Login Tailscale (pós instalação)"
curl -fsSL https://tailscale.com/install.sh | sh && \ echo "$?"
systemctl enable --now tailscaled && \ sudo tailscale up --ssh --accept-dns --force-reauth && \ echo "$?"

echo "Instalação de programas no distrobox"
#distrobox create --name archlinux --image archlinux:latest && \ distrobox enter archlinux -- sudo pacman -S --noconfirm fastfetch && \ distrobox enter archlinux -- sudo pacman -S --noconfirm simple-scan && \ distrobox enter archlinux -- sudo pacman -S --noconfirm kdenlive && \ distrobox enter archlinux -- sudo pacman -S --noconfirm inkscape && \ distrobox enter archlinux -- sudo pacman -S --noconfirm thunderbird && \ distrobox enter archlinux -- sudo pacman -S --noconfirm audacious && \ distrobox enter archlinux -- sudo pacman -S --noconfirm gimp && \ distrobox enter archlinux -- sudo pacman -S --noconfirm vlc && \ distrobox enter archlinux -- sudo pacman -S --noconfirm transmission-gtk && \ distrobox enter archlinux -- sudo pacman -S --noconfirm rpi-imager && \ distrobox enter archlinux -- sudo pacman -S --noconfirm gwenview && \ distrobox enter archlinux -- sudo pacman -S --noconfirm kate && \ distrobox enter archlinux -- sudo pacman -S --noconfirm yt-dlp && \ echo "$?"

echo "Exportação dos pacotes instalados no distrobox"
#distrobox enter archlinux -- distrobox-export --app simple-scan && \ distrobox enter archlinux -- distrobox-export --app kdenlive && \ distrobox enter archlinux -- distrobox-export --app inkscape && \ distrobox enter archlinux -- distrobox-export --app thunderbird && \ distrobox enter archlinux -- distrobox-export --app audacious && \ distrobox enter archlinux -- distrobox-export --app gimp && \ distrobox enter archlinux -- distrobox-export --app vlc && \ distrobox enter archlinux -- distrobox-export --app transmission-gtk && \ distrobox enter archlinux -- distrobox-export --app rpi-imager && \ distrobox enter archlinux -- distrobox-export --app gwenview && \ distrobox enter archlinux -- distrobox-export --app kate && \

echo "Instalação dos programas Flatpak"
# flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo  && \ flatpak install flathub com.spotify.Client --system -y && \flatpak install flathub us.zoom.Zoom --system -y && \ flatpak install flathub org.onlyoffice.desktopeditors --system -y && \ flatpak install flathub com.adobe.Flash-Player-Projector --system -y && \ flatpak install flathub com.github.IsmaelMartinez.teams_for_linux --system -y && \ flatpak install flathub org.fedoraproject.MediaWriter --system -y && \ flatpak install flathub org.kde.kget --system -y && \ flatpak install flathub org.videolan.VLC --system -y && \ flatpak install flathub net.mkiol.SpeechNote --system -y && \ flatpak install flathub com.saivert.pwvucontrol --system -y && \ flatpak install flathub io.github.dvlv.boxbuddyrs --system -y && \ flatpak install flathub org.telegram.desktop --system -y && \ flatpak install flathub com.obsproject.Studio --system -y && \ flatpak install flathub org.audacityteam.Audacity --system -y && \ flatpak install flathub com.github.tchx84.Flatseal --system -y && \ flatpak install flathub app.zen_browser.zen --system -y && \ flatpak install flathub com.google.ChromeDev --system -y && \ flatpak install flathub com.mattjakeman.ExtensionManager --system -y && \

echo "Atualização e verificação do rkhunter"
sudo rkhunter --update --propupd --check --skip-keypress --report-warnings-only && \
echo "$?"

echo "Atualização do Flatpak"
flatpak update -y && \
echo "$?"

echo "Atualização dos pacotes instalados via distrobox"
distrobox enter archlinux -- sudo pacman -Syyuu --noconfirm && distrobox enter archlinux -- sudo pacman -Scc --noconfirm && \
echo "$?"

##Baixar um vídeo em melhor qualidade:##
#distrobox enter archlinux -- yt-dlp URL
    ##Baixar só áudio (MP3):
#distrobox enter archlinux -- yt-dlp -x --audio-format mp3 URL

##Importação dos arquivos transferidos via Tailscale (/var/lib/tailscale/files)
#sudo tailscale file get ~/

sudo apt autoremove -y && \
sudo apt update -y && \
sudo apt upgrade -y && \
systemctl reboot -i
