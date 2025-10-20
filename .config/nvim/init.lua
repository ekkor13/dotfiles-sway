-- ===============================================
-- 1. УСТАНОВКА И КОНФИГУРАЦИЯ LAZY.NVIM
-- ===============================================

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({"git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", lazypath})
end
vim.opt.rtp:prepend(lazypath)

-- ===============================================
-- 2. ГОРЯЧИЕ КЛАВИШИ И БАЗОВЫЕ НАСТРОЙКИ
-- ===============================================

vim.g.mapleader = " " -- Установим Leader key на пробел

-- Базовые настройки Vim
vim.opt.number = true        -- Включить нумерацию строк
vim.opt.relativenumber = true  -- Включить относительную нумерацию (для навигации)
vim.opt.expandtab = true     -- Использовать пробелы вместо табов
vim.opt.tabstop = 4          -- Ширина таба = 4 пробела
vim.opt.shiftwidth = 4       -- Ширина сдвига = 4 пробела
vim.opt.mouse = "a"          -- Включить поддержку мыши
vim.opt.swapfile = false     -- Отключить файлы подкачки
vim.opt.termguicolors = true -- Включить 24-битный цвет

-- Горячие клавиши
vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { desc = 'Toggle NvimTree' })

-- ===============================================
-- 3. ПЛАГИНЫ
-- ===============================================

require("lazy").setup({
  -- === ОСНОВА ДЛЯ ВСЕХ ЯЗЫКОВ ===
  
  'williamboman/mason.nvim',         -- Диспетчер LSP-серверов, форматеров и тp.
  'williamboman/mason-lspconfig.nvim', -- Автоматическая настройка LSP
  'neovim/nvim-lspconfig',           -- Плагин для настройки LSP
  {'nvim-treesitter/nvim-treesitter', build = ':TSUpdate'}, -- Подсветка синтаксиса
  
  -- === АВТОДОПОЛНЕНИЕ ===
  'hrsh7th/nvim-cmp',                -- Основной движок автодополнения
  'hrsh7th/cmp-nvim-lsp',            -- Источник: LSP
  'hrsh7th/cmp-buffer',              -- Источник: буфер
  
  -- === UI и ФУНКЦИОНАЛ ===
  'nvim-tree/nvim-tree.lua',         -- Файловый менеджер
  'nvim-tree/nvim-web-devicons',     -- Иконки для файлов
  'nvim-lualine/lualine.nvim',       -- Строка состояния
  'lewis6991/gitsigns.nvim',         -- Git-интеграция
  'numToStr/Comment.nvim',           -- Комментирование (gc)
  -- === АВТОДОПОЛНЕНИЕ ===
'hrsh7th/nvim-cmp',                -- Основной движок автодополнения
'hrsh7th/cmp-nvim-lsp',            -- Источник: LSP
'hrsh7th/cmp-buffer',              -- Источник: буфер
 { 'windwp/nvim-autopairs', event = "InsertEnter", config = true },
  -- === ПОИСК ===
  {'nvim-telescope/telescope.nvim',
  requires = { {'nvim-lua/plenary.nvim'} }
  },
  
  -- === ЦВЕТОВАЯ СХЕМА (Nightfox - Carbonfox) ===
  'EdenEast/nightfox.nvim',

}, {
  ui = { border = "rounded" },
  -- Установим 'nightfox' как цветовую схему по умолчанию для Lazy
  install = { colorscheme = { "nightfox" } } 
})

-- ===============================================
-- 4. АКТИВАЦИЯ И НАСТРОЙКА ПЛАГИНОВ
-- ===============================================

-- 1. Цветовая схема Carbonfox
-- Nightfox предлагает несколько стилей (dayfox, nightfox, carbonfox, итд.)
-- Мы загружаем плагин 'EdenEast/nightfox.nvim', но активируем стиль 'carbonfox'.
require('nightfox').setup({
    options = {
        compile_path = vim.fn.stdpath("cache") .. "/nightfox",
        load_default = true,
        styles = {
            comments = "italic",
            keywords = "bold",
        }
    },
    specs = {
        carbonfox = {}, -- Здесь могут быть переопределения для carbonfox, если нужны
    },
    -- Основная строка, которая активирует цветовую схему
    palettes = {},
})
vim.cmd('colorscheme carbonfox')


-- 2. Конфигурация Nvim-Tree
require("nvim-tree").setup({
    view = { width = 30, },
    renderer = { group_empty = true, icons = { git_placement = "before" } },
})

-- 3. Конфигурация Lualine (Строка состояния)
require('lualine').setup({
    options = { theme = 'auto' }
})

-- 4. Конфигурация Комментирования
require('Comment').setup()

-- 5. Подключение остальных Lua-модулей (не забудьте создать эти файлы!)
require('lsp_config')       -- LSP, Mason, LSP-серверы
require('treesitter_config') -- Tree-sitter и парсеры
require('cmp_config')        -- Настройка автодополнения
require('telescope_config')  -- Настройка Telescope

-- Включаем поддержку 24-битного цвета (необходимо для использования HEX-кодов)
vim.o.termguicolors = true

-- Определяем цветовую палитру из вашей Sway/Waybar конфигурации
local colors = {
    -- Цвета из config/style.css:
    bg_main = '#1a1a1a',     -- Dark Background
    bg_accent = '#5a5a5a',   -- Active/Accent Background (Workspace Focused)
    fg_main = '#ffffff',     -- White Foreground
    fg_subtle = '#aaaaaa',   -- Light Gray Text/Inactive
}

-- Установка базовых цветов редактора
-- Группа Normal отвечает за основной фон (bg) и текст (fg)
vim.api.nvim_set_hl(0, "Normal", { fg = colors.fg_main, bg = colors.bg_main })
vim.api.nvim_set_hl(0, "NonText", { fg = colors.fg_subtle, bg = colors.bg_main }) -- Фон за концом текста

-- Настройка номеров строк
vim.api.nvim_set_hl(0, "LineNr", { fg = colors.fg_subtle, bg = colors.bg_main })          -- Неактивные номера строк
vim.api.nvim_set_hl(0, "CursorLineNr", { fg = colors.fg_main, bg = colors.bg_main, bold = true }) -- Номер строки, где находится курсор

-- Настройка подсветки синтаксиса и UI
vim.api.nvim_set_hl(0, "Comment", { fg = colors.fg_subtle, italic = true }) -- Комментарии
vim.api.nvim_set_hl(0, "Visual", { bg = colors.bg_accent })                  -- Визуальное выделение (используем акцентный фон)
vim.api.nvim_set_hl(0, "Folded", { fg = colors.fg_subtle, bg = colors.bg_accent })       -- Свернутые блоки кода

-- Дополнительно: Если вы используете StatusLine/Lualine, примените тему Tmux:
vim.api.nvim_set_hl(0, "StatusLine", { fg = colors.fg_main, bg = colors.bg_accent })
vim.api.nvim_set_hl(0, "StatusLineNC", { fg = colors.fg_subtle, bg = colors.bg_main })
