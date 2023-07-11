packadd lua

lua << EOF
sqlite = require('sqlite')

local SQLiteTables = require('sqlite').tables
local SQLiteTableData = require('sqlite').table_data
local SQLiteColumnNames = require('sqlite').column_names
EOF
