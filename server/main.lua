--[[
-- @author smuttoN
-- @website www.github.com/sutt0n
-- @date 5/23/2017
--]]

--[[
-- Basics
-]]
Users, commands, settings = {}, {}, {}

--[[
-- Default Settings
-]]
settings.defaults = conf.settings

-- placeholder for session settings
settings.session = {}

require "resources/essential-mode-mysql/lib/mysql"

--[[
-- @param {string} name
-- @param {function} callback
-]]
AddEventHandler("playerConnecting", function(name, callback)
	local identifiers = GetPlayerIdentifiers(source)

	for i = 1, #identifiers do

		local identifier = identifiers[i]
		debugMsg("Checking user ban: " .. identifier .. " (" .. name .. ")")

		local banned = isIdentifierBanned(identifier)
		if(banned) then

			if(type(settings.defaults.bans_verbiage) == "string") then
				callback(settings.defaults.bans_verbiage)
			elseif(type(settings.defaults.bans_verbiage) == "function") then
				callback(settings.defaults.bans_verbiage(identifier, name))
			else
				callback("Default ban reason error.")
			end

			CancelEvent()
		end
	end
end)

AddEventHandler("playerDropped", function()
	if(Users[source]) then

		TriggerEvent("es:playerDropped", Users[source])

		local sql = [[
		UPDATE
			`users`
		SET
			`money` = "@value"
		WHERE
			`identifier` = "@identifier"
		]]

		mysql:exec(sql,
			{
				["@value"] = Users[source].money,
				["@identifier"] = Users[source].identifier
			}
		)

		Users[source] = nil
	end
end)

local just_joined = {}
RegisterServerEvent("es:firstJoinProper")
AddEventHandler("es:firstJoinProper", function()
	local identifiers = GetPlayerIdentifiers(source)
	for i = 1, #identifiers do
		if(Users[source] == nil) then
			debugMsg("Essential | Loading user: " .. GetPlayerName(source))

			local identifier = identifiers[i]
			registerUser(identifier, source)

			TriggerEvent("es:initialized", source)
			just_joined[source] = true

			if(settings.defaults.pvp_enabled) then
				TriggerClientEvent("es:enablePvp", source)
			end
		end
	end
end)

--[[
-- @param {string} key
-- @param {.} val
-]]
AddEventHandler("es:setSessionSetting", function(key, val)
	settings.session[key] = val
end)

--[[
-- @param {string} key
-- @param {function?} callback
-]]
AddEventHandler("es:getSessionSetting", function(key, callback)
	callback(settings.session[key])
end)

RegisterServerEvent("playerSpawn")
AddEventHandler("playerSpawn", function()

	if(just_joined[source]) then

		TriggerEvent("es:firstSpawn", source)
		just_joined[source] = nil
	end
end)

--[[
-- @param {table} tbl
-]]
AddEventHandler("es:setDefaultSettings", function(tbl)
	for key, val in pairs(tbl) do
		if(settings.defaults[key] ~= nil) then
			settings.defaults[key] = val
		end
	end

	debugMsg("Default settings edited.")
end)

--[[
-- @param {string} source
-- @param {?} n
-- @param {string} message
-]]
AddEventHandler("chatMessage", function(source, n, message)
	if(startswith(message, "/")) then

		local command_args = stringsplit(message, " ")
		command_args[1] = string.gsub(command_args[1], "/", "")
		local command = commands[command_args[1]]

		if(command) then

			CancelEvent()

			if(command.perm > 0) then

				if(Users[source].permission_level >= command.perm or Users[source].group:canTarget(command.group)) then
					command.cmd(source, command_args, Users[source])
					TriggerEvent("es:adminCommandRan", source, command_args, Users[source])
				else

					command.callbackfailed(source, command_args, Users[source])
					TriggerEvent("es:adminCommandFailed", source, command_args, Users[source])

					if(type(settings.defaults.permission_denied) == "string" and not WasEventCanceled()) then
						TriggerClientEvent("chatMessage", source, "", {0,0,0}, settings.defaults.permissionDenied)
					end

					debugMsg("Non admin (" .. GetPlayerName(source) .. ") attempted to run admin command: " .. command_args[1])
				end
			else
				command.cmd(source, command_args, Users[source])
				TriggerEvent("es:userCommandRan", source, command_args, Users[source])
			end

			TriggerEvent("es:commandRan", source, command_args, Users[source])
		else
			TriggerEvent("es:invalidCommandHandler", source, command_args, Users[source])

			if WasEventCanceled() then
				CancelEvent()
			end
		end
	else
		TriggerEvent("es:chatMessage", source, message, Users[source])
	end
end)

--[[
-- @param {string} command
-- @param {function} callback
-]]
AddEventHandler("es:addCommand", function(command, callback)
	commands[command] = {}
	commands[command].perm = 0
	commands[command].group = "user"
	commands[command].cmd = callback

	debugMsg("Command added: " .. command)
end)

--[[
-- @param {string} command
-- @param {string} perm
-- @param {function} callback
-- @param {bool} callbackFailed
-]]
AddEventHandler("es:addAdminCommand", function(command, perm, callback, callbackFailed)
	commands[command] = {}
	commands[command].perm = perm
	commands[command].group = "superadmin"
	commands[command].cmd = callback
	commands[command].callbackfailed = callbackFailed

	debugMsg("Admin command added: " .. command .. ", requires permission level: " .. perm)
end)

--[[
-- @param {string} command
-- @param {string} group
-- @param {function} callback
-- @param {bool} callbackFailed
-]]
AddEventHandler("es:addGroupCommand", function(command, group, callback, callbackFailed)
	commands[command] = {}
	commands[command].perm = math.maxinteger
	commands[command].group = group
	commands[command].cmd = callback
	commands[command].callbackfailed = callbackFailed

	debugMsg("Group command added: " .. command .. ", requires group: " .. group)
end)

--[[
-- @param {int} x
-- @param {int} y
-- @param {int} z
-]]
RegisterServerEvent("es:updatePositions")
AddEventHandler("es:updatePositions", function(x, y, z)
	if(Users[source]) then
		Users[source]:setCoords(x, y, z)
	end
end)

-- info command
commands["info"] = {}
commands["info"].perm = 0
commands["info"].cmd = function(source, args, user)
	TriggerClientEvent("chatMessage", source, "SYSTEM", {255, 0, 0}, "^2[^3EssentialModeMySQL^2]^0 Version: ^2" .. conf.system.version)
	TriggerClientEvent("chatMessage", source, "SYSTEM", {255, 0, 0}, "^2[^3EssentialModeMySQL^2]^0 Commands loaded: ^2" .. (returnIndexesInTable(commands) - 1))
end