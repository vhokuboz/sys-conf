#!/bin/bash

# --- CONFIGURAÇÕES DO USUÁRIO ---
GIT_USER="Vitor Okubo"
GIT_EMAIL="vitor.okubo@outlook.com"
NEW_HOSTNAME="nitro-server"

echo "----------------------------------------------------"
echo " CONFIGURANDO NOTEBOOK GAMER COMO SERVIDOR "
echo "----------------------------------------------------"

# 1. EVITAR SUSPENSÃO AO FECHAR A TAMPA (LID CLOSE)
echo "--- Configurando comportamento da tampa (Lid Switch) ---"
sudo sed -i 's/#HandleLidSwitch=suspend/HandleLidSwitch=ignore/' /etc/systemd/logind.conf
sudo systemctl restart systemd-logind

# 2. IDENTIDADE E REDE
echo "--- Alterando hostname para $NEW_HOSTNAME ---"
sudo hostnamectl set-hostname $NEW_HOSTNAME

# 3. ATUALIZAÇÃO E FERRAMENTAS X86
echo "--- Atualizando sistema e instalando ferramentas ---"
sudo apt update && sudo apt upgrade -y
sudo apt install -y git htop curl wget bash-completion powertop lm-sensors

# 4. BUSCA INTELIGENTE NO HISTÓRICO (.inputrc)
cat <<EOT > ~/.inputrc
"\e[A": history-search-backward
"\e[B": history-search-forward
set show-all-if-ambiguous on
set completion-ignore-case on
EOT
bind -f ~/.inputrc

# 5. CONFIGURAÇÃO DO GIT
git config --global user.name "$GIT_USER"
git config --global user.email "$GIT_EMAIL"
git config --global credential.helper store

# 6. ALIASES ESPECÍFICOS PARA NOTEBOOK (Bateria e Sensores)
echo "--- Criando atalhos de monitoramento ---"
cat <<EOT >> ~/.bashrc

# ALIASES SERVIDOR NOTEBOOK
alias update='sudo apt update && sudo apt upgrade -y'
alias mem='free -h'
alias dash='htop'
alias stats='powertop --show-stats'      # Ver consumo de energia
alias temp='sensors'                     # Ver temperatura da CPU/GPU
alias bat='upower -i /org/freedesktop/UPower/devices/battery_BAT0' # Ver saúde da bateria
alias bat1='upower -i $(upower -e | grep BAT) | grep -E "state|to\ full\percentage"'
EOT

source ~/.bashrc

# 7. OTIMIZAÇÃO DE ENERGIA (Opcional, mas recomendado)
# TLP ajuda a economizar energia em notebooks Linux
sudo apt install -y tlp
sudo tlp start

echo "----------------------------------------------------"
echo " SETUP CONCLUÍDO! "
echo " Seu notebook não irá dormir ao fechar a tampa. "
echo " Use o comando 'bat' para monitorar sua 'Nobreak integrada'. "
echo "----------------------------------------------------"
