sql = require('sql')

local M = {}
local terminals = {}
local previous_bfnr;

local function create_terminal()
  local current_id = vim.fn.bufnr()

  vim.cmd(":terminal")
  local buf_id = vim.fn.bufnr()
  local term_id  = vim.b.terminal_job_id

  if term_id == nil then
    -- TODO: Throw an erro?
    return nil
  end

  -- Make sure the term buffer has "hidden" set so it doesn't get thrown
  -- away and cause an error
  vim.api.nvim_buf_set_option(buf_id, 'bufhidden', 'hide')

  -- Resets the buffer back to the old one
  vim.api.nvim_set_current_buf(current_id)
  return buf_id, term_id
end

function find_terminal(idx)
  local current_id = vim.fn.bufnr()
  if vim.api.nvim_buf_get_option(current_id, 'buftype') ~= "terminal" then
    previous_bfnr = current_id;
  end

  local term_handle = terminals[idx]
  if not term_handle or not vim.api.nvim_buf_is_valid(term_handle.buf_id) then
    local buf_id, term_id = create_terminal()
    if buf_id == nil then
      return
    end

    term_handle = {
      buf_id = buf_id,
      term_id = term_id
    }
    terminals[idx] = term_handle
  end
  return term_handle
end

M.gotoTerminal = function(idx)
  local term_handle = find_terminal(idx)

  vim.api.nvim_set_current_buf(term_handle.buf_id)
end

M.switch_back = function()
  vim.api.nvim_set_current_buf(previous_bfnr);
end

function prevCommand(idx)
  local cmd =  sql.with_open(os.getenv('HOME')..'/.cache/nvim/nvim_term_bindings.sqlite3', function(db)
    return db:eval([[select cmd 
    from termbinds 
    where termid = ? and ? like dir||'%' 
    order by length(dir) 
    limit 1]], {idx, vim.api.nvim_exec('pwd', true)})
  end)

  if type(cmd) == "boolean"then
    print('No command found in history')
    return nil
  else
    return cmd[1].cmd
  end
end

M.sendCommand = function(idx, cmd, ...)
  local term_handle = find_terminal(idx)

  if cmd then
    sql.with_open(os.getenv('HOME').."/.cache/nvim/nvim_term_bindings.sqlite3", function(db)
      db:eval([[create table if not exists termbinds (
      dir varchar(20),
      termid int,
      cmd varchar(50),
      primary key(dir, termid)
      )]])
      db:eval("insert or replace into termbinds values(?, ?, ?)", {vim.api.nvim_exec('pwd', true),  idx,  cmd});
    end)
  else
    cmd = prevCommand(idx)
  end

  if cmd then
    vim.fn.chansend(term_handle.term_id, string.format(cmd, ...))
  end
end

return M
