local M = {}

local slots_file = vim.fn.stdpath 'data' .. '/my_nvim_slots.json'

M.config = {
  leader = vim.g.mapleader or ' ',
  add_prefix = 'bs',
  go_prefix = 'b',
}

M.slots = {}

-- Load slots from file
local function load_slots()
  local f = io.open(slots_file, 'r')
  if f then
    local content = f:read '*a'
    f:close()
    if content and content ~= '' then
      local ok, data = pcall(vim.fn.json_decode, content)
      if ok and type(data) == 'table' then
        M.slots = data
      end
    end
  end
end

-- Save slots to file
local function save_slots()
  local f = io.open(slots_file, 'w')
  if f then
    f:write(vim.fn.json_encode(M.slots))
    f:close()
  end
end

function M.add_to_slot(slot)
  local current_file = vim.api.nvim_buf_get_name(0)
  if current_file == '' then
    print 'No file open to add!'
    return
  end
  M.slots[slot] = current_file
  save_slots()
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

  load_slots() -- Load slots at startup

  local leader = M.config.leader
  for i = 1, 9 do
    vim.keymap.set('n', leader .. M.config.add_prefix .. i, function()
      M.add_to_slot(i)
    end, { noremap = true, silent = true })

    vim.keymap.set('n', leader .. M.config.go_prefix .. i, function()
      M.go_to_slot(i)
    end, { noremap = true, silent = true })
  end

  -- Auto-save slots when exiting Neovim
  vim.api.nvim_create_autocmd('VimLeavePre', {
    pattern = '*',
    callback = save_slots,
  })
end

return M
