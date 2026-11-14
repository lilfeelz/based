vim.g.mapleader = vim.keycode('<C-_>')
vim.keymap.set({ 'n', 'x' }, '<C-/>', '<C-_>', { remap = true })

vim.pack.add({ 'https://github.com/ibhagwan/fzf-lua' }, { confirm = false })
local fzf = require('fzf-lua')
local map = vim.keymap.set

map('n', '<leader>f', fzf.files, { desc = 'files (f)' })
map('n', '<leader>s', fzf.live_grep, { desc = 'search (s)' })
map('n', '<leader>w', fzf.grep_cword, { desc = 'search word' })
map('n', '<leader>b', fzf.buffers, { desc = 'buffers' })
map('n', '<leader>o', fzf.oldfiles, { desc = 'oldfiles' })

map('n', '<leader>j', function()
  local out = vim.fn.systemlist({ 'm' })
  if vim.v.shell_error ~= 0 or #out == 0 then
    vim.notify('m: no sessions', vim.log.levels.WARN)
    return
  end
  fzf.fzf_exec(out, {
    prompt = 'mux> ',
    actions = {
      ['default'] = function(selected)
        if selected and selected[1] then
          vim.fn.system({ 'm', selected[1] })
        end
      end,
    },
  })
end, { desc = 'm: switch session' })

map('n', '<leader>d', function()
  vim.fn.system({ 'm', 'detach' })
end, { desc = 'm: detach session' })
