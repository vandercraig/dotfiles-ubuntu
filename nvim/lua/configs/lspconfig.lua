require("nvchad.configs.lspconfig").defaults()

local lspconfig = require "lspconfig"
local nvlsp = require "nvchad.configs.lspconfig"

-- List of servers to enable
local servers = { "html", "cssls", "pyright", "ruff", "marksman", "taplo", "jsonls", "yamlls", "lua_ls" }

-- Setup each server with default config
for _, lsp in ipairs(servers) do
  if lsp == "yamlls" then
    -- Custom YAML setup with schemas
    lspconfig[lsp].setup {
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
  else
    -- Default setup for other servers
    lspconfig[lsp].setup {
      on_attach = nvlsp.on_attach,
      on_init = nvlsp.on_init,
      capabilities = nvlsp.capabilities,
    }
  end
end 
