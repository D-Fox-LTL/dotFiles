-- basic settings
vim.opt.number = true
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.cursorline = true
vim.g.mapleader = " "

-- Lazy.nvim Bootstrap
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

-- Plugins
require("lazy").setup({
  -- Core Dev Tools
  { "nvim-telescope/telescope.nvim", tag = "0.1.4", dependencies = { "nvim-lua/plenary.nvim" } },
  { "nvim-tree/nvim-tree.lua", dependencies = { "nvim-tree/nvim-web-devicons" } },
  { "nvim-lualine/lualine.nvim" },
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
  { "lewis6991/gitsigns.nvim" },

  -- LSP + Autocomplete
  { "neovim/nvim-lspconfig" },
  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "L3MON4D3/LuaSnip" },
  { "saadparwaiz1/cmp_luasnip" },
  { "williamboman/mason.nvim", config = true },
  { "williamboman/mason-lspconfig.nvim" },

  -- RUST
  { "simrat39/rust-tools.nvim" },

  -- AESTHETICS
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
  { "rcarriga/nvim-notify" },
  { "folke/noice.nvim", dependencies = {
    "MunifTanjim/nui.nvim",
    "rcarriga/nvim-notify"
  }},
  { "folke/trouble.nvim", dependencies = { "nvim-tree/nvim-web-devicons" } },
  { "folke/which-key.nvim" },
})

-- Theme: Catppuccin
vim.cmd.colorscheme "catppuccin-mocha"
require("catppuccin").setup({
  integrations = {
    cmp = true,
    gitsigns = true,
    nvimtree = true,
    treesitter = true,
    lsp_trouble = true,
    telescope = true,
    notify = true,
    noice = true,
  }
})

-- Noice + Notify
require("noice").setup({
  lsp = {
    progress = { enabled = true },
    hover = { enabled = true },
    signature = { enabled = true },
  },
  presets = {
    bottom_search = true,
    command_palette = true,
    lsp_doc_border = true,
  },
})
vim.notify = require("notify")

-- Telescope
require("telescope").setup({})

-- Nvim-tree
require("nvim-tree").setup({})

-- Lualine
require("lualine").setup({ options = { theme = "catppuccin" } })

-- Treesitter
require("nvim-treesitter.configs").setup({
  ensure_installed = { "c", "cpp", "lua", "bash", "make", "toml", "rust" },
  highlight = { enable = true },
  indent = { enable = true },
})

require("mason").setup({})
require("mason-lspconfig").setup({
	ensure_installed = { "rust_analyzer", "jdtls" },
})

-- LSP + Completion
local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

lspconfig.rust_analyzer.setup({
	settings = {
		["rust_analyzer"] = {
			cargo = { allFeatures = true },
			checkOnSave = { command = "clippy" },
		},
	},
})


lspconfig.clangd.setup {
  capabilities = capabilities,
}

lspconfig.jdtls.setup({
    cmd = { "jdtls" },
    root_dir = function(fname)
        return
    require("lspconfig.util").root_pattern(".git", "mvnw", "gradlew")(fname) or vim.fn.getcwd()
    end,
    on_attach = function(_, bufnr)
        local opts = { noremap = true, silent = true }
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    end,
})

local cmp = require("cmp")
local luasnip = require("luasnip")
cmp.setup({
  snippet = {
    expand = function(args) luasnip.lsp_expand(args.body) end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<Tab>'] = cmp.mapping.select_next_item(),
    ['<S-Tab>'] = cmp.mapping.select_prev_item(),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
  }),
  sources = {
    { name = "nvim_lsp" },
    { name = "luasnip" },
  },
})

-- Gitsigns
require("gitsigns").setup()

-- Trouble (diagnostic UI)
require("trouble").setup()

-- Which-key (cute keymap helper)
require("which-key").setup()

-- Keymaps (super useful)
local keymap = vim.keymap.set
keymap("n", "<leader>w", ":w<CR>")
keymap("n", "<leader>q", ":q<CR>")
keymap("n", "<leader>e", ":NvimTreeToggle<CR>")
keymap("n", "<leader>ff", "<cmd>Telescope find_files<CR>")
keymap("n", "<leader>fg", "<cmd>Telescope live_grep<CR>")
keymap("n", "<leader>fb", "<cmd>Telescope buffers<CR>")
keymap("n", "<leader>fh", "<cmd>Telescope help_tags<CR>")
keymap("n", "<leader>gd", vim.lsp.buf.definition)
keymap("n", "<leader>rn", vim.lsp.buf.rename)
keymap("n", "<leader>ca", vim.lsp.buf.code_action)
keymap("n", "<leader>d", vim.diagnostic.open_float, { desc = "Show error message" })
keymap("n", "<leader>xx", "<cmd>TroubleToggle<cr>", { desc = "Toggle Diagnostics" })
