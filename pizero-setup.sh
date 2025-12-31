#!/bin/bash

# ---  CONFIGURAÇÕES DO USUÁRIO ---
GIT_USER="Vitor Okubo"
GIT_EMAIL="vitor.okubo@outlook.com"

echo "---------------------------------------------"
echo " INICIANDO SETUP OTIMIZADO PARA PI ZERO 2W "
echo "---------------------------------------------"

# 1. ESTABILIDADE DE REDO (Evita queda do SSH)
echo "--- Desativando economia de energia do Wi-Fi"
sudo iw dev wlan0 set power_save off

# 2. IDENTIDADE DO PI
echo "Identidade do PI " | sudo tee -a /etc/hosts

# 3. ATUALIZAÇÃO E FERRAMENTAS
echo "--- Atualizando sistema e instalando essenciais ---"
sudo apt update && sudo apt upgrade -y
sudo apt install -y git htop curl wget bash-completion zram-tools

# 4. BUSCA INTELIGENTE NO HIST[ORICO (.inputrc)
echo "--- Configurando .inputrc ---"
cat <<EOT >> ~/.inputrc

$include /etc/inputrc

"\\e[A": history-search-backward
"\\e[B": history-search-forward
set show-all-if-ambiguous on
set completion-ignore-case on
EOT
# Aplica sem precisar deslogar
bind -f ~/.inputrc

# 5. CONFIGURAÇÃO DO GIT
echo "--- Configurando Git com Credential Helper ---"
git config --global user.name "$GIT_USER"
git config --global user.email "$GIT_EMAIL"
git config --global credential.helper store

# 6. OTIMIZAÇÃO DE MEMORIA (ZRAM E SWAPPINESS)
echo "--- Otimizando RAM e ZRAM ---"
sudo sysctl vm.swappiness=100
echo "vm.swappiness=100" | sudo tee -a /etc/sysctl.conf

# 7. ALIASES PERSONALIZADOS
echo "--- Criando atalhos (ll, temp, update, mem) ---"
sed -i '/# ALIASES PERSONALIZADOS/,$d' ~/.bashrc # Limpa de já existir
cat <<EOT >> ~/.bashrc

# ALIASES PERSONALIZADOS
alias ll='ls -lah'
alias update='sudo apt update && sudo apt upgrade -y'
alias mem='free -h'
alias temp='/usr/bin/vcgencmd measure_temp'
alias dash='htop'
EOT

# 8. LIMPEZA
sudo apt autoremove -y

echo "------------------------------------------------------------------------"
echo " SETUP FINALIZADO COM SUCESSO! "
echo "------------------------------------------------------------------------"
echo "Próximos passos:"
echo "1. Rode: source ~/.bashrc"
echo "2. Na proxima vez que usar o Git, use seu token do Github com senha."
echo "------------------------------------------------------------------------"
