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

				if dstCheck < 3.0 then

					if IsControlJustReleased(0, 38) then

						if cachedData["rentedVoi"] then
							TriggerEvent('esx:deleteVehicle')
							cachedData["rentedVoi"] = false
							TriggerServerEvent("arp_voi:pengar", Config.PPM * cachedData["timeRented"])
						else
							VoiMeny()
						end
						
					end
					ESX.ShowHelpNotification(cachedData["rentedVoi"] and "~INPUT_CONTEXT~ Ställ tillbaka din voi" or "~INPUT_CONTEXT~ Hyr en Voi")
				end
				DrawMarker(6, coords - vector3(0.0, 0.0, 0.98), 0, 0, 0.1, 0, 0, 0, 1.0, 1.0, 1.0, 0, 205, 150, 200, 0, 0, 0, 0)
			end
		end
		Citizen.Wait(sleepThread)
	end
end)


function VoiMeny()
	
	local elements = {}
	
	if not Config.EnablePrice then
		table.insert(elements, {label = ('Voi'), value = 'voi'}) 
	else
		table.insert(elements, {label = ('Voi - 50kr'), value = 'voi'})
	end
	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'client',
		{
			title    = ('Hyrning av Voi'),
			align    = 'top-right',
			elements = elements,
		},
	function(data, menu)
		if data.current.value == 'voi' then
			if Config.EnablePrice then
				TriggerServerEvent("arp_voi:pengar", Config.Price) 
				TriggerEvent('notification', 'Du hyrde en Voi för ' .. Config.Price .. 'kr', 3)
				rentVoi()
			else TriggerEvent('notification', 'Du hyrde en Voi', 3)
				rentVoi()
			end
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
	Citizen.CreateThread(function()
		
		local lastAdded = GetGameTimer()
		
		while cachedData["rentedVoi"] do

			local sleepThread = 500
			local ped = PlayerPedId()
			local pedCoords = GetEntityCoords(ped)
			
			if IsPedInVehicle(ped, cachedData["voiModel"]) then
				
				sleepThread = 5
				
				if GetEntitySpeed(cachedData["voiModel"]) > 0.0 then


					if GetGameTimer() - lastAdded > 60000 then

						cachedData["timeRented"] = cachedData["timeRented"] + 1
						lastAdded = GetGameTimer()

					end
				end
				drawTxt(0.88, 0.6, 1.0, 1.0, 0.5, "Tid:~r~ " ..cachedData["timeRented"].."~s~ minuter | " .."Kostnad: ~g~" ..cachedData["timeRented"]*Config.PPM.. "~s~ SEK", 255, 255, 255, 255)
			end
			Citizen.Wait(sleepThread)
		end
	end)
end


drawTxt = function(x,y ,width,height,scale, text, r,g,b,a, outline)
    SetTextFont(0)
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
end