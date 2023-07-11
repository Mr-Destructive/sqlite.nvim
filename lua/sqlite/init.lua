local M = {}
--Table_data("db.sqlite3", "accounts_user")
--tables("db.sqlite3")
--Column_names("db.sqlite3", "chat_room")

local sqlite3 = require("lsqlite3")

local function get_column_names_list(db, column_name)
  local buf = vim.api.nvim_create_buf(false, true)
  
  local max_col_name_length = 0
  local max_col_type_length = 0
    
  local columns = {}
  local cols = db:prepare("PRAGMA table_info('" .. column_name .. "')")
  while cols:step() == sqlite3.ROW do
    local col_row = cols:get_values()
    local col_name = col_row[2]
    table.insert(columns, col_name) 
  end
  return columns
end

M.tables =  function()
  local file_path = vim.fn.input("DB file name/path: ") 
  local lsqlite3 = require('lsqlite3')
  local db = lsqlite3.open(file_path)

  local stmt = db:prepare("SELECT name FROM sqlite_master WHERE type='table'") 
  if not stmt then
      error("Error preparing query: " .. db:errmsg())
  end

  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, false, {
    relative = "win",
    width = 40,
    height = 20, 
    col = 10,
    row = 5,
    style = "minimal",
    border = "rounded"  
  })

  while stmt:step() == sqlite3.ROW do
    local row = stmt:get_values()
    local s = row[1]
    vim.api.nvim_buf_set_lines(buf, -1, -1, false, {s})
  end

  stmt:finalize() 
  db:close() 
end

M.column_names = function()
  local file_path = vim.fn.input("DB file name/path: ") 
  local table_name = vim.fn.input("Table name: ")

  local db = sqlite3.open(file_path)
  local buf = vim.api.nvim_create_buf(false, true)
  
  local max_col_name_length = 0
  local max_col_type_length = 0
    
  local cols = db:prepare("PRAGMA table_info('" .. table_name .. "')")
  while cols:step() == sqlite3.ROW do
    local col_row = cols:get_values()
    local col_name = col_row[2]
    local col_type = col_row[3]
    
    if #col_name > max_col_name_length then
      max_col_name_length = #col_name
    end
      
    if #col_type > max_col_type_length then
      max_col_type_length = #col_type
    end
    
    local col_info = string.format("%-20s  (%s)", col_name, col_type)
    print(col_info)
    vim.api.nvim_buf_set_lines(buf, -1, -1, false, {col_info})
  end
  
  cols:reset()
  
  local heading = string.format("Table : %s", table_name)
  vim.api.nvim_buf_set_lines(buf, 0, 0, false, {heading})
  local win = vim.api.nvim_open_win(buf, false, {
    relative = "win",
    width = 40,
    height = 10,
    col = 10,
    row = 10,
    style = "minimal",
    border = "rounded"  
  })
  db:close() 
end

M.table_data = function()
  local file_path = vim.fn.input("DB file name/path: ") 
  local table_name = vim.fn.input("Table name: ")
  local db = sqlite3.open(file_path)
  local buf = vim.api.nvim_create_buf(false, true)
  
  local stmt = db:prepare("SELECT * FROM " .. table_name)
  if not stmt then
    error("Error preparing query: " .. db:errmsg())
  end
  
  local col_names = get_column_names_list(db, table_name)
  vim.api.nvim_buf_set_lines(buf, 1, -1, false, col_names)
  
  rows_num = {}
  for row in stmt:urows() do
      print(row)
    table.insert(rows_num, row)
  end

  local rows = {}
  while stmt:step() == sqlite3.ROW do
    local row = {}
    for i = 1, #col_names do
      row[i] = stmt:get_value(i - 1)
    end
    table.insert(rows, row)
  end
  
  stmt:finalize()
  
  local table_lines = {}
  
  table.insert(table_lines, table.concat(col_names, " | "))
  
  local separator_line = string.rep("-", #table_lines[1])
  table.insert(table_lines, separator_line)
  
  for _, row in ipairs(rows) do
    local formatted_row = {}
    for _, value in ipairs(row) do
      table.insert(formatted_row, tostring(value))
    end
    table.insert(table_lines, table.concat(formatted_row, " | "))
  end
  
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, table_lines)
  
  local win = vim.api.nvim_open_win(buf, false, {
    relative = "win",
    width = 80,
    height = math.max(#table_lines, 20),
    col = 10,
    row = 10,
    style = "minimal",
    border = "rounded"
  })
  db:close() 
end


return M
