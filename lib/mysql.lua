--[[
-- @author smuttoN
-- @website www.github.com/sutt0n
-- @date 5/22/2017
--]]

mysql = setmetatable({}, mysql)
mysql.__index = mysql

--[[
-- @property {MySqlClient} client
-- @property {MySqlConnection} conn
-]]

local conn_opened = false

--[[
-- Create a new MySQL connection.
-- @param {string} server
-- @param {string} db
-- @param {string} user
-- @param {string} pass
-]]
function mysql.open(self, server, db, user, pass)

	-- manage number of connections
	if(conn_opened) then
		print("Attempted to open a MySQL connection, but one is already opened.")
		return
	end

	-- basics
	local refl  = clr.System.Reflection

	-- load dll
	refl.Assembly.LoadFrom("resources/essential-mode-mysql/lib/MySql.Data.dll")

	-- init
	print("Initializing MySQL connection.")
	self.client = clr.MySql.Data.MySqlClient
	self.conn   = self.client.MySqlConnection("server=".. server ..";database=".. db ..";userid=".. user ..";password=".. pass)

	-- open connection
	print("Opening MySQL connection.")
	self.conn.Open();

	-- resource management
	conn_opened = true

	-- todo: error handling?
end

--[[
-- Execute the query.
-- @param {string} cmd
-- @param {table} params
-]]
function mysql.exec(self, cmd, params)
	local _cmd = self.conn.CreateCommand()
	_cmd.CommandText = cmd

	if type(params) == "table" then

		-- exec escapeStr in each param
		for param in pairs(params) do
			_cmd.CommandText = string.gsub(_cmd.CommandText, param, self:escape(params[param]))
		end
	end

	-- todo: check other possible datatypes for `params`

	-- execute query
	local _res = _cmd.ExecuteNonQuery()
	print("Query Exec: [".. _res .."]: \"".. _cmd.CommandText .."\"")

	-- return
	return {
		cmd = _cmd,
		res = _res
	}

end

--[[
-- Get the query results.
-- @param {MySqlCommand|table} cmd
-- @param {table} fields
-]]
function mysql.getResults(self, cmd, fields)

	-- assert (todo: try assert(x,y))
	if type(fields) ~= "table" or #fields == 0 then
		return nil
	end

	-- double check we get the MySqlCommand object so we can read it
	if type(cmd) == "table" and cmd["cmd"] ~= nil then
		cmd = cmd["cmd"]
	end

	local reader = cmd:ExecuteReader()
	local records = {}
	local i = 0

	-- populate res table with query results
	while reader:Read() do

		-- increment and allocate next result
		i = #records + 1
		records[i] = {}

		-- populate current record
		for field in pairs(fields) do
			records[i][fields[field]] = self:_getFieldByName(reader, fields[field])
		end
	end

	-- close the reader
	reader:Close()

	-- return
	return records
end

--[[
-- Escapes the input string for any single quotations.
-- @param {string} input
-]]
function mysql.escape(self, input)
	return self.client.MySqlHelper.EscapeString(input)
end

--[[
-- Gets the field by its name.
-- @param {MySqlReader} reader
-- @param {string} name
-]]
function mysql._getFieldByName(self, reader, name)
	local type = tostring(reader:GetFieldType(name))

	-- todo: make a better switch statement, this is annoying garbage
	if(typ == "System.DateTime") then
		return reader:GetDateTime(name)
	elseif(typ == "System.Double") then
		return reader:GetDouble(name)
	elseif(typ == "System.Int32") then
		return reader:GetInt32(name)
	else
		return reader:GetString(name)
	end

end

--[[
-- Gets all records.
-- @param {string} cmd
-- @param {table} params
-- @param {table} fields
-]]
function mysql.getMany(self, cmd, params, fields)
	local res_tbl = self:exec(cmd, params)

	return self:getResults(res_tbl, fields)
end

--[[
-- Gets one record.
-- @param {string} cmd
-- @param {table} params
-- @param {table} fields
-]]
function mysql.getOne(self, cmd, params, fields)
	local res_tbl = self:exec(cmd, params)
	local res = self:getResults(res_tbl, fields)

	if(res) then
		return res[1]
	end

	return nil
end