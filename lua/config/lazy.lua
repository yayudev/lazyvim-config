local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  -- bootstrap lazy.nvim
  -- stylua: ignore
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(vim.env.LAZY or lazypath)

require("lazy").setup({
  spec = {
    -- add LazyVim and import its plugins
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    -- import any extras modules here
    { import = "lazyvim.plugins.extras.lang.json" },
    { import = "lazyvim.plugins.extras.lang.python" },
    { import = "lazyvim.plugins.extras.lang.rust" },
    { import = "lazyvim.plugins.extras.lang.go" },
    { import = "lazyvim.plugins.extras.lang.typescript" },
    { import = "lazyvim.plugins.extras.lang.tailwind" },
    -- { import = "lazyvim.plugins.extras.ui.mini-animate" },
    { import = "lazyvim.plugins.extras.linting.eslint" },
    { import = "lazyvim.plugins.extras.formatting.prettier" },

    { import = "lazyvim.plugins.extras.coding.copilot" },

    {
      "nvimtools/none-ls.nvim",
      optional = true,
      opts = function(_, opts)
        local nls = require("null-ls")
        table.insert(opts.sources, nls.builtins.formatting.prettierd)
      end,
    },
    {
      "stevearc/conform.nvim",
      optional = true,
      opts = {
        formatters_by_ft = {
          ["javascript"] = { { "prettierd", "prettier" } },
          ["javascriptreact"] = { { "prettierd", "prettier" } },
          ["typescript"] = { { "prettierd", "prettier" } },
          ["typescriptreact"] = { { "prettierd", "prettier" } },
          ["vue"] = { { "prettierd", "prettier" } },
          ["css"] = { { "prettierd", "prettier" } },
          ["scss"] = { { "prettierd", "prettier" } },
          ["less"] = { { "prettierd", "prettier" } },
          ["html"] = { { "prettierd", "prettier" } },
          ["json"] = { { "prettierd", "prettier" } },
          ["jsonc"] = { { "prettierd", "prettier" } },
          ["yaml"] = { { "prettierd", "prettier" } },
          ["markdown"] = { { "prettierd", "prettier" } },
          ["markdown.mdx"] = { { "prettierd", "prettier" } },
          ["graphql"] = { { "prettierd", "prettier" } },
          ["handlebars"] = { { "prettierd", "prettier" } },
        },
      },
    },
    {
      "neovim/nvim-lspconfig",
      opts = {
        servers = {
          eslint = {},

          tailwindcss = {
            -- exclude a filetype from the default_config
            filetypes_exclude = { "markdown" },
            -- add additional filetypes to the default_config
            filetypes_include = {},
            -- to fully override the default_config, change the below
            -- filetypes = {}
          },
        },
        setup = {
          eslint = function()
            require("lazyvim.util").on_attach(function(client)
              if client.name == "eslint" then
                client.server_capabilities.documentFormattingProvider = true
              elseif client.name == "tsserver" then
                client.server_capabilities.documentFormattingProvider = false
              end
            end)
          end,

          tailwindcss = function(_, opts)
            local tw = require("lspconfig.server_configurations.tailwindcss")
            opts.filetypes = opts.filetypes or {}

            -- Add default filetypes
            vim.list_extend(opts.filetypes, tw.default_config.filetypes)

            -- Remove excluded filetypes
            --- @param ft string
            opts.filetypes = vim.tbl_filter(function(ft)
              return not vim.tbl_contains(opts.filetypes_exclude or {}, ft)
            end, opts.filetypes)

            -- Add additional filetypes
            vim.list_extend(opts.filetypes, opts.filetypes_include or {})
          end,
        },
      },
    },
    {
      "Saecki/crates.nvim",
      event = { "BufRead Cargo.toml" },
      opts = {
        src = {
          cmp = { enabled = true },
        },
      },
    },
    {
      "goolord/alpha-nvim",
      dependencies = { "nvim-tree/nvim-web-devicons" },
      config = function()
        require("alpha").setup(require("alpha.themes.startify").config)
      end,
    },
    { "roobert/tailwindcss-colorizer-cmp.nvim", config = true },
    { "kevinhwang91/promise-async" },
    { "kevinhwang91/nvim-ufo", requires = "kevinhwang91/promise-async" },
    -- import/override with your plugins
    { "wuelnerdotexe/vim-astro" },
    { "xiyaowong/transparent.nvim" },
    { "jxnblk/vim-mdx-js" },
    {
      "folke/tokyonight.nvim",
      opts = {
        transparent = true,
        styles = {
          sidebars = "transparent",
          floats = "transparent",
        },
      },
    },
    { import = "plugins" },
  },
  defaults = {
    -- By default, only LazyVim plugins will be lazy-loaded. Your custom plugins will load during startup.
    -- If you know what you're doing, you can set this to `true` to have all your custom plugins lazy-loaded by default.
    lazy = false,
    -- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
    -- have outdated releases, which may break your Neovim install.
    version = false, -- always use the latest git commit
    -- version = "*", -- try installing the latest stable version for plugins that support semver
  },
  checker = { enabled = true }, -- automatically check for plugin updates
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        "gzip",
        -- "matchit",
        -- "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})

-- theme
vim.cmd([[colorscheme tokyonight-day]])

-- UFO
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.foldingRange = {
  dynamicRegistration = false,
  lineFoldingOnly = true,
}
local language_servers = require("lspconfig").util.available_servers() -- or list servers manually like {'gopls', 'clangd'}
for _, ls in ipairs(language_servers) do
  require("lspconfig")[ls].setup({
    capabilities = capabilities,
    -- you can add other fields for setting up lsp server in this table
  })
end
require("ufo").setup()
