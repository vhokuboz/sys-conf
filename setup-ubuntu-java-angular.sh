#!/bin/bash

# ==============================================================================
# Script de Configuração de Ambiente de Desenvolvimento (WSL/Ubuntu)
# Stack: Java (Spring Boot) + Angular
# ==============================================================================

# Cores para logs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

log() {
    echo -e "${BLUE}[SETUP]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[ATENCAO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCESSO]${NC} $1"
}

error() {
    echo -e "${RED}[ERRO]${NC} $1"
}

# 1. Atualizando o Sistema
log "Atualizando pacotes do sistema (sudo necessário)..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl git zip unzip build-essential

# 2. Configuração do Git
# 2. Configuração do Git
log "Configurando Git..."

# Caminho do Credential Manager no Windows (acessado via WSL)
WIN_CREDENTIAL_MANAGER="/mnt/c/Program Files/Git/mingw64/bin/git-credential-manager.exe"

if [ -f "$HOME/.gitconfig" ]; then
    warn "Arquivo .gitconfig já existe. Pulando configuração básica."
else
    git config --global core.autocrlf input
    git config --global core.editor nano
    git config --global init.defaultBranch main
    
    # Aliases
    git config --global alias.st status
    git config --global alias.co checkout
    git config --global alias.br branch
    git config --global alias.ci commit
    git config --global alias.lg "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(auto)%d%C(reset)' --all"
    
    success "Git configurado!"
fi

# Configuração do Credential Helper (Integração WSL <-> Windows)
if [ -f "$WIN_CREDENTIAL_MANAGER" ]; then
    log "Configurando integração com Git Credential Manager do Windows..."
    git config --global credential.helper "$WIN_CREDENTIAL_MANAGER"
    success "Integração de credenciais configurada! (Você usará o login do Windows)"
else
    warn "Git for Windows não encontrado no caminho padrão ($WIN_CREDENTIAL_MANAGER)."
    warn "A integração de credenciais foi pulada. Instale o Git no Windows se quiser usar."
fi

# 3. Instalação do NVM (Node Version Manager)
if [ -d "$HOME/.nvm" ]; then
    log "NVM já instalado."
else
    log "Instalando NVM..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
fi

# Carrega o NVM no script atual para podermos usar imediatamente
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# 4. Instalação do Node.js (LTS) e Angular CLI
log "Instalando Node.js LTS..."
nvm install --lts
nvm use --lts

log "Instalando Angular CLI Globalmente..."
npm install -g @angular/cli

# 5. Instalação do SDKMAN! (Java Version Manager)
if [ -d "$HOME/.sdkman" ]; then
    log "SDKMAN! já instalado."
else
    log "Instalando SDKMAN!..."
    curl -s "https://get.sdkman.io" | bash
fi

# Carrega o SDKMAN no script atual
source "$HOME/.sdkman/bin/sdkman-init.sh"

# 6. Instalação do Java 17 e Maven
log "Instalando Java 17 (Eclipse Temurin)..."
sdk install java 17.0.10-tem

log "Instalando Maven..."
sdk install maven

# 7. Verificação Final
echo ""
echo "============================================================"
success "Instalação Finalizada!"
echo "============================================================"
echo "Versões instaladas:"
echo "-------------------"
echo "Git:     $(git --version)"
echo "Node:    $(node -v)"
echo "NPM:     $(npm -v)"
echo "Angular: $(ng version | grep 'Angular CLI' | awk '{print $3}')"
echo "Java:    $(java -version 2>&1 | head -n 1)"
echo "Maven:   $(mvn -v | head -n 1)"
echo "-------------------"
warn "IMPORTANTE: Feche e abra este terminal novamente para carregar todas as variáveis de ambiente."
echo "============================================================"
