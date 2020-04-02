ESX          = nil
cachedData = {
	["rentedVoi"] = false
}

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

Citizen.CreateThread(function()

	Citizen.Wait(50)

	while true do
		
		local sleepThread = 500
		local ped = PlayerPedId()
		local pedCoords = GetEntityCoords(ped)

		for _, coords in ipairs(Config.Locations) do

			local dstCheck = #(pedCoords - coords)

			if dstCheck < 15.0 then

				sleepThread = 5

				if dstCheck < 5.0 then

					if IsControlJustReleased(0, 38) then
							if cachedData["rentedVoi"] then
						else
							VoiMeny()
					end
				end
					ESX.ShowHelpNotification("~INPUT_CONTEXT~ Hyr en Voi")
				end
				DrawMarker(6, coords - vector3(0.0, 0.0, 0.98), 0, 0, 0.1, 0, 0, 0, 1.0, 1.0, 1.0, 0, 205, 150, 200, 0, 0, 0, 0)
			end
		end
		Citizen.Wait(sleepThread)
	end
end)

Citizen.CreateThread(function()
	while true do
	Citizen.Wait(10)
	
		if IsControlJustPressed(0, 311) then
			if cachedData["rentedVoi"] then
				ESX.Game.DeleteVehicle(cachedData["voiModel"])
				cachedData["rentedVoi"] = false
				TriggerServerEvent("arp_voi:pengar", Config.PPM * cachedData["cost"])
			end
		end
	end
end)


function VoiMeny()
	
	local elements = {}
	
	if table.insert(elements, {label = ('Voi'), value = 'voi'}) then
end
	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'client',
		{
			title    = ('Hyrning av Voi'),
			align    = 'center',
			elements = elements,
		},
	function(data, menu)
		if data.current.value == 'voi' then
			sendNotification('Du hyrde en Voi', 'error', 4000)
			rentVoi()
			end
		ESX.UI.Menu.CloseAll()
	end,
	function(data, menu)
		menu.close()
	end)
end

rentVoi = function()
	RequestModel(Config.VoiModel)
	while not HasModelLoaded(Config.VoiModel) do
		Wait(0)
	end
	cachedData["voiModel"] = CreateVehicle(Config.VoiModel, GetEntityCoords(PlayerPedId()), GetEntityHeading(PlayerPedId()), true)
	TaskWarpPedIntoVehicle(PlayerPedId(), cachedData["voiModel"], -1)
	cachedData["rentedVoi"] = true
	cachedData["timeRented"] = 0
	cachedData["cost"] = 0
	Citizen.CreateThread(function()
		
		local lastAdded = GetGameTimer()
		
		while cachedData["rentedVoi"] do

			local sleepThread = 500
			local ped = PlayerPedId()
			local pedCoords = GetEntityCoords(ped)
			
			if IsPedInVehicle or IsPedOnFoot(ped, cachedData["voiModel"]) then
				
				sleepThread = 5
				
				if (cachedData["voiModel"]) > 0.0 then


					if GetGameTimer() - lastAdded > 30000 then

						cachedData["timeRented"] = cachedData["timeRented"] + 0.5
						cachedData["cost"] = cachedData["cost"] + 1.0
						lastAdded = GetGameTimer()

					end
				end
				drawTxt(1.37, 0.73, 1.0, 1.0, 0.5, "Tid:~r~ " ..cachedData["timeRented"].."~s~ minuter", 255, 255, 255, 255)
				drawTxt(1.37, 0.78, 1.0, 1.0, 0.5, "Kostnad: ~g~" ..cachedData["cost"]*Config.PPM.. "~s~ SEK", 255, 255, 255, 255) 
				drawTxt(1.37, 0.83, 1.0, 1.0, 0.5, "[~g~K~s~] Avsluta körning", 255, 255, 255, 255)
			end
			Citizen.Wait(sleepThread)
		end
	end)
end


drawTxt = function(x,y ,width,height,scale, text, r,g,b,a, outline)
    SetTextFont(4)
    SetTextProportional(0)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    if(outline)then
	    SetTextOutline()
	end
    SetTextEntry("STRING")
    AddTextComponentString(text)
	DrawText(x - width/2, y - height/2 + 0.005)
	DrawRect(0.920, 0.300, 0.13, 0.15, 41, 41, 41, 250)
end

function sendNotification(message, messageType, messageTimeout)
	TriggerEvent("pNotify:SendNotification", {
		text = message,
		type = messageType,
		queue = "kok",
		timeout = messageTimeout,
		layout = "centerRight"
	})
end

Citizen.CreateThread(function()
	if Config.EnableBlips then
		for k, v in ipairs(Config.Locations) do
			local blip = AddBlipForCoord(v.x, v.y, v.z)

			SetBlipSprite(blip, 494)
			SetBlipScale(blip, 0.8)
			SetBlipColour(blip, 4)
			SetBlipDisplay(blip, 4)
			SetBlipAsShortRange(blip, true)

			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString("Hyr Voi")
			EndTextCommandSetBlipName(blip)
		end
	end
end)
