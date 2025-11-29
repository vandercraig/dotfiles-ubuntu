return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  {
    "github/copilot.vim",
    event = "InsertEnter",
  },

  -- {
  --   "fabridamicelli/cronex.nvim",
  --   event = "VeryLazy",
  --   opts = {},
  -- },
  -- test new blink
  -- { import = "nvchad.blink.lazyspec" },

  {
  	"nvim-treesitter/nvim-treesitter",
  	opts = {
  		ensure_installed = {
  			"vim", "lua", "vimdoc",
       "html", "css", "python", "markdown", "markdown_inline", "toml", "json", "yaml"
  		},
  	},
  },

  -- Telescope configuration to include hidden files
  {
    "nvim-telescope/telescope.nvim",
    opts = function()
      local defaults = require("nvchad.configs.telescope")
      
      -- Override the default find_files configuration to include hidden files
      defaults.defaults.file_ignore_patterns = {
        "node_modules",
        ".git/",
        ".venv/",
        "venv/",
        "env/",
        ".pytest_cache/",
        ".coverage",
        ".mypy_cache/",
        ".ruff_cache/",
        "htmlcov/",
        "dist/",
        "build/",
        "*.egg-info/",
        "target/",
        "*.pyc",
        "__pycache__/",
        "%.lock",
        "Pipfile.lock",
        "poetry.lock",
        "uv.lock",
      }
      
      -- Configure pickers to show hidden files
      defaults.pickers = {
        find_files = {
          hidden = true,
          -- You can also use find_command to customize the search behavior
          find_command = { "rg", "--files", "--hidden", "--glob", "!.git/*" },
        },
        live_grep = {
          additional_args = function()
            return { "--hidden", "--glob", "!.git/*" }
          end,
        },
      }
      
      return defaults
    end,
  },
}
