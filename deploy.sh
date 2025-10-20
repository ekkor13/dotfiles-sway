#!/bin/bash

# ==========================================================
# КОНФИГУРАЦИЯ
# ==========================================================
# URL вашего репозитория dotfiles на GitHub
REPO_URL="https://github.com/ekkor13/dotfiles-sway"
DOTFILES_DIR="$HOME/.dotfiles"

# Список пакетов Arch Linux для установки
PACKAGES=(
    git sway waybar foot zsh tmux neovim
    dunst pamixer brightnessctl network-manager-applet rofi
    ntfs-3g exfatprogs ttf-nerd-fonts # Утилиты и Шрифты
)

# ==========================================================
# ФУНКЦИИ
# ==========================================================

# Функция для установки пакетов
install_packages() {
    echo "===== 1. Установка системных зависимостей (Arch Linux) ====="
    sudo pacman -Syu --noconfirm "${PACKAGES[@]}"
    echo "Установка пакетов завершена."
}

# Функция для создания символической ссылки
link_file() {
    local source_file="$DOTFILES_DIR/$1"
    local target_file="$HOME/$2"
    local target_dir=$(dirname "$target_file")

    # Создание целевой директории
    mkdir -p "$target_dir"
    
    # Резервное копирование существующего файла, если это не симлинк
    if [ -e "$target_file" ] && [ ! -L "$target_file" ]; then
        echo "   -> Резервное копирование $2..."
        mv "$target_file" "$target_file.bak"
    fi
    
    echo "   -> Создание симлинка: $2"
    # Создание символической ссылки (-s) и принудительная перезапись (-f)
    ln -sf "$source_file" "$target_file"
}

# ==========================================================
# ОСНОВНАЯ ЧАСТЬ СКРИПТА
# ==========================================================

# Защита от запуска на уже установленной системе
if [ -d "$DOTFILES_DIR" ] && [ "$1" != "--force-install" ]; then
    echo "!!! Директория $DOTFILES_DIR уже существует. Запустите 'git pull' для обновления."
    echo "!!! Для полной переустановки запустите: ./deploy.sh --force-install"
    exit 1
fi

# Устанавливаем зависимости
install_packages

echo "===== 2. Клонирование Dotfiles ====="
if [ ! -d "$DOTFILES_DIR" ]; then
    git clone "$REPO_URL" "$DOTFILES_DIR"
fi
cd "$DOTFILES_DIR"

echo "===== 3. Создание символических ссылок (Symlinks) ====="

# Zsh и Tmux (в корне ~)
link_file ".zshrc" ".zshrc"
link_file ".tmux.conf" ".tmux.conf"

# Конфигурации в ~/.config
link_file ".config/sway/config" ".config/sway/config"
link_file ".config/waybar/style.css" ".config/waybar/style.css"
link_file ".config/nvim/init.lua" ".config/nvim/init.lua"

echo "===== 4. Финальная настройка Neovim ====="
# Запуск Nvim для установки плагинов (LazyVim)
nvim --headless "+Lazy sync" +qa

echo "=========================================================="
echo "✅ РАЗВЕРТЫВАНИЕ УСПЕШНО ЗАВЕРШЕНО!"
echo "Для использования Zsh: exec zsh"
echo "Для запуска Sway: exec sway"
echo "=========================================================="
