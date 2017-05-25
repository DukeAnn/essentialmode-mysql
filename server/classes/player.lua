--[[
-- @author smuttoN
-- @website www.github.com/sutt0n
-- @date 5/23/2017
--]]

-- constructor
Player = {}
Player.__index = Player

-- meta table for players
setmetatable(Player, {
	__call = function(self, _source, _permission_level, _money, _identifier, _group)
		local pl = {}

		pl.source           = _source
		pl.permission_level = _permission_level
		pl.money            = _money
		pl.identifier       = _identifier
		pl.group            = _group
		pl.coords           = { x = 0.0, y = 0.0, z = 0.0 }
		pl.session          = {}

		return setmetatable(pl, Player)
	end
})

--[[
-- Get permissions.
]]
function Player:getPermissions()
	return self.permission_level
end

--[[
-- Set permissions.
-- @param {string} permission
-]]
function Player:setPermissions(permission)
	TriggerEvent("es:setPlayerData", self.source, "permission_level", permission, function(response, success)
		self.permission_level = permission
	end)
end

--[[
-- No need to ever call this (No, it doesn't teleport the player).
-- @param {int} x
-- @param {int} y
-- @param {int} z
-]]
function Player:setCoords(x, y, z)
	self.coords.x, self.coords.y, self.coords.z = x, y, z
end

--[[
-- Kicks a player with specified reason.
-- @param {string} reason
]]
function Player:kick(reason)
	DropPlayer(self.source, reason)
end

--[[
-- Sets the player money (required to call this from now).
-- @param {double} _money
-]]
function Player:setMoney(_money)
	local prevMoney = self.money
	local newMoney : double = _money

	self.money = _money

	if((prevMoney - newMoney) < 0) then
		TriggerClientEvent("es:addedMoney", self.source, math.abs(prevMoney - newMoney))
	else
		TriggerClientEvent("es:removedMoney", self.source, math.abs(prevMoney - newMoney))
	end

	TriggerClientEvent("es:activateMoney", self.source , self.money)
end

--[[
-- Adds to player money (required to call this from now).
-- @param {double} _money
-]]
function Player:addMoney(_money)
	local newMoney : double = self.money + _money

	self.money = newMoney

	TriggerClientEvent("es:addedMoney", self.source, _money)
	TriggerClientEvent("es:activateMoney", self.source , self.money)
end

--[[
-- Removes from player money (required to call this from now).
-- @param {double} _money
-]]
function Player:removeMoney(_money)
	local newMoney : double = self.money - _money

	self.money = newMoney

	TriggerClientEvent("es:removedMoney", self.source, _money)
	TriggerClientEvent("es:activateMoney", self.source , self.money)
end

--[[
-- Player session variables.
-- @param {string} key
-- @param {string} value
-]]
function Player:setSessionVar(key, value)
	self.session[key] = value
end

--[[
-- Get session variable.
-- @param {string} key
-]]
function Player:getSessionVar(key)
	return self.session[key]
end