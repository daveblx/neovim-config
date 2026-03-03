-- =========================
-- PLUGIN MANAGEMENT
-- =========================

vim.cmd([[
  call plug#begin('~/.local/share/nvim/plugged')

  " Theme
  Plug 'rebelot/kanagawa.nvim'

  " UI enhancements
  Plug 'folke/noice.nvim'
  Plug 'MunifTanjim/nui.nvim'
  Plug 'rcarriga/nvim-notify'

  " File explorer
  Plug 'kyazdani42/nvim-tree.lua'

  " Statusline
  Plug 'nvim-lualine/lualine.nvim'

  " Bufferline (tabs)
  Plug 'akinsho/bufferline.nvim'

  " Startup screen
  Plug 'goolord/alpha-nvim'

  " Telescope (Fuzzy Finder)
  Plug 'nvim-telescope/telescope.nvim'
  Plug 'nvim-lua/plenary.nvim'

  " Multiple cursors
  Plug 'mg979/vim-visual-multi', {'branch': 'master'}

  " LSP + Autocompletion (Mason 2.0 — note new org: mason-org)
  Plug 'mason-org/mason.nvim'
  Plug 'mason-org/mason-lspconfig.nvim'
  Plug 'neovim/nvim-lspconfig'
  Plug 'hrsh7th/nvim-cmp'
  Plug 'hrsh7th/cmp-nvim-lsp'
  Plug 'L3MON4D3/LuaSnip'

  " Treesitter (better syntax highlighting)
  Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

  " Quality of life
  Plug 'windwp/nvim-autopairs'
  Plug 'lukas-reineke/indent-blankline.nvim'
  Plug 'folke/which-key.nvim'

  " Git
  Plug 'lewis6991/gitsigns.nvim'
  Plug 'kdheepak/lazygit.nvim'

  call plug#end()
]])

-- =========================
-- HELPER: safe require
-- Skips setup silently if a plugin isn't installed yet
-- =========================
local function safe_require(name)
    local ok, mod = pcall(require, name)
    if not ok then return nil end
    return mod
end

-- =========================
-- THEME: KANAGAWA
-- =========================
local kanagawa = safe_require('kanagawa')
if kanagawa then
    kanagawa.setup({
        compile = false,
        undercurl = true,
        commentStyle = { italic = true },
        keywordStyle = { italic = true },
        statementStyle = { bold = true },
        typeStyle = {},
        transparent = false,
        dimInactive = false,
        terminalColors = true,
        theme = "dragon",
        background = { dark = "dragon", light = "dragon" },
        overrides = function(colors)
            return {
                NormalFloat = { bg = colors.palette.dragon },
                FloatBorder = { bg = colors.palette.dragon },
                NvimTreeNormal = { bg = colors.palette.dragon },
                NvimTreeEndOfBuffer = { bg = colors.palette.dragon },
            }
        end,
    })
    vim.cmd("colorscheme kanagawa")
end

-- =========================
-- NEOVIDE
-- =========================
if vim.g.neovide then
    vim.g.neovide_hide_titlebar = true
    vim.g.neovide_fullscreen = true
    vim.g.neovide_opacity = 1
    vim.g.neovide_background_image = vim.fn.expand("~/.config/nvim/background.png")
    vim.g.neovide_padding_top = 15
    vim.g.neovide_padding_bottom = 15
    vim.g.neovide_padding_right = 10
    vim.g.neovide_padding_left = 10
    vim.g.neovide_cursor_vfx_mode = "railgun"
    vim.g.neovide_cursor_vfx_particle_density = 1.0
    vim.g.neovide_cursor_vfx_particle_lifetime = 0.01
end

-- =========================
-- NOICE + NOTIFY
-- =========================
local notify = safe_require("notify")
if notify then vim.notify = notify end

local noice = safe_require("noice")
if noice then
    noice.setup({
        lsp = {
            progress = { enabled = true },
            override = {
                ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                ["vim.lsp.util.stylize_markdown"] = true,
                ["cmp.entry.get_documentation"] = true,
            },
        },
        presets = {
            bottom_search = false,
            command_palette = true,
            long_message_to_split = true,
            inc_rename = false,
            lsp_doc_border = true,
        },
        cmdline = {
            view = "cmdline_popup",
            format = {
                cmdline     = { pattern = "^:",  icon = "",  lang = "vim" },
                search_down = { kind = "search", pattern = "^/",  icon = " ", lang = "regex" },
                search_up   = { kind = "search", pattern = "^%?", icon = " ", lang = "regex" },
            },
        },
    })
end

-- =========================
-- NVIM-TREE
-- =========================
local nvimtree = safe_require("nvim-tree")
if nvimtree then
    nvimtree.setup({
        view = { width = 30, side = "left" },
        renderer = {
            icons = { show = { git = true, folder = true, file = true, folder_arrow = true } },
        },
        filters = { dotfiles = false },
        actions = { open_file = { quit_on_open = true } },
    })
end

-- =========================
-- LUALINE
-- =========================
local lualine = safe_require('lualine')
if lualine then
    lualine.setup({
        options = {
            theme = 'kanagawa',
            section_separators = { '', '' },
            component_separators = { '|', '|' },
        }
    })
end

-- =========================
-- BUFFERLINE
-- =========================
local bufferline = safe_require("bufferline")
if bufferline then
    bufferline.setup({
        options = {
            numbers = "ordinal",
            separator_style = "slant",
            show_close_icon = false,
            diagnostics = "nvim_lsp",
            offsets = {{
                filetype = "NvimTree",
                text = "File Explorer",
                highlight = "Directory",
                text_align = "left"
            }},
        }
    })
end

-- =========================
-- MASON 2.0 + LSP
-- Key changes from Mason 1.x:
--   - Plug path changed: williamboman -> mason-org
--   - automatic_installation removed -> use automatic_enable
--   - handlers removed -> use vim.lsp.config() directly
-- =========================
local mason = safe_require("mason")
local mason_lspconfig = safe_require("mason-lspconfig")

if mason and mason_lspconfig then
    mason.setup({
        ui = {
            icons = {
                package_installed = "✓",
                package_pending = "➜",
                package_uninstalled = "✗",
            },
        },
    })

    mason_lspconfig.setup({
        ensure_installed = { "lua_ls", "dockerls", "terraformls", "bashls" },
        automatic_enable = true,
    })

    -- Set up capabilities for autocomplete integration
    local cmp_nvim_lsp = safe_require("cmp_nvim_lsp")
    local capabilities = cmp_nvim_lsp
        and cmp_nvim_lsp.default_capabilities()
        or vim.lsp.protocol.make_client_capabilities()

    -- Apply capabilities globally to all LSP servers
    vim.lsp.config('*', {
        capabilities = capabilities,
    })

    -- Lua-specific: tell the LSP that 'vim' is a valid global
    vim.lsp.config('lua_ls', {
        settings = {
            Lua = {
                diagnostics = { globals = { 'vim' } },
                runtime = { version = 'LuaJIT' },
            },
        },
    })
end

-- =========================
-- AUTOCOMPLETION (nvim-cmp)
-- =========================
local cmp = safe_require("cmp")
local luasnip = safe_require("luasnip")
if cmp and luasnip then
    cmp.setup({
        snippet = {
            expand = function(args) luasnip.lsp_expand(args.body) end,
        },
        mapping = cmp.mapping.preset.insert({
            ['<Tab>']     = cmp.mapping.select_next_item(),
            ['<S-Tab>']   = cmp.mapping.select_prev_item(),
            ['<CR>']      = cmp.mapping.confirm({ select = true }),
            ['<C-Space>'] = cmp.mapping.complete(),
            ['<C-e>']     = cmp.mapping.abort(),
        }),
        sources = cmp.config.sources({
            { name = 'nvim_lsp' },
            { name = 'luasnip' },
        }),
    })
end

-- =========================
-- TREESITTER
-- =========================
local treesitter = safe_require("nvim-treesitter.configs")
if treesitter then
    treesitter.setup({
        ensure_installed = {
            "lua", "python", "javascript", "typescript",
            "dockerfile", "hcl", "bash", "yaml", "json"
        },
        highlight = { enable = true },
        indent = { enable = true },
    })
end

-- =========================
-- AUTOPAIRS
-- =========================
local autopairs = safe_require("nvim-autopairs")
if autopairs then autopairs.setup() end
-- Tab to jump out of closing brackets
vim.keymap.set('i', '<Tab>', function()
    local closers = { ')', ']', '}', '"', "'", '`' }
    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local next_char = line:sub(col + 1, col + 1)
    for _, closer in ipairs(closers) do
        if next_char == closer then
            vim.api.nvim_win_set_cursor(0, { vim.api.nvim_win_get_cursor(0)[1], col + 1 })
            return
        end
    end
    -- fallback: insert a real tab / trigger completion
    local cmp = safe_require("cmp")
    if cmp and cmp.visible() then
        cmp.select_next_item()
    else
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Tab>', true, false, true), 'n', false)
    end
end, { desc = 'Smart tab' })
-- =========================
-- INDENT GUIDES
-- =========================
local ibl = safe_require("ibl")
if ibl then ibl.setup() end

-- =========================
-- WHICH-KEY
-- =========================
local whichkey = safe_require("which-key")
if whichkey then whichkey.setup() end

-- =========================
-- GITSIGNS
-- =========================
local gitsigns = safe_require("gitsigns")
if gitsigns then
    gitsigns.setup({
        signs = {
            add    = { text = '▎' },
            change = { text = '▎' },
            delete = { text = '▎' },
        },
    })
end

-- =========================
-- ALPHA (STARTUP SCREEN)
-- Deferred via VimEnter so it loads after all plugins
-- =========================
vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        if vim.fn.argc() == 0 then
            local alpha = safe_require('alpha')
            local dashboard = safe_require('alpha.themes.dashboard')
            if not alpha or not dashboard then return end

            dashboard.section.header.val = {
                "⠀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
                "⠇⡅⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
                "⠧⡇⠀⠀⠒⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠀⠀⠀⠀⠀⠀⠀⡤⡆⠦⠆⢀⠠⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
                "⠧⣷⣆⠅⢦⠀⠀⠀⠀⠀⠀⠀⠀⠠⠀⠈⠀⠀⠀⠀⠀⢤⣤⣆⢇⣶⣤⡤⡯⣦⣌⡡⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
                "⠷⣿⣷⣆⣐⡆⠀⠀⠀⠀⢀⠤⠊⠀⠀⢀⣠⣾⢯⣦⣴⣜⣺⣾⣿⣤⠟⠋⣷⢛⡣⠭⠢⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
                "⠯⣿⣷⢫⡯⠄⠀⠀⢀⠐⠁⠀⠀⠀⠠⣤⣿⣿⣾⣿⣿⣿⣿⣿⣿⣿⣿⣙⣷⡗⢤⡤⠀⠈⣰⠶⡤⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
                "⣩⣿⡏⠉⠉⠀⢠⡔⠁⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⠑⣏⠶⡉⠖⣡⠂⣈⣤⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
                "⣮⣿⣧⣤⣤⠖⠁⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⢉⡻⣿⣿⣿⣿⣿⣿⣿⣿⠟⠓⠈⠅⠈⠀⠀⠘⢒⣽⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
                "⣿⡿⠛⠉⠀⠀⠀⣀⠔⢀⡴⣃⠀⠀⢀⠷⠲⡄⠸⠟⢋⣿⣿⣿⣿⣿⡇⠀⠀⠀⠐⠁⠀⠀⠂⠀⠀⠰⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
                "⡆⣷⣆⡐⠶⠤⢤⣷⣀⣀⣩⢐⣟⣥⠜⣤⣀⣠⣤⠀⠈⠉⢀⣹⣿⣿⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠐⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
                "⢃⣿⣞⣫⡔⢆⡸⡿⣿⣿⣄⣰⣿⠁⢀⣛⠿⣻⣿⣿⣧⣬⣿⣿⣿⣿⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠀⠀⠀⢀",
                "⢼⣿⣟⢿⣧⣾⣵⣷⣿⣿⣟⡿⢿⣶⣞⣍⡴⢿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠀⣠⠈⠀⢀⣀⣼",
                "⠋⣿⣟⡛⢿⣿⣿⣿⣿⣿⣭⣿⣿⣿⣿⣯⣽⣿⣿⣿⣿⠟⠛⠿⢽⣿⣿⣆⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡀⣀⢀⡠⣤⣤⣰⣿⠟⠁⠀⠀⡼⢾⣿",
                "⣻⣿⣟⣇⠈⣉⣯⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⠃⠀⠀⠀⠀⠀⠻⣿⣿⣿⣿⣴⣶⣤⣤⣤⣤⣴⣴⣴⣶⣦⣦⣤⣦⣀⣦⣤⣶⣿⣿⣿⣿⣿⣿⣿⠿⠁⠀⠀⡀⣤⣬⣾⣿",
                "⡝⣿⣿⣇⣤⣶⣿⣷⣾⣭⡿⠻⢿⣿⣿⣿⣿⠿⠃⠀⠀⠀⠀⡄⠀⠀⠀⢊⡻⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⠋⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣟⢿⠟⢉⠀⡀⢤⣴⣿⣿⣿⠿⠻",
                "⡁⣻⣿⣿⣿⣿⣷⣿⣿⣿⣿⠾⣿⡿⠞⠁⠀⠀⠀⠀⠀⠔⠫⡅⠀⠀⠀⠀⠁⣀⠀⠈⠻⣿⣿⣿⣿⣻⢟⣁⣄⡄⣀⠙⠻⣿⣿⡿⠿⠛⡋⠕⠂⢀⣀⣄⣓⣳⢿⠟⢛⣩⠴⠈⠀",
                "⠂⡁⠈⠛⠛⠛⠛⠋⠁⠀⠈⠈⡀⠀⠀⠀⠀⢀⠘⠀⠀⠀⠆⠀⡀⡢⣀⣆⠄⠈⠨⢦⡀⣈⠙⠛⠿⢿⣿⣿⣿⣿⣿⡿⡿⠿⠟⠆⠒⠁⠀⢶⣾⠿⠟⠛⢉⣀⣠⡶⠚⠁⠀⠀⣠",
                "⠀⡇⡄⣀⡀⠀⠀⠀⠀⠀⠀⠀⢬⠠⠀⡀⠀⠋⠁⠀⡀⠀⠀⡀⠆⢱⣿⣿⣧⣧⣄⠛⣿⣞⣵⣤⣷⣄⠀⠀⠀⠐⠀⠀⠀⠀⠀⠈⠉⠁⠁⠀⠠⢤⣶⣾⣿⡿⠋⢀⣀⣰⣶⣾⣿",
                "⡀⡆⠀⡉⡁⢿⣉⢀⠀⣰⣷⣿⣟⠠⡽⢂⡀⡄⠀⠰⣖⢱⢖⢂⡆⠈⣿⣿⣿⣿⣿⣶⣄⡙⠻⢿⣿⣿⣷⣦⣀⠀⠠⣤⣀⡀⢈⣓⣶⣶⣿⣿⣿⣿⣿⠟⠉⠀⠀⠀⣉⣭⣽⣿⣿",
                "⡇⣯⣿⣿⣿⣾⣿⣿⣿⠿⠟⡡⢞⣹⠾⢻⣚⣛⢺⠞⢋⣭⣾⣧⡃⢄⡈⢿⣿⣿⣿⣿⣿⣿⣯⣿⣮⣽⣿⣿⣿⣿⣷⣬⣽⣿⣿⣿⣽⡿⣿⡿⠟⠋⢀⣀⣐⣺⣿⣿⣟⣫⣭⣿⣿",
                "⢳⣿⣿⣿⣿⣿⣿⣿⣿⣤⣿⣿⣿⣿⣿⣦⠒⠉⢁⡀⠀⣙⣛⢿⣷⣶⣅⠀⠙⠻⣿⣿⣿⣿⣟⡚⠛⠻⠞⠿⠿⡿⡿⠯⠁⠟⣊⠾⠝⢋⣁⣀⣤⣤⣿⣿⣿⡿⠿⠿⠻⠛⠻⠻⠿",
                "⣸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣟⣐⣾⡿⡟⢶⠾⢋⢹⠿⢿⣿⣿⣷⣦⡈⠙⠛⠿⠿⢿⣶⣶⣶⣶⣶⢶⠟⠚⠀⠁⠀⠀⠙⠛⠛⠛⠛⠛⠋⠉⠁⠀⠀⠀⠀⠀⢀⠀⠀",
            }

            dashboard.section.buttons.val = {
                dashboard.button("e", "  New file",   ":ene <BAR> startinsert <CR>"),
                dashboard.button("f", "  Find file",  ":Telescope find_files<CR>"),
                dashboard.button("t", "  File tree",  ":NvimTreeToggle<CR>"),
                dashboard.button("g", "  Git (Lazy)", ":LazyGit<CR>"),
                dashboard.button("m", "  Mason",      ":Mason<CR>"),
                dashboard.button("q", "  Quit NVIM",  ":qa<CR>"),
            }

            alpha.setup(dashboard.config)
            vim.cmd("Alpha")
        end
    end,
})

