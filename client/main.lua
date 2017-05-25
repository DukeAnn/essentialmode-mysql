--[[
-- @author smuttoN
-- @website www.github.com/sutt0n
-- @date 5/22/2017
--]]

-- first join
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if NetworkIsSessionStarted() then
			TriggerServerEvent("es:firstJoinProper")
			return
		end
	end
end)

local oldPos

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1000)
		local pos = GetEntityCoords(GetPlayerPed(-1))

		if(oldPos ~= pos) then
			TriggerServerEvent("es:updatePositions", pos.x, pos.y, pos.z)

			-- init
			SendNUIMessage({
				setmoney = true,
				money = 0
			})

			oldPos = pos
		end
	end
end)

local decorators = {}

--[[
-- @param {string} key
-- @param {string} val
-- @param {bool} now
-]]
RegisterNetEvent("es:setPlayerDecorator")
AddEventHandler("es:setPlayerDecorator", function(key, val, now)
	decorators[key] = value
	DecorRegister(key, 3)

	if(now) then
		DecorSetInt(GetPlayerPed(-1), key, val)
	end
end)

AddEventHandler("playerSpawned", function()
	for key, val in pairs(decorators) do
		DecorSetInt(GetPlayerPed(-1), key, val)
	end
end)

--[[
-- @param {int} _money
-- @param {Player} player
-]]
RegisterNetEvent("es:activateMoney")
AddEventHandler("es:activateMoney", function(_money)
	SendNUIMessage({
		setmoney = true,
		money = _money
	})
end)

--[[
-- @param {int} _money
-]]
RegisterNetEvent("es:addedMoney")
AddEventHandler("es:addedMoney", function(_money)
	SendNUIMessage({
		addmoney = true,
		money = _money
	})
end)

--[[
-- @param {int} _money
-]]
RegisterNetEvent("es:removedMoney")
AddEventHandler("es:removedMoney", function(_money)
	SendNUIMessage({
		removemoney = true,
		money = _money
	})
end)

RegisterNetEvent("es:setMoneyDisplay")
--[[
-- @param {string} _display
-]]
AddEventHandler("es:setMoneyDisplay", function(_display)
	SendNUIMessage({
		setDisplay = true,
		display = _display
	})
end)

RegisterNetEvent("es:enablePvp")
AddEventHandler("es:enablePvp", function()
	Citizen.CreateThread(function()
		while true do
			Citizen.Wait(0)
			for i = 0,32 do
				if NetworkIsPlayerConnected(i) then
					if NetworkIsPlayerConnected(i) and GetPlayerPed(i) ~= nil then
						SetCanAttackFriendly(GetPlayerPed(i), true, true)
						NetworkSetFriendlyFireOption(true)
					end
				end
			end
		end
	end)
end)