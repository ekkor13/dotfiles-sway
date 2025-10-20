#!/bin/bash

# ==========================================================
# 1. КОНФИГУРАЦИЯ
# ==========================================================
# ВАЖНО: Замените на URL вашего репозитория dotfiles
REPO_URL="<URL_ВАШЕГО_РЕПОЗИТОРИЯ>"
DOTFILES_DIR="$HOME/.dotfiles"

# Список пакетов Arch Linux для установки
PACKAGES=(
    git sway waybar foot zsh tmux neovim
    dunst pamixer brightnessctl rofi network-manager-applet
    ntfs-3g exfatprogs # Утилиты для флешек
    # Шрифты: JetBrains Mono Nerd Font - самая популярная и надежная альтернатива общему пакету
    ttf-jetbrains-mono-nerd
)

# ==========================================================
# 2. ФУНКЦИИ
# ==========================================================

# Функция для установки пакетов
install_packages() {
    echo "===== 1. Установка системных зависимостей (Arch Linux) ====="
    echo "Устанавливаются пакеты: ${PACKAGES[@]}"
    
    # Сначала проверим, установлен ли yay, и установим его, если его нет
    if ! command -v yay &> /dev/null; then
        echo "Yay не найден. Установка yay..."
        sudo pacman -S --needed base-devel git --noconfirm
        
        # Клонирование и сборка yay
        cd /tmp
        if [ ! -d "yay" ]; then
            git clone https://aur.archlinux.org/yay.git
        fi
        cd yay
        makepkg -si --noconfirm
        cd -
    fi
    
    # Установка пакетов с помощью yay (для AUR и стандартных)
    yay -Syu --noconfirm "${PACKAGES[@]}"
    echo "Установка пакетов завершена."
}

# Функция для создания символической ссылки
link_file() {
    local source_file="$DOTFILES_DIR/$1"
    local target_file="$HOME/$2"
    local target_dir=$(dirname "$target_file")

    # Создание целевой директории
    mkdir -p "$target_dir"
    
    # Пропускаем, если исходного файла нет в репозитории (ошибка при копировании)
    if [ ! -f "$source_file" ] && [ ! -d "$source_file" ]; then
        echo "   -> Пропущено: Файл $1 не найден в репозитории."
        return
    fi

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
# 3. ОСНОВНАЯ ЧАСТЬ СКРИПТА
# ==========================================================

# 1. Устанавливаем зависимости
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
link_file ".config/foot/foot.ini" ".config/foot/foot.ini" # Добавлена конфигурация Foot

echo "===== 4. Финальная настройка Zsh ====="

# Установка Zsh в качестве оболочки по умолчанию
if [ "$SHELL" != "/usr/bin/zsh" ]; then
    echo "Установка Zsh в качестве оболочки по умолчанию..."
    chsh -s /usr/bin/zsh
fi

# Установка Oh My Zsh
echo "Установка Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    # Используем опцию --unattended для автоматической установки без вопросов
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Установка плагинов Zsh
echo "Установка плагинов Zsh..."
ZSH_PLUGINS_DIR=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins

if [ ! -d "$ZSH_PLUGINS_DIR/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_PLUGINS_DIR/zsh-autosuggestions
fi
if [ ! -d "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_PLUGINS_DIR/zsh-syntax-highlighting
fi
if [ ! -d "$ZSH_PLUGINS_DIR/zsh-history-substring-search" ]; then
    git clone https://github.com/zsh-users/zsh-history-substring-search $ZSH_PLUGINS_DIR/zsh-history-substring-search
fi

echo "===== 5. Настройка Neovim ====="
# Запуск Nvim для установки плагинов (LazyVim)
echo "Синхронизация плагинов Neovim..."
nvim --headless "+Lazy sync" +qa

echo "=========================================================="
echo "✅ РАЗВЕРТЫВАНИЕ УСПЕШНО ЗАВЕРШЕНО!"
echo "Для использования Zsh: exec zsh"
echo "Для запуска Sway: exec sway"
echo "=========================================================="
