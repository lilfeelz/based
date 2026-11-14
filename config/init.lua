vim.g.mapleader = ' '

vim.pack.add({ 'https://github.com/ibhagwan/fzf-lua' }, { confirm = false })
local fzf = require('fzf-lua')
local map = vim.keymap.set

map('n', '<leader>ff', fzf.files, { desc = 'files (f)' })
map('n', '<leader>fg', fzf.live_grep, { desc = 'search (s)' })
map('n', '<leader>fw', fzf.grep_cword, { desc = 'search word' })
map('n', '<leader>fb', fzf.buffers, { desc = 'buffers' })
map('n', '<leader>fr', fzf.oldfiles, { desc = 'recent files' })

map('n', '<leader>j', function()
  local out = vim.fn.systemlist({ 'm', 'list' })
  if vim.v.shell_error ~= 0 or #out == 0 then
    vim.notify('m: no sessions', vim.log.levels.WARN)
    return
  end
  fzf.fzf_exec(out, {
    prompt = 'mux> ',
    actions = {
      ['default'] = function(selected)
        if selected and selected[1] then
          vim.fn.system({ 'm', 'attach', selected[1] })
        end
      end,
    },
  })
end, { desc = 'm: switch session' })

map('n', '<leader>d', function()
  vim.fn.system({ 'm', 'detach' })
end, { desc = 'm: detach session' })
