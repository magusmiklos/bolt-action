local M = {}

M.config = {
  leader = vim.g.mapleader or ' ',
  add_prefix = 'bs',
  go_prefix = 'b',
}

M.slots = {}

function M.add_to_slot(slot)
  local current_file = vim.api.nvim_buf_get_name(0)
  if current_file == '' then
    print 'No file open to add!'
    return
  end
  M.slots[slot] = current_file
  print('Added file to slot ' .. slot)
end

function M.go_to_slot(slot)
  local file = M.slots[slot]
  if file then
    vim.cmd('edit ' .. vim.fn.fnameescape(file))
  else
    print('No file stored in slot ' .. slot)
  end
end

function M.setup(user_config)
  if user_config then
    M.config = vim.tbl_extend('force', M.config, user_config)
  end

  local leader = M.config.leader
  for i = 1, 9 do
    vim.keymap.set('n', leader .. M.config.add_prefix .. i, function()
      M.add_to_slot(i)
    end, { noremap = true, silent = true })

    vim.keymap.set('n', leader .. M.config.go_prefix .. i, function()
      M.go_to_slot(i)
    end, { noremap = true, silent = true })
  end
end

return M
