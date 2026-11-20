#!/bin/bash

# Скрипт для автоматичного встановлення DevOps-інструментів
# Docker, Docker Compose, Python 3.9+, Django
# Працює на Ubuntu / Debian

set -e

echo "=== Початок встановлення DevOps-інструментів ==="

# --- 1. Docker ---
if command -v docker &> /dev/null; then
    echo "[SKIP] Docker вже встановлено: $(docker --version)"
else
    echo "[INSTALL] Встановлення Docker..."
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl gnupg lsb-release

    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
        sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
      https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    echo "[OK] Docker встановлено: $(docker --version)"
fi

# --- 2. Docker Compose ---
if docker compose version &> /dev/null; then
    echo "[SKIP] Docker Compose (плагін) вже доступний: $(docker compose version)"
elif command -v docker-compose &> /dev/null; then
    echo "[SKIP] Docker Compose (standalone) вже встановлено: $(docker-compose --version)"
else
    echo "[INSTALL] Встановлення Docker Compose (standalone)..."
    COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
    sudo curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" \
        -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo "[OK] Docker Compose встановлено: $(docker-compose --version)"
fi

# --- 3. Python 3.9+ ---
PYTHON_OK=false
if command -v python3 &> /dev/null; then
    PY_VER=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
    PY_MAJOR=$(echo "$PY_VER" | cut -d. -f1)
    PY_MINOR=$(echo "$PY_VER" | cut -d. -f2)
    if [ "$PY_MAJOR" -eq 3 ] && [ "$PY_MINOR" -ge 9 ]; then
        echo "[SKIP] Python вже встановлено: $(python3 --version)"
        PYTHON_OK=true
    fi
fi

if [ "$PYTHON_OK" = false ]; then
    echo "[INSTALL] Встановлення Python 3.9+..."
    sudo apt-get update
    sudo apt-get install -y python3 python3-pip python3-venv
    echo "[OK] Python встановлено: $(python3 --version)"
fi
# --- 3.5. pip (окремо, бо python3 може бути без pip) ---
if ! command -v pip3 &> /dev/null; then
    echo "[INSTALL] Встановлення pip3..."
    sudo apt-get install -y python3-pip
    echo "[OK] pip3 встановлено: $(pip3 --version)"
else
    echo "[SKIP] pip3 вже встановлено: $(pip3 --version)"
fi

# --- 4. Django (через pip) ---
if python3 -c "import django" &> /dev/null; then
    echo "[SKIP] Django вже встановлено: $(python3 -m django --version)"
else
    echo "[INSTALL] Встановлення Django через pip..."
    pip3 install django --break-system-packages 2>/dev/null || \
        pip3 install django --user
    echo "[OK] Django встановлено: $(python3 -m django --version)"
fi

echo "=== Встановлення завершено успішно! ==="
