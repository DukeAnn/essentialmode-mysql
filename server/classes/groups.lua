--[[
-- @author smuttoN
-- @website www.github.com/sutt0n
-- @date 5/23/2017
--]]

groups = {}

-- constructor
Group = {}
Group.__index = Group

-- meta table for groups
setmetatable(Group, {
	__eq = function(self)
			return self.group
	end,

	__tostring = function(self)
		return self.group
	end,

	__call = function(self, group, inh)
		local gr = {}

		gr.group = group
		gr.inherits = inh

		groups[group] = gr
		return setmetatable(gr, Group)
	end
})

--[[
-- Check if a certain group can target one another.
-- @param {string} _group
--]]
function Group:canTarget(_group)
	if(self.group == 'user') then
		return false
	else
		if(self.group == _group) then
			return true
		elseif(self.inherits == _group) then
			return true
		elseif(self.inherits == 'superadmin') then
			return true
		else
			if(self.inherits == 'user') then
				return false
			else
				return groups[self.inherits]:canTarget(_group)
			end
		end
	end
end

-- init groups
user = Group("user", "")
admin = Group("admin", "user")
superadmin = Group("superadmin", "admin")

--[[
-- Create custom groups.
-- @param {string} group
-- @param {string} inherits
-- @param {function} callback
-]]
AddEventHandler("es:addGroup", function(group, inherit, callback)
	if(inherit == "user")then
		admin.inherits = group
	end

	local rtVal = Group(group, inherit)

	callback(rtVal)
end)

--[[
-- Get all groups.
-- @param {function} callback
-]]
AddEventHandler("es:getAllGroups", function(callback)
	callback(groups)
end)