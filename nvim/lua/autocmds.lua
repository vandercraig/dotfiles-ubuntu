require "nvchad.autocmds"

-- Auto-open tree, navigate to rightmost window, and open horizontal terminal on startup
vim.api.nvim_create_autocmd("VimEnter", {
  pattern = "*",
  callback = function()
    -- Only run if no arguments were passed (opening nvim without a specific file)
    if vim.fn.argc() == 0 then
      vim.schedule(function()
        -- Open the tree (equivalent to <C-n>)
        vim.cmd("NvimTreeToggle")
        
        -- Small delay to ensure tree is loaded
        vim.defer_fn(function()
          -- Navigate to the rightmost window
          vim.cmd("wincmd l")
          
          -- Open horizontal terminal (equivalent to <leader>h)
          -- Assuming this calls the terminal function - adjust if needed
          require("nvchad.term").new({ pos = "sp" })
          
          -- Focus back on the main text buffer (move up from terminal)
          vim.cmd("wincmd k")
          
          -- Ensure we're in normal mode
          vim.cmd("stopinsert")
        end, 100)
      end)
    end
  end,
})
