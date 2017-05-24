--[[
-- @author smuttoN
-- @website www.github.com/sutt0n
-- @date 5/23/2017
--]]

--[[
-- @param {string} delimiter
 ]]
function stringsplit(self, delimiter)
	local a = self:Split(delimiter)
	local t = {}

	for i = 0, #a - 1 do
		table.insert(t, a[i])
	end

	return t
end

--[[
-- @param {string} str
-- @param {string} start
 ]]
function startswith(str, start)
	return string.sub(str, 1, string.len(start)) == start
end

--[[
-- @param {table} _table
 ]]
function returnIndexesInTable(_table)
	local i = 0;

	for _,v in pairs(_table)do
		i = i + 1
	end

	return i;
end

--[[
-- @param {string} msg
 ]]
function debugMsg(msg)
	if(settings.defaults.debug_mode and msg) then
		print("ES_DEBUG: " .. msg)
	end
end

AddEventHandler("es:debugMsg", debugMsg)