--[[
-- @author smuttoN
-- @website www.github.com/sutt0n
-- @date 5/22/2017
--]]

conf = {}

------------------------[[
-- Server configuration []
------------------------]]

conf.settings = {
	["bans_verbiage"]               = "You are currently banned. Please go to: www.how-not-to-get-banned.edu",
	["pvp_enabled"]                 = false,
	["permission_denied"]           = false,
	["debug_mode"]                  = true,
	["starting_cash"]               = 0,
	["enable_rank_decorators"]      = false,
	["save_player_money_seconds"]   = 60        -- saves player money to the database every 60 seconds by default (obviously, this can be changed)
}

--------------------------[[
-- Database configuration []
--------------------------]]

conf.db = {
	["hostname"] = "localhost",
	["database"] = "essential",
	["username"] = "root",
	["password"] = "root"    -- ;)
}

-----------------------[[
-- System Configuration[]
-----------------------]]

-- yo, do me a huge favor and don't touch this; thanks!

conf.system = {
	["version"] = "0.0.1"
}