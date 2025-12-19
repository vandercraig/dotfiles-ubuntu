require("nvchad.configs.lspconfig").defaults()

local nvlsp = require "nvchad.configs.lspconfig"

-- Configure LSP servers using the new vim.lsp.config API
vim.lsp.config.yamlls = {
  cmd = { 'yaml-language-server', '--stdio' },
  filetypes = { 'yaml' },
  root_markers = { '.git' },
  single_file_support = true,
  on_attach = nvlsp.on_attach,
  on_init = nvlsp.on_init,
  capabilities = nvlsp.capabilities,
  settings = {
    yaml = {
      schemas = {
        ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
        ["https://json.schemastore.org/github-action.json"] = "/.github/actions/*/action.{yml,yaml}",
        ["https://raw.githubusercontent.com/microsoft/azure-pipelines-vscode/master/service-schema.json"] = ".azure-pipelines/*.{yml,yaml}",
        ["https://json.schemastore.org/docker-compose.json"] = "docker-compose*.{yml,yaml}",
        ["https://json.schemastore.org/gitlab-ci.json"] = ".gitlab-ci.{yml,yaml}",
        ["https://json.schemastore.org/kustomization.json"] = "kustomization.{yml,yaml}",
        ["https://json.schemastore.org/ansible-playbook.json"] = "playbook*.{yml,yaml}",
        ["https://raw.githubusercontent.com/instrumenta/kubernetes-json-schema/master/v1.18.0-standalone-strict/all.json"] = "*.k8s.{yml,yaml}",
        ["https://json.schemastore.org/databricks-asset-bundles.json"] = {
          "databricks*.{yml,yaml}",
          "resources/*.{yml,yaml}"
        },
      },
      validate = true,
      completion = true,
      hover = true,
      schemaStore = {
        enable = true,
        url = "https://www.schemastore.org/api/json/catalog.json",
      },
    },
  },
}

vim.lsp.config.basedpyright = {
  cmd = { 'basedpyright-langserver', '--stdio' },
  filetypes = { 'python' },
  root_markers = { '.git', 'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', 'Pipfile' },
  single_file_support = true,
  on_attach = nvlsp.on_attach,
  on_init = nvlsp.on_init,
  capabilities = nvlsp.capabilities,
  settings = {
    basedpyright = {
      analysis = {
        typeCheckingMode = "basic",
      },
    },
  },
}

vim.lsp.config.ruff = {
  cmd = { 'ruff', 'server', '--preview' },
  filetypes = { 'python' },
  root_markers = { '.git', 'pyproject.toml', 'ruff.toml', '.ruff.toml' },
  single_file_support = true,
  on_attach = nvlsp.on_attach,
  on_init = nvlsp.on_init,
  capabilities = nvlsp.capabilities,
}

vim.lsp.config.lua_ls = {
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
  root_markers = { '.git', '.luarc.json', '.luarc.jsonc', '.luacheckrc', '.stylua.toml', 'stylua.toml' },
  single_file_support = true,
  on_attach = nvlsp.on_attach,
  on_init = nvlsp.on_init,
  capabilities = nvlsp.capabilities,
}

vim.lsp.config.jsonls = {
  cmd = { 'vscode-json-language-server', '--stdio' },
  filetypes = { 'json', 'jsonc' },
  root_markers = { '.git' },
  single_file_support = true,
  on_attach = nvlsp.on_attach,
  on_init = nvlsp.on_init,
  capabilities = nvlsp.capabilities,
}

vim.lsp.config.html = {
  cmd = { 'vscode-html-language-server', '--stdio' },
  filetypes = { 'html' },
  root_markers = { '.git' },
  single_file_support = true,
  on_attach = nvlsp.on_attach,
  on_init = nvlsp.on_init,
  capabilities = nvlsp.capabilities,
}

vim.lsp.config.cssls = {
  cmd = { 'vscode-css-language-server', '--stdio' },
  filetypes = { 'css', 'scss', 'less' },
  root_markers = { '.git' },
  single_file_support = true,
  on_attach = nvlsp.on_attach,
  on_init = nvlsp.on_init,
  capabilities = nvlsp.capabilities,
}

vim.lsp.config.marksman = {
  cmd = { 'marksman', 'server' },
  filetypes = { 'markdown' },
  root_markers = { '.git' },
  single_file_support = true,
  on_attach = nvlsp.on_attach,
  on_init = nvlsp.on_init,
  capabilities = nvlsp.capabilities,
}

vim.lsp.config.taplo = {
  cmd = { 'taplo', 'lsp', 'stdio' },
  filetypes = { 'toml' },
  root_markers = { '.git' },
  single_file_support = true,
  on_attach = nvlsp.on_attach,
  on_init = nvlsp.on_init,
  capabilities = nvlsp.capabilities,
}

vim.lsp.config.bashls = {
  cmd = { 'bash-language-server', 'start' },
  filetypes = { 'sh', 'bash', 'zsh' },
  root_markers = { '.git' },
  single_file_support = true,
  on_attach = nvlsp.on_attach,
  on_init = nvlsp.on_init,
  capabilities = nvlsp.capabilities,
}

-- Enable the LSP configs
vim.lsp.enable('yamlls')
vim.lsp.enable('basedpyright')
vim.lsp.enable('ruff')
vim.lsp.enable('lua_ls')
vim.lsp.enable('jsonls')
vim.lsp.enable('html')
vim.lsp.enable('cssls')
vim.lsp.enable('marksman')
vim.lsp.enable('taplo')
vim.lsp.enable('bashls')

-- Associate .envrc files with bash filetype for LSP support
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
  pattern = {".envrc", "*.envrc"},
  callback = function()
    vim.bo.filetype = "bash"
  end,
})
