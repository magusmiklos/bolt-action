local M = {}

local slots_file = vim.fn.stdpath 'data' .. '/my_nvim_slots.json'

M.config = {
  leader = vim.g.mapleader or ' ',
  add_prefix = 'bs',
  go_prefix = 'b',
  view_prefix = 'bv',
  delete_prefix = 'bd',
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

-- Delete slot
function M.delete_slot(slot)
  M.slots[slot] = nil
  save_slots()
  print('Slot was deleted ' .. slot)
end

function M.add_to_slot(slot)
  local current_file = vim.api.nvim_buf_get_name(0)
  if current_file == '' then
    print 'No file open to add!'
    return
  end
  M.slots[slot] = {
    file = current_file,
    pos = vim.api.nvim_win_get_cursor(0),
  }
  save_slots()
  print('Added file to slot ' .. slot)
end

function M.go_to_slot(slot)
  local slot_data = M.slots[slot]
  if type(slot_data) ~= 'table' or not slot_data.file or not slot_data.pos then
    return print 'Empty or invalid slot'
  end

  local file = slot_data.file
  local current_file = vim.api.nvim_buf_get_name(0)

  if file == current_file then
    vim.api.nvim_win_set_cursor(0, M.slots[slot].pos)
  elseif vim.fn.filereadable(file) ~= 0 then
    vim.cmd('edit ' .. vim.fn.fnameescape(file))
    vim.api.nvim_win_set_cursor(0, M.slots[slot].pos)
  else
    M.slots[slot] = nil
    print('File removed ' .. slot)
  end
end

function M.show_slots_window()
  -- Create buffer and window
  local buf = vim.api.nvim_create_buf(false, true)

  local width = math.floor(vim.o.columns * 0.5) -- 50% of the screen width
  local height = math.floor(vim.o.lines * 0.3) -- 30% of the screen height
  local row = math.floor((vim.o.lines - height) / 2) -- Center vertically
  local col = math.floor((vim.o.columns - width) / 2) -- Center horizontally

  -- Create window config
  local opts = {
    relative = 'editor',
    width = width,
    height = height,
    col = col,
    row = row,
    style = 'minimal',
    border = 'rounded',
    noautocmd = true,
  }

  -- Create window
  local win = vim.api.nvim_open_win(buf, true, opts)

  -- Set window options
  vim.bo[buf].filetype = 'bolt-action'
  vim.api.nvim_win_set_option(win, 'winhl', 'Normal:NormalFloat')
  vim.api.nvim_win_set_option(win, 'wrap', false)

  -- Create content lines
  local lines = {}
  for i = 1, 9 do
    local slot = M.slots[i]
    local status
    if type(slot) == 'table' and type(slot.file) == 'string' then
      status = '● ' .. vim.fn.fnamemodify(slot.file .. ' line: ' .. slot.pos[1] .. ' col: ' .. slot.pos[2], ':~:.')
    else
      status = '○ Empty'
    end
    lines[i] = string.format(' %d: %s', i, status)
  end -- Add header
  table.insert(lines, 1, ' Bolt Action ( -_•)▄︻デ══━一')
  table.insert(lines, 2, string.rep('─', width - 2))

  -- Set buffer content
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  -- Put cursor at under header
  vim.api.nvim_win_set_cursor(win, { 3, 0 })

  -- Add syntax highlighting
  vim.api.nvim_buf_add_highlight(buf, -1, 'Title', 0, 0, -1)
  for i = 3, 11 do
    if M.slots[i - 2] then
      vim.api.nvim_buf_add_highlight(buf, -1, 'Directory', i - 1, 7, -1)
    else
      vim.api.nvim_buf_add_highlight(buf, -1, 'Comment', i - 1, 7, -1)
    end
  end

  -- Close window on escape/enter
  vim.api.nvim_buf_set_keymap(buf, 'n', '<Esc>', '<cmd>q!<CR>', { silent = true, noremap = true })
  vim.api.nvim_buf_set_keymap(buf, 'n', '<CR>', '', {
    silent = true,
    noremap = true,
    callback = function()
      local slot = vim.api.nvim_win_get_cursor(win)[1] - 2
      if slot and slot > 0 and slot < 10 then
        vim.api.nvim_win_close(win, true)
        M.go_to_slot(slot)
      end
    end,
  })
  vim.api.nvim_buf_set_keymap(buf, 'n', 'd', '', {
    silent = true,
    noremap = true,
    callback = function()
      local line = vim.api.nvim_win_get_cursor(win)[1]
      local slot = line - 2

      local line_str = string.format(' %d: ○ Empty', slot)
      if slot and slot > 0 and slot < 10 then
        M.delete_slot(slot)
        vim.api.nvim_buf_set_lines(buf, line - 1, line, false, { line_str })
      end
    end,
  })
end

function M.setup(user_config)
  if user_config then
    M.config = vim.tbl_extend('force', M.config, user_config)
  end

  load_slots() -- Load slots at startup

  local leader = M.config.leader

  vim.keymap.set('n', leader .. M.config.view_prefix, function()
    M.show_slots_window()
  end, { noremap = true, silent = true, desc = 'Show bolt slots' })

  for i = 1, 9 do
    vim.keymap.set('n', leader .. M.config.add_prefix .. i, function()
      M.add_to_slot(i)
    end, { noremap = true, silent = true })

    vim.keymap.set('n', leader .. M.config.go_prefix .. i, function()
      M.go_to_slot(i)
    end, { noremap = true, silent = true })

    vim.keymap.set('n', leader .. M.config.delete_prefix .. i, function()
      M.delete_slot(i)
    end, { noremap = true, silent = true })
  end

  -- Auto-save slots when exiting Neovim
  vim.api.nvim_create_autocmd('VimLeavePre', {
    pattern = '*',
    callback = save_slots,
  })
end

return M
