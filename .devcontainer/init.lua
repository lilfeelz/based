vim.g.mapleader = ' '

vim.opt.runtimepath:prepend(vim.env.BASED_FZF_LUA or (vim.fn.stdpath('data') .. '/fzf-lua'))
local fzf = require('fzf-lua')
local map = vim.keymap.set

map('n', '<leader>ff', fzf.files, { desc = 'files (fd)' })
map('n', '<leader>fg', fzf.live_grep, { desc = 'grep (rg)' })
map('n', '<leader>fw', fzf.grep_cword, { desc = 'grep word (rg)' })
map('n', '<leader>fb', fzf.buffers, { desc = 'buffers' })
map('n', '<leader>fr', fzf.oldfiles, { desc = 'recent files' })

local function in_session()
  return (vim.env.ZMX_SESSION or '') ~= ''
end

map('n', '<leader>j', function()
  if not in_session() then
    vim.notify('zmx: not in a session', vim.log.levels.WARN)
    return
  end
  local out = vim.fn.systemlist({ 'zmx', 'list', '--short' })
  if vim.v.shell_error ~= 0 then return end
  local current = vim.env.ZMX_SESSION
  local sessions = {}
  for _, name in ipairs(out) do
    if name ~= '' and name ~= current then sessions[#sessions + 1] = name end
  end
  if #sessions == 0 then
    vim.notify('zmx: no other sessions', vim.log.levels.WARN)
    return
  end
  fzf.fzf_exec(sessions, {
    prompt = 'zmx> ',
    fzf_opts = { ['--preview'] = 'zmx history {} | tail -40' },
    actions = {
      ['default'] = function(selected)
        local result = vim.fn.system({ 'zmx', 'attach', selected[1] })
        if vim.v.shell_error ~= 0 then
          vim.notify('zmx: ' .. result, vim.log.levels.ERROR)
        end
      end,
    },
  })
end, { desc = 'zmx: jump' })

map('n', '<leader>d', function()
  if in_session() then
    vim.fn.system({ 'zmx', 'detach' })
  else
    vim.notify('zmx: not in a session', vim.log.levels.WARN)
  end
end, { desc = 'zmx: detach' })
