--[[
-- @author smuttoN
-- @website www.github.com/sutt0n
-- @date 5/23/2017
--]]

require "resources/essential-mode-mysql/lib/mysql"

mysql:open(
	conf.db.hostname,
	conf.db.database,
	conf.db.username,
	conf.db.password
)

--[[
-- Loads the user.
-- @param {string} identifier
-]]
function loadUser(identifier, source, new)
	local sql = [[
	SELECT
		`permission_level`,
		`money`,
		`identifier`,
		`group`,
		`bank`
	FROM
		`users`
	WHERE
		`identifier` = '@name'
	]]

	local user = mysql:getOne(
		sql,
		{
			['@name'] = identifier
		},
		{
			"permission_level",
			"money",
			"identifier",
			"group",
			"bank"
		}
	)

	local group = groups[user.group]
	Users[source] = Player(
		source,
		user.permission_level,
		user.money,
		user.identifier,
		user.group
	)

	print("Displaying cash!")
	print("Money: " .. user.money)
	print("Bank: " .. user.bank)
	DisplayCash(true)
	SetSingleplayerHudCash(user.money, user.bank)
--	SetMultiplayerBankCash(user.bank)

	TriggerEvent("es:playerLoaded", source, Users[source])
	TriggerClientEvent("es:setPlayerDecorator", source, "rank", Users[source]:getPermissions())

	if(new) then
		TriggerEvent("es:newPlayerLoaded", source, Users[source])
	end
end

--[[
-- Checks if the user with the current identifier is currently banned.
-- @param {string} identifier
]]
function isIdentifierBanned(identifier)
	local sql = [[
	SELECT
		`expires`,
		`reason`,
		`timestamp`
	FROM
		`bans`
	WHERE
		`banned` = '@name'
	]]

	local bans = mysql:getMany(
		sql,
		{
			['@name'] = identifier
		},
		{
			"expires",
			"reason",
			"timestamp"
		}
	)

	if(bans) then
		for key, ban in ipairs(bans) do
			if ban.expires > ban.timestamp then
				return true
			end
		end
	end

	return false
end

--[[
-- Determines if the identifier has an established account.
-- @param {string} identifier
-]]
function hasAccount(identifier)
	local sql = [[
	SELECT
		`identifier`
	FROM
		`users`
	WHERE
		`identifier` = '@name'
	]]

	local user = mysql:getOne(
		sql,
		{
			['@name'] = identifier
		},
		{
			"identifier"
		}
	)

	if(user ~= nil) then
		return true
	end

	return false
end

--[[
-- Determine if the player is logged in.
-- @param {string} source
-]]
function isLoggedIn(source)
	if(Users[GetPlayerName(source)] ~= nil) then
		if(Users[GetPlayerName(source)]["isLoggedIn"] == 1) then
			return true
		else
			return false
		end
	else
		return false
	end
end

--[[
-- Registers the user if necessary; otherwise, it loads the user.
-- @param {string} identifier
-- @param {string} source
-]]
function registerUser(identifier, source)
	if not hasAccount(identifier) then
		local sql = [[
		INSERT INTO `users`
		(
			`identifier`,
			`permission_level`,
			`money`,
			`group`
		)
		VALUES
		(
			'@username',
			'@permission_level',
			'@money',
			'@group'
		)
		]]

		mysql:exec(
			sql,
			{
				["@username"] = identifier,
				["@permission_level"] = 0,
				["@money"] = settings.defaults.starting_cash,
				["@group"] = "user",
			}
		)

		loadUser(identifier, source, true)
	else
		loadUser(identifier, source)
	end
end

--[[
-- @param {string} user
-- @param {string} key
-- @param {string} val
-- @param {function} callback
-]]
AddEventHandler("es:setPlayerData", function(user, key, val, callback)
	if(Users[user]) then
		if(Users[user][key]) then

			if(key ~= "money") then
				Users[user][key] = val

				local sql = [[
				UPDATE
					`users`
				SET
					`@key` = '@value'
				WHERE
					`identifier` = '@identifier'
				]]

				mysql:exec(
					sql,
					{
						["@key"] = key,
						["@value"] = val,
						["@identifier"] = Users[user]["identifier"]
					}
				)

			end

			if(key == "group") then
				Users[user].group = groups[key]
			end

			callback("Player data edited.", true)
		else
			callback("Column does not exist!", false)
		end
	else
		callback("User could not be found!", false)
	end
end)

--[[
-- @param {string} user
-- @param {string} key
-- @param {string} val
-- @param {function} callback
-]]
AddEventHandler("es:setPlayerDataId", function(user, key, val, callback)

	local sql = [[
	UPDATE
		`users`
	SET
		`@key` = '@value'
	WHERE
		`identifier` = '@identifier'
	]]

	mysql:exec(
		sql,
		{
			["@key"] = key,
			["@value"] = val,
			["@identifier"] = user
		}
	)

	callback("Player data edited.", true)
end)

--[[
-- @param {string} user
-- @param {function} callback
-]]
AddEventHandler("es:getPlayerFromId", function(user, callback)
	if(Users) then
		if(Users[user]) then
			callback(Users[user])
		else
			callback(nil)
		end
	else
		callback(nil)
	end
end)

--[[
-- @param {string} identifier
-- @param {function} callback
-]]
AddEventHandler("es:getPlayerFromIdentifier", function(identifier, callback)

	local sql = [[
	SELECT
		`permission_level`,
		`money`,
		`identifier`,
		`group`
	FROM
		`users`
	WHERE
		`identifier` = '@name'
	]]

	local user = mysql:getOne(
		sql,
		{
			["@name"] = identifier
		},
		{
			"permission_level",
			"money",
			"identifier",
			"group"
		}
	)

	if(user) then
		callback(user)
	else
		callback(nil)
	end
end)

--[[
-- @param {function} callback
-]]
AddEventHandler("es:getAllPlayers", function(callback)

	local sql = [[
	SELECT
		`permission_level`,
		`money`,
		`identifier`,
		`group`
	FROM
		`users`
	]]

	local users = mysql:getMany(
		sql,
		{},
		{
			"permission_level",
			"money",
			"identifier",
			"group"
		}
	)

	if(users) then
		callback(users)
	else
		callback(nil)
	end
end)

--[[
-- Function to update player money every X seconds.
-- @param {int} seconds
]]
local function savePlayerMoney(seconds)
	SetTimeout(seconds * 1000, function()
		TriggerEvent("es:getPlayers", function(users)
			for key, user in pairs(users) do

				local sql = [[
				UPDATE
					`users`
				SET
					`money` = '@money'
				WHERE
					`identifier` = '@identifier'
				]]

				mysql:exec(
					sql,
					{
						["@money"] = user.money,
						["@identifier"] = user.identifier
					}
				)
			end
		end)

		savePlayerMoney(seconds)
	end)
end

savePlayerMoney(conf.settings.save_player_money_seconds)