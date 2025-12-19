require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>", { desc = "Exit insert mode" })
map("t", "jk", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Neogen
map("n", "<leader>cg", function()
  require("neogen").generate()
end, { noremap = true, silent = true, desc = "Neogen: Generate" })

map("n", "<leader>cf", function()
  require("neogen").generate({ type = "func" })
end, { noremap = true, silent = true, desc = "Neogen: Function" })

map("n", "<leader>cc", function()
  require("neogen").generate({ type = "class" })
end, { noremap = true, silent = true, desc = "Neogen: Class" })

map("n", "<leader>ct", function()
  require("neogen").generate({ type = "type" })
end, { noremap = true, silent = true, desc = "Neogen: Type" })
-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