-- =========================
-- GENERAL SETTINGS
-- =========================
vim.opt.clipboard = 'unnamedplus'
vim.cmd('cd ' .. vim.fn.expand("~/Base"))

-- =========================
-- KEYBINDINGS
-- =========================
vim.keymap.set('n', 'gt',        ':BufferLineCycleNext<CR>',  { desc = 'Next buffer' })
vim.keymap.set('n', 'gT',        ':BufferLineCyclePrev<CR>',  { desc = 'Previous buffer' })
vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>',       { desc = 'Toggle file tree' })
vim.keymap.set('n', '<leader>f', ':Telescope find_files<CR>', { desc = 'Find files' })
vim.keymap.set('n', '<leader>s', ':Telescope live_grep<CR>',  { desc = 'Search in files' })
vim.keymap.set('n', '<leader>g', ':LazyGit<CR>',              { desc = 'Open LazyGit' })
vim.keymap.set('n', 'gd',        vim.lsp.buf.definition,      { desc = 'Go to definition' })
vim.keymap.set('n', 'K',         vim.lsp.buf.hover,           { desc = 'Hover docs' })
vim.keymap.set('n', '<leader>r', vim.lsp.buf.rename,          { desc = 'Rename symbol' })
vim.keymap.set('n', '<leader>a', vim.lsp.buf.code_action,     { desc = 'Code actions' })
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
