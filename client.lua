local QBCore = exports['qb-core']:GetCoreObject()
NOOBKING = {}

local nui = false
local block = false
local vehicle
local myveh = {}
local cam = nil
local gameplaycam = nil
local damage = 0
local cart = {["total"] = 0}
local prices = config.prices


local colors = {
	["cromado"] = {120},
	["metálico"] = {
		0, 147, 1, 11, 2, 3, 4, 5, 6, 7, 8, 9, 10, 27, 28, 29, 150, 30, 31, 32, 33, 34, 
		143, 35, 135, 137, 136, 36, 38, 138, 99, 90, 88, 89, 91, 49, 50, 51, 52, 53, 54, 
		92, 141, 61, 62, 63, 64, 65, 66, 67, 68, 69, 73, 70, 74, 96, 101, 95, 94, 97,
		103, 104, 98, 100, 102, 99, 105, 106, 71, 72, 142, 145, 107, 111, 112
	},
	["fosco"] = {12,13,14,131,83,82,84,149,148,39,40,41,42,55,128,151,155,152,153,154},
	["metal"] = { 117,118,119,158,159 }
}

local mod = {
	["aerofólio"] = 0,
	["parachoque-dianteiro"] = 1,
	["parachoque-traseiro"] = 2,
	["saias"] = 3,
	["escapamento"] = 4,
	["roll-cage"] = 5,
	["grelha"] = 6,
	["capô"] = 7,
	["para-lama"] = 8,
	["teto"] = 10,
	["motor"] = 11,
	["freios"] = 12,
	["transmissão"] = 13,
	["buzina"] = 14,
	["suspensão"] = 15,
	["blindagem"] = 16,
	["turbo"] = 18,
	["smoke"] = 20,
	["farol"] = 22,
	["dianteira"] = 23,
	["traseira"] = 24,
	["ornaments"] = 28,
	["dashboard"] = 29,
	["dials"] = 30,
	["doors"] = 31,
	["seats"] = 32,
	["plaques"] = 35,
	["arch-cover"] = 42,
	["janela"] = 46,
	["decal"] = 48,
}

local wheeltype = {
	["stock"] = -1,
	["sport"] = 0,
	["muscle"] = 1,
	["lowrider"] = 2,
	["suv"] = 3,
	["offroad"] = 4,
	["tuner"] = 5,
	["highend"] = 7,
}

local QBCore = exports['qb-core']:GetCoreObject()
local nui = false
local block = false
local vehicle
local myveh = {}
local cam = nil
local gameplaycam = nil
local damage = 0
local cart = {["total"] = 0}
local prices = config.prices

Citizen.CreateThread(function()
	local bennys = false
	SetNuiFocus(false, false)
	while true do 
		local idle = 500
		if not bennys then
			bennys = getNearestBennys()
		elseif not nui then
			idle = 5
			DrawMarker(36, bennys[1], bennys[2], bennys[3] - 0.27, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 1.0, 255, 102, 0, 200, 0, 0, 0, 1)
			local playercoords = GetEntityCoords(PlayerPedId())
			local distance = #(playercoords - bennys)
			if distance < 2 then
				drawTxt("Press [E] Para abrir o menu mecânico", 4, 0.5, 0.93, 0.50, 255, 255, 255, 180)
				if IsControlJustPressed(0, 38) then
					QBCore.Functions.TriggerCallback('nation:checkPermission', function(data)
						if data and config.mechaniconly then
							vehicle = getNearestVehicle(7)
							while vehicle == nil do
								vehicle = getNearestVehicle(7)
								Citizen.Wait(100)
							end
							QBCore.Functions.TriggerCallback('nation:checkVehicle', function(data)
								if vehicle ~= nil and data then
									damage = (1000 - GetVehicleBodyHealth(vehicle)) / 100
									if config.no_repair then
										damage = 0
									end
									SetVehicleModKit(vehicle, 0)
									FreezeEntityPosition(vehicle, true)
									myveh = getAllVehicleMods(vehicle)
									gameplaycam = GetRenderingCam()
									cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true, 2)
									SendNUIMessage({ action = "vehicle", vehicle = getVehicleMods(vehicle), damage = damage, logo = config.logo })
									showNui()
									isVehicleTooFar(vehicle)
								end
							end, VehToNet(vehicle))
						elseif not config.mechaniconly then
							vehicle = getNearestVehicle(7)
							while vehicle == nil do
								vehicle = getNearestVehicle(7)
								Citizen.Wait(100)
							end
							QBCore.Functions.TriggerCallback('nation:checkVehicle', function(data)
								if vehicle ~= nil and data then
									damage = (1000 - GetVehicleBodyHealth(vehicle)) / 100
									if config.no_repair then
										damage = 0
									end
									SetVehicleModKit(vehicle, 0)
									FreezeEntityPosition(vehicle, true)
									myveh = getAllVehicleMods(vehicle)
									gameplaycam = GetRenderingCam()
									cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true, 2)
									SendNUIMessage({ action = "vehicle", vehicle = getVehicleMods(vehicle), damage = damage, logo = config.logo })
									showNui()
									isVehicleTooFar(vehicle)
								end
							end, VehToNet(vehicle))
						end
					end)
				end
			end
			if distance > 10 then
				bennys = false
			end
		end
		Citizen.Wait(idle)
	end
end)

-- Animações

function playAnim(animDict, name)
	RequestAnimDict(animDict)
	while not HasAnimDictLoaded(animDict) do 
		Wait(1)
		RequestAnimDict(animDict)
	end
	TaskPlayAnim(PlayerPedId(), animDict, name, 2.0, 2.0, -1, 47, 0, 0, 0, 0)
end

function stopAnim()
	ClearPedTasks(PlayerPedId())
end

function parseInt(v)
	if v == nil then
		v = 0
	end
	return tonumber(v)
end

-- Eventos

RegisterNetEvent("progress")
AddEventHandler("progress", function(a, b)
	--exports['progressBars']:startUI(a, b)
	lib.progressBar({
		duration = 10 * 1000,
		label = b,
		useWhileDead = false,
		canCancel = false, -- # if you dont want that player can cancel progress then change to false 
		disable = {
			car = true,
			move = true,
			combat = true,
			mouse = false
		},
	})
end)

RegisterNetEvent("Notify")
AddEventHandler("Notify", function(a, b)
	QBCore.Functions.Notify(a, 'normal', b)
	print(a)
	print(b)
end)

RegisterNUICallback("close", function(data)
	SetVehicleLights(vehicle, 0)
	if IsHornActive(vehicle) then
		StartVehicleHorn(vehicle, 0, "NORMAL", false)
	end
	NOOBKING.closeNui()
end)


RegisterNUICallback("voltar", function(data)
    if IsHornActive(vehicle) then
        StartVehicleHorn(vehicle, 0, "NORMAL", false)
    end
end)

RegisterNUICallback("cam", function(data)
    if data and data.cam then
        if data.cam == "freecam" then
            freeCam()
        else
            camControl(data.cam)
        end
    end
end)

RegisterNUICallback("pagar", function(data)
    QBCore.Functions.TriggerCallback('nation:checkPayment', function(paymentData)
        if cart["total"] and paymentData then
            SetNuiFocus(false, false)
            SendNUIMessage({ action = "applying" })
            if not IsPedInAnyVehicle(PlayerPedId()) then
                playAnim("mini@repair", "fixing_a_player")
            end
            TriggerEvent("progress", 10000, "Installing")
            Wait(10000)
            stopAnim()
            myveh = QBCore.Functions.GetVehicleProperties(vehicle)
            local vehname = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)):lower()
            local vehplate = myveh.plate
            TriggerServerEvent("saveVehicle", vehplate, myveh)
            NOOBKING.closeNui()
        end
    end, cart["total"])
end)

RegisterNUICallback("callbacks", function(data)
    if data then
        if data.type == "reparar" then
            if block then
                return
            end
            block = true
            SetVehicleDoorOpen(vehicle, 4, 0, 0)
            if not IsPedInAnyVehicle(PlayerPedId()) then
                playAnim("mini@repair", "fixing_a_player")
            end
            TriggerEvent("progress", 10000, "Repairing")
            Wait(10000)
            SetVehicleFixed(vehicle)
            SetVehicleDirtLevel(vehicle, 0.0)
            SetVehicleUndriveable(vehicle, false)
            SetEntityAsMissionEntity(vehicle, true, true)
            SetVehicleOnGroundProperly(vehicle)
            myveh.damage = 0.0
            stopAnim()
            TriggerEvent("Notify", "sucesso", "Veículo reparado com <b>sucesso</b>.", 7000)
            SendNUIMessage({ action = "repair" })
            block = false
        elseif data.type == "cor-primaria" or data.type == "cor-secundaria" then
            local color = split(data.color, ",")
            vehicleCustomColor(data.type, vehicle, color)
        elseif string.find(data.type, "turbo") then
            local turbo = parseInt(split(data.type, "-")[2])
            if turbo > 0 then
                ToggleVehicleMod(vehicle, mod["turbo"], true)
            else
                ToggleVehicleMod(vehicle, mod["turbo"], false)
            end
            updateCart(myveh, mod["turbo"], turbo)
        elseif string.find(data.type, "motor") or string.find(data.type, "freios") or string.find(data.type, "transmissão") or string.find(data.type, "suspensão") then
            local type = split(data.type, "-")[1]
            local level = parseInt(split(data.type, "-")[2]) - 1
            SetVehicleMod(vehicle, mod[type], level)
            updateCart(myveh, mod[type], level)
        elseif string.find(data.type, "neon") then
            local type = split(data.type, "-")[2]
            if type == "kit" then
                setNeon(vehicle, true)
                updateCart(myveh, "neon", 1)
            elseif type == "default" then
                setNeon(vehicle, false)
                updateCart(myveh, "neon", 0)
            elseif type == "colors" then
                local color = split(data.color, ",")
                neonColor(vehicle, color)
            end
            SetVehicleLights(vehicle, 2)
        elseif string.find(data.type, "farol") then
            SetVehicleLights(vehicle, 2)
            local type = split(data.type, "-")[2]
            if type then
                if type == "xenon" then
                    setXenon(vehicle, true)
                    updateCart(myveh, mod["farol"], 1)
                else
                    setXenon(vehicle, false)
                    updateCart(myveh, mod["farol"], 0)
                end
            end
        elseif string.find(data.type, "xenon") then
            local colorindex = parseInt(split(data.type, "-")[3])
            SetVehicleXenonLightsColour(vehicle, colorindex)
        elseif string.find(data.type, "pneus") then
            local type = split(data.type, "-")[1]
            local modindex = GetVehicleMod(vehicle, mod["dianteira"])
            if type == "fabrica" then
                SetVehicleMod(vehicle, mod["dianteira"], modindex, false)
                SetVehicleTyresCanBurst(vehicle, true)
                updateCart(myveh, "fabrica", 0)
            elseif type == "custom" then
                SetVehicleMod(vehicle, mod["dianteira"], modindex, true)
                updateCart(myveh, "custom", 1)
            elseif type == "bulletproof" then
                SetVehicleTyresCanBurst(vehicle, false)
                updateCart(myveh, "bulletproof", 1)
            end
        elseif string.find(data.type, "smoke") then
            local color = split(data.color, ",")
            smokeColor(vehicle, color)
        elseif string.find(data.type, "primaria") or string.find(data.type, "secundaria") then
            local type = split(data.type, "-")[2]
            local color = split(data.type, "-")[3]
            local colorindex = split(data.type, "-")[4]
            if colors[color] then
                if #colors[color] > 1 and colorindex then
                    colorindex = parseInt(colorindex)
                    vehicleColor(type, vehicle, colors[color][colorindex], color)
                else
                    vehicleColor(type, vehicle, colors[color][1], color)
                end
            end
        elseif string.find(data.type, "blindagem") then
            local blindagem = data.blindagem
            if blindagem then
                SetVehicleMod(vehicle, mod["blindagem"], blindagem)
            end
            updateCart(myveh, mod["blindagem"], blindagem)
        elseif string.find(data.type, "placa") then
            local type = parseInt(split(data.type, "-")[2])
            SetVehicleNumberPlateTextIndex(vehicle, type)
            updateCart(myveh, "placa", type)
        elseif string.find(data.type, "vidro") then
            local tint = parseInt(split(data.type, "-")[2])
            SetVehicleWindowTint(vehicle, tint)
            updateCart(myveh, "vidro", tint)
        elseif string.find(data.type, "perolado") then
            local colorindex = split(data.type, "-")[3]
            if colorindex then
                vehiclePerolado(vehicle, parseInt(colorindex))
                updateCart(myveh, "perolado", colorindex)
            end
        elseif string.find(data.type, "wheelcolor") then
            local colorindex = split(data.type, "-")[2]
            if colorindex then
                vehicleWheelColor(vehicle, parseInt(colorindex))
                updateCart(myveh, "wheelcolor", colorindex)
            end
        elseif wheeltype[data.type] or wheeltype[split(data.type, "-")[1]] then
            local type = wheeltype[data.type]
            local index = -1
            if not type then
                type = wheeltype[split(data.type, "-")[1]]
                index = parseInt(split(data.type, "-")[2]) - 1
            end
            SetVehicleWheelType(vehicle, type)
            SetVehicleMod(vehicle, mod["dianteira"], index, false)
            updateCart(myveh, mod["dianteira"], index)
        elseif mod[split(data.type, "-")[1]] or mod[tostring(split(data.type, "-")[1] .. "-" .. split(data.type, "-")[2])] then
            local modType = mod[split(data.type, "-")[1]]
            local index = string.match(data.type, "%d+") - 1
            if split(data.type, "-")[3] then
                modType = mod[split(data.type, "-")[1] .. "-" .. split(data.type, "-")[2]]
                index = string.match(data.type, "%d+") - 1
            end
            count = 0
            index = math.ceil(index)
            while true and count < 22 do
                count = count + 1
                Citizen.Wait(11)
            end
            SetVehicleMod(vehicle, modType, index, false)
            if modType == mod["buzina"] then
                StartVehicleHorn(vehicle, 5000, "HELDDOWN", true)
            end
            updateCart(myveh, modType, index)
        end
    end
end)


function updateCart(myveh, modtype, index, colortype)
    if not myveh or not modtype or index == nil then
        return
    end

    local function adjustCartPrice(modType, modIndex)
        local price = prices[modType].startprice
        local increase = prices[modType].increaseby or 0
        if modIndex ~= nil then
            price = price + (increase * modIndex)
        end
        return price
    end

    if modtype == mod["turbo"] or modtype == mod["farol"] then
        if not cart[tostring(modtype)] then
            if myveh.mods[modtype].mod < 1 and index > 0 then
                cart[tostring(modtype)] = 1
                cart["total"] = cart["total"] + adjustCartPrice(modtype)
            end
        elseif cart[tostring(modtype)] > 0 and index < 1 then
            cart["total"] = cart["total"] - adjustCartPrice(modtype)
            cart[tostring(modtype)] = nil
        end
    elseif modtype == "neon" then
        if not cart[modtype] then
            if not myveh.neon and index > 0 then
                cart[modtype] = 1
                cart["total"] = cart["total"] + adjustCartPrice(modtype)
            end
        elseif cart[modtype] > 0 and index < 1 then
            cart["total"] = cart["total"] - adjustCartPrice(modtype)
            cart[modtype] = nil
        end
    elseif modtype == "bulletproof" or modtype == "custom" or modtype == "fabrica" then
        if modtype == "fabrica" then
            if cart["bulletproof"] then
                cart["total"] = cart["total"] - adjustCartPrice("bulletproof")
                cart["bulletproof"] = nil
            end
            if cart["custom"] then
                cart["total"] = cart["total"] - adjustCartPrice("custom")
                cart["custom"] = nil
            end
            SendNUIMessage({ action = "price", price = cart["total"] })
            return
        end

        local type = not myveh.bulletProofTyres
        if modtype == "custom" then
            type = myveh.mods[mod["dianteira"]].variation
        end

        if not cart[modtype] then
            if not type and index > 0 then
                cart[modtype] = 1
                cart["total"] = cart["total"] + adjustCartPrice(modtype)
            end
        elseif cart[modtype] > 0 and index < 1 then
            cart["total"] = cart["total"] - adjustCartPrice(modtype)
            cart[modtype] = nil
        end
    elseif modtype == "wheelcolor" or modtype == "perolado" then
        index = tonumber(index)
        local type = myveh.extracolor[1]
        if modtype == "wheelcolor" then
            type = myveh.extracolor[2]
        end

        if not cart[modtype] and type ~= index and index > 0 then
            cart[modtype] = index
            cart["total"] = cart["total"] + adjustCartPrice(modtype)
        elseif type ~= index and index > 0 then
            cart[modtype] = index
        elseif (index < 1 or type == index) and cart[modtype] then
            cart["total"] = cart["total"] - adjustCartPrice(modtype)
            cart[modtype] = nil
        end
    elseif modtype == "primaria" or modtype == "secundaria" then
        local type = myveh.color[1]
        local vehcolortype = myveh.pcolortype
        local cartcolortype = cart["pcolortype"]
        if modtype == "secundaria" then
            type = myveh.color[2]
            vehcolortype = myveh.scolortype
            cartcolortype = cart["scolortype"]
        end

        if colortype and config.prices["colortypes"][colortype] then
            if not cartcolortype and colortype ~= vehcolortype then
                local price = config.prices["colortypes"][colortype]
                cartcolortype = colortype
                cart["total"] = cart["total"] + price
            elseif colortype == vehcolortype and config.prices["colortypes"][cartcolortype] then
                local price = config.prices["colortypes"][cartcolortype]
                cart["total"] = cart["total"] - price
                cartcolortype = nil
            elseif config.prices["colortypes"][cartcolortype] then
                local price = config.prices["colortypes"][cartcolortype]
                cart["total"] = cart["total"] - price
                cartcolortype = colortype
                price = config.prices["colortypes"][colortype]
                cart["total"] = cart["total"] + price
            end

            if modtype == "primaria" then
                cart["pcolortype"] = cartcolortype
            else
                cart["scolortype"] = cartcolortype
            end
        end

        if not cart[modtype] and type and index and type ~= index and index > 0 then
            cart[modtype] = index
            cart["total"] = cart["total"] + adjustCartPrice(modtype)
        elseif type and index and type ~= index and index > 0 then
            cart[modtype] = index
        elseif (index < 1 or type == index) and cart[modtype] then
            cart["total"] = cart["total"] - adjustCartPrice(modtype)
            cart[modtype] = nil
        end
    elseif modtype == "cor-primaria" or modtype == "cor-secundaria" then
        local type = myveh.customPcolor
        if modtype == "cor-secundaria" then
            type = myveh.customScolor
        end

        if not cart[modtype] and not sameColor(index, type) then
            cart[modtype] = index
            cart["total"] = cart["total"] + adjustCartPrice(modtype)
        elseif sameColor(index, type) then
            cart["total"] = cart["total"] - adjustCartPrice(modtype)
            cart[modtype] = nil
        end
    elseif modtype == "vidro" then
        if not cart[modtype] and myveh.windowtint ~= index and index > 0 then
            cart[modtype] = index
            cart["total"] = cart["total"] + (prices[modtype].startprice + prices[modtype].increaseby * (index - 1))
        elseif myveh.windowtint ~= index and index > 0 then
            cart["total"] = cart["total"] - (prices[modtype].startprice + prices[modtype].increaseby * (cart[modtype] - 1))
            cart[modtype] = index
            cart["total"] = cart["total"] + (prices[modtype].startprice + prices[modtype].increaseby * (index - 1))
        elseif (index < 1 or myveh.windowtint == index) and cart[modtype] then
            cart["total"] = cart["total"] - (prices[modtype].startprice + prices[modtype].increaseby * (cart[modtype] - 1))
            cart[modtype] = nil
        end
    elseif modtype == "placa" then
        if not cart[modtype] and myveh.plateindex ~= index and index > 0 then
            cart[modtype] = index
            cart["total"] = cart["total"] + (prices[modtype].startprice + prices[modtype].increaseby * (index - 1))
        elseif myveh.plateindex ~= index and index > 0 then
            cart["total"] = cart["total"] - (prices[modtype].startprice + prices[modtype].increaseby * (cart[modtype] - 1))
            cart[modtype] = index
            cart["total"] = cart["total"] + (prices[modtype].startprice + prices[modtype].increaseby * (index - 1))
        elseif (index < 1 or myveh.plateindex == index) and cart[modtype] then
            cart["total"] = cart["total"] - (prices[modtype].startprice + prices[modtype].increaseby * (cart[modtype] - 1))
            cart[modtype] = nil
        end
    elseif not cart[tostring(modtype)] and myveh.mods[modtype].mod ~= index and index > -1 then
        cart[tostring(modtype)] = index
        cart["total"] = cart["total"] + (prices[modtype].startprice + prices[modtype].increaseby * index)
    elseif myveh.mods[modtype].mod ~= index and index > -1 then
        cart["total"] = cart["total"] - (prices[modtype].startprice + prices[modtype].increaseby * cart[tostring(modtype)])
        cart[tostring(modtype)] = index
        cart["total"] = cart["total"] + (prices[modtype].startprice + prices[modtype].increaseby * index)
    elseif (index < 0 or myveh.mods[modtype].mod == index) and cart[tostring(modtype)] then
        cart["total"] = cart["total"] - (prices[modtype].startprice + prices[modtype].increaseby * cart[tostring(modtype)])
        cart[tostring(modtype)] = nil
    end

    SendNUIMessage({ action = "price", price = cart["total"] })
end

-- Função auxiliar para garantir que o número não seja negativo
function p(nro)
    if nro < 0 then
        return 0
    end
    return nro
end

-- Obtém todas as modificações do veículo
function getAllVehicleMods(veh)
    local myveh = {}
    myveh.vehicle = veh
    myveh.model = GetDisplayNameFromVehicleModel(GetEntityModel(veh)):lower()
    myveh.color = table.pack(GetVehicleColours(veh))
    myveh.customPcolor = table.pack(GetVehicleCustomPrimaryColour(veh))
    myveh.customScolor = table.pack(GetVehicleCustomSecondaryColour(veh))
    myveh.extracolor = table.pack(GetVehicleExtraColours(veh))
    myveh.neon = hasNeonKit(veh)
    myveh.neoncolor = table.pack(GetVehicleNeonLightsColour(veh))
    myveh.xenoncolor = GetVehicleHeadlightsColour(veh)
    myveh.smokecolor = table.pack(GetVehicleTyreSmokeColor(veh))
    myveh.plateindex = GetVehicleNumberPlateTextIndex(veh)
    myveh.pcolortype = getColorType(myveh.color[1])
    myveh.scolortype = getColorType(myveh.color[2])
    myveh.mods = {}

    for i = 0, 48 do
        myveh.mods[i] = { mod = nil }
    end

    for i, t in pairs(myveh.mods) do
        if i == 22 or i == 18 then
            t.mod = IsToggleModOn(veh, i) and 1 or 0
        elseif i == 23 or i == 24 then
            t.mod = GetVehicleMod(veh, i)
            t.variation = GetVehicleModVariation(veh, i)
        else
            t.mod = GetVehicleMod(veh, i)
        end
    end

    myveh.windowtint = (GetVehicleWindowTint(veh) == -1 or GetVehicleWindowTint(veh) == 0) and false or GetVehicleWindowTint(veh)
    myveh.xenoncolor = (myveh.xenoncolor > 12 or myveh.xenoncolor < -1) and -1 or myveh.xenoncolor
    myveh.wheeltype = GetVehicleWheelType(veh)
    myveh.bulletProofTyres = GetVehicleTyresCanBurst(veh)
    myveh.damage = (1000 - GetVehicleBodyHealth(veh)) / 100

    return myveh
end

-- Configura as modificações no veículo com base nas informações fornecidas
function setVehicleMods(veh, myveh, tunnerChip)
    SetVehicleModKit(veh, 0)

    if not myveh or not myveh.customPcolor then
        return
    end

    local primary = myveh.color[1]
    local secondary = myveh.color[2]
    local cprimary = myveh.customPcolor
    local csecondary = myveh.customScolor
    local perolado = myveh.extracolor[1]
    local wheelcolor = myveh.extracolor[2]
    local neoncolor = myveh.neoncolor
    local smokecolor = myveh.smokecolor

    ClearVehicleCustomPrimaryColour(veh)
    ClearVehicleCustomSecondaryColour(veh)
    SetVehicleWheelType(veh, myveh.wheeltype)
    SetVehicleColours(veh, primary, secondary)

    if cprimary['1'] then
        SetVehicleCustomPrimaryColour(veh, cprimary['1'], cprimary['2'], cprimary['3'])
        SetVehicleCustomSecondaryColour(veh, csecondary['1'], csecondary['2'], csecondary['3'])
    else
        SetVehicleCustomPrimaryColour(veh, cprimary[1], cprimary[2], cprimary[3])
        SetVehicleCustomSecondaryColour(veh, csecondary[1], csecondary[2], csecondary[3])
    end

    SetVehicleExtraColours(veh, perolado, wheelcolor)
    SetVehicleNeonLightsColour(veh, neoncolor[1], neoncolor[2], neoncolor[3])
    SetVehicleXenonLightsColour(veh, myveh.xenoncolor)
    SetVehicleNumberPlateTextIndex(veh, myveh.plateindex)
    SetVehicleWindowTint(veh, myveh.windowtint)

    for i, t in pairs(myveh.mods) do
        if tonumber(i) == 22 or tonumber(i) == 18 then
            ToggleVehicleMod(veh, tonumber(i), t.mod > 0)
        elseif tonumber(i) == 20 then
            smokeColor(veh, smokecolor)
        elseif tonumber(i) == 23 or tonumber(i) == 24 then
            SetVehicleMod(veh, tonumber(i), tonumber(t.mod), tonumber(t.variation))
        else
            SetVehicleMod(veh, tonumber(i), tonumber(t.mod))
        end
    end

    SetVehicleTyresCanBurst(veh, myveh.bulletProofTyres)
    
    for i = 0, 3 do
        SetVehicleNeonLightEnabled(veh, i, myveh.neon)
    end

    if myveh.damage > 0 then
        SetVehicleBodyHealth(veh, myveh.damage)
    end
end


-- Obtém as modificações do veículo
	function getVehicleMods(veh)
		local rodaatual = GetVehicleMod(veh, mod["dianteira"])
		local mods = {
			["cor-primaria"] = rgbToHex({GetVehicleCustomPrimaryColour(veh)}),
			["cor-secundaria"] = rgbToHex({GetVehicleCustomSecondaryColour(veh)}),
			["neon"] = IsVehicleNeonLightEnabled(veh, 2),
			["neon-colors"] = rgbToHex({GetVehicleNeonLightsColour(veh)}),
			["smoke-colors"] = rgbToHex({GetVehicleTyreSmokeColor(veh)}),
			["custom-pneus"] = GetVehicleModVariation(veh, mod["dianteira"]),
			["bulletproof-pneus"] = GetVehicleTyresCanBurst(veh),
			["farol"] = IsToggleModOn(veh, mod["farol"]),
			["turbo"] = IsToggleModOn(veh, mod["turbo"]),
			["placa"] = {6, GetVehicleNumberPlateTextIndex(veh) - 1},
			["vidro"] = {7, GetVehicleWindowTint(veh) - 1},
			["bike"] = IsThisModelABike(GetEntityModel(veh)),
		}
	
		for k in pairs(wheeltype) do
			mods[k] = {isWheelType(k)}
		end
	
		SetVehicleMod(veh, mod["dianteira"], rodaatual)
	
		for k, v in pairs(mod) do
			if mods[k] == nil then
				mods[k] = {GetNumVehicleMods(veh, v) + 1, GetVehicleMod(veh, v)}
			end
		end
	
		return mods
	end
	
	-- Verifica se o veículo tem kit de neon
	function hasNeonKit(veh)
		for i = 0, 3 do 
			if not IsVehicleNeonLightEnabled(veh, i) then 
				return false 
			end 
		end 
		return true
	end
	
	-- Ativa ou desativa as luzes de neon no veículo
	function setNeon(veh, toggle)
		for i = 0, 3 do
			SetVehicleNeonLightEnabled(veh, i, toggle)
		end
	end
	
	-- Ativa ou desativa o mod de farol do veículo
	function setXenon(veh, toggle)
		ToggleVehicleMod(veh, mod["farol"], toggle)
	end
	
	-- Verifica se o tipo de roda é igual ao especificado
	function isWheelType(type)
		local wheelType = wheeltype[type]
		local currentWheelType = GetVehicleWheelType(vehicle)
		local bool = (currentWheelType == wheelType)
		local wheel = 0
		local num = 0
	
		if bool then
			wheel = rodaatual
		end
	
		SetVehicleWheelType(vehicle, wheelType)
		num = GetNumVehicleMods(vehicle, mod["dianteira"])
		SetVehicleWheelType(vehicle, currentWheelType)
	
		return bool, wheel, num
	end
	
	-- Define a cor do veículo
	function vehicleCustomColor(type, veh, color)
		local r, g, b = parseInt(color[1]), parseInt(color[2]), parseInt(color[3])
	
		if type == "cor-primaria" then
			SetVehicleCustomPrimaryColour(veh, r, g, b)
			updateCart(myveh, type, {r, g, b})
		elseif type == "cor-secundaria" then
			SetVehicleCustomSecondaryColour(veh, r, g, b)
			updateCart(myveh, type, {r, g, b})
		end
	end
	
	-- Verifica se duas cores são iguais
	function sameColor(c1, c2)
		return c1[1] == c2[1] and c1[2] == c2[2] and c1[3] == c2[3]
	end
	
	-- Define a cor do neon no veículo
	function neonColor(veh, color)
		local r, g, b = parseInt(color[1]), parseInt(color[2]), parseInt(color[3])
		SetVehicleNeonLightsColour(veh, r, g, b)
	end
	
	-- Define a cor da fumaça dos pneus do veículo
	function smokeColor(veh, color)
		local r, g, b = parseInt(color[1]), parseInt(color[2]), parseInt(color[3])
		ToggleVehicleMod(veh, mod["smoke"], true)
		SetVehicleTyreSmokeColor(veh, r, g, b)
	end
	
	-- Define a cor do veículo
	function vehicleColor(type, veh, color, colortype)
		SetVehicleModKit(veh, 0)
		local p, s = GetVehicleColours(veh)
	
		if type == "primaria" then
			ClearVehicleCustomPrimaryColour(veh)
			SetVehicleColours(veh, color, s)
		elseif type == "secundaria" then
			ClearVehicleCustomSecondaryColour(veh)
			SetVehicleColours(veh, p, color)
		end
	
		updateCart(myveh, type, color, colortype)
	end
	
	-- Define o perolado no veículo
	function vehiclePerolado(veh, i)
		local perolado, wcolor = GetVehicleExtraColours(veh)
		SetVehicleExtraColours(veh, i, wcolor)
	end
	
	-- Define a cor das rodas do veículo
	function vehicleWheelColor(veh, i)
		local perolado, wcolor = GetVehicleExtraColours(veh)
		SetVehicleExtraColours(veh, perolado, i)
	end
	
	-- Divide uma string usando o delimitador especificado
	function split(s, delimiter)
		local result = {}
		for match in (s .. delimiter):gmatch("(.-)" .. delimiter) do
			table.insert(result, match)
		end
		return result
	end
	
	-- Converte RGB para hexadecimal
	function rgbToHex(rgb)
		local hexadecimal = '#'
		for _, value in ipairs(rgb) do
			local hex = ''
			while value > 0 do
				local index = math.fmod(value, 16) + 1
				value = math.floor(value / 16)
				hex = string.sub('0123456789ABCDEF', index, index) .. hex
				Citizen.Wait(0)
			end
			hex = (string.len(hex) == 0) and '00' or (string.len(hex) == 1) and '0' .. hex or hex
			hexadecimal = hexadecimal .. hex
		end
		return hexadecimal
	end	

-- Obtém o tipo de cor para uma determinada cor
function getColorType(color)
	for k, v in pairs(colors) do
		for _, j in pairs(v) do
			if j == color then
				return k
			end
		end
	end
	return false
end

-- Obtém veículos próximos a uma determinada posição
function getNearestVehicles(radius)
	local r = {}
	local px, py, pz = table.unpack(GetEntityCoords(PlayerPedId()))

	local vehs = {}
	local it, veh = FindFirstVehicle()
	if veh then
		table.insert(vehs, veh)
	end

	local ok
	repeat
		ok, veh = FindNextVehicle(it)
		if ok and veh then
			table.insert(vehs, veh)
		end
	until not ok
	EndFindVehicle(it)

	for _, veh in pairs(vehs) do
		local x, y, z = table.unpack(GetEntityCoords(veh, true))
		local distance = GetDistanceBetweenCoords(x, y, z, px, py, pz, true)
		if distance <= radius then
			r[veh] = distance
		end
	end
	return r
end

-- Obtém o veículo mais próximo dentro de um raio
function getNearestVehicle(radius)
	local veh
	local vehs = getNearestVehicles(radius)
	local min = radius + 0.0001
	for _veh, dist in pairs(vehs) do
		if dist < min then
			min = dist
			veh = _veh
		end
	end
	return veh
end

-- Desenha um texto na tela
function drawTxt(text, font, x, y, scale, r, g, b, a)
	SetTextFont(font)
	SetTextScale(scale, scale)
	SetTextColour(r, g, b, a)
	SetTextOutline()
	SetTextCentre(1)
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x, y)
end

-- Verifica se o veículo está muito longe
function isVehicleTooFar(veh)
	Citizen.CreateThread(function()
		while nui do
			local vehcoords = GetEntityCoords(veh)
			local playercoords = GetEntityCoords(PlayerPedId())
			local distance = #(playercoords - vehcoords)
			if distance > 7 then
				NOOBKING.closeNui()
				TriggerEvent("Notify", "aviso", "Você se afastou muito do veículo.", 7000)
			end
			Citizen.Wait(500)
		end
	end)
end

-- Obtém o local mais próximo de Bennys
function getNearestBennys()
	local locais = config.locais
	local playercoords = GetEntityCoords(PlayerPedId())
	for _, loc in ipairs(locais) do
		local distance = #(playercoords - loc)
		if distance < 3 then
			return loc
		end
	end
	return false
end

-- Ajusta uma pequena constante para cálculos
local function f(n)
	return (n + 0.00001)
end

-- Define a câmera para olhar para um osso específico do veículo
local function PointCamAtBone(bone, ox, oy, oz)
	SetCamActive(cam, true)
	local veh = vehicle
	local b = GetEntityBoneIndexByName(veh, bone)
	if b and b > -1 then
		local bx, by, bz = table.unpack(GetWorldPositionOfEntityBone(veh, b))
		local ox2, oy2, oz2 = table.unpack(GetOffsetFromEntityGivenWorldCoords(veh, bx, by, bz))
		local x, y, z = table.unpack(GetOffsetFromEntityInWorldCoords(veh, ox2 + f(ox), oy2 + f(oy), oz2 + f(oz)))
		SetCamCoord(cam, x, y, z)
		PointCamAtCoord(cam, GetOffsetFromEntityInWorldCoords(veh, 0, oy2, oz2))
		RenderScriptCams(1, 1, 1000, 0, 0)
	end
end

-- Move a câmera do veículo para uma posição específica
local function MoveVehCam(pos, x, y, z)
	SetCamActive(cam, true)
	local veh = vehicle
	local vx, vy, vz = table.unpack(GetEntityCoords(veh))
	local d = GetModelDimensions(GetEntityModel(veh))
	local length, width, height = d.y * -2, d.x * -2, d.z * -2
	local ox, oy, oz

	-- Calcula a posição da câmera com base na posição especificada
	if pos == 'front' then
		ox, oy, oz = table.unpack(GetOffsetFromEntityInWorldCoords(veh, f(x), (length / 2) + f(y), f(z)))
	elseif pos == "front-top" then
		ox, oy, oz = table.unpack(GetOffsetFromEntityInWorldCoords(veh, f(x), (length / 2) + f(y), (height) + f(z)))
	elseif pos == "back" then
		ox, oy, oz = table.unpack(GetOffsetFromEntityInWorldCoords(veh, f(x), -(length / 2) + f(y), f(z)))
	elseif pos == "back-top" then
		ox, oy, oz = table.unpack(GetOffsetFromEntityInWorldCoords(veh, f(x), -(length / 2) + f(y), (height / 2) + f(z)))
	elseif pos == "left" then
		ox, oy, oz = table.unpack(GetOffsetFromEntityInWorldCoords(veh, -(width / 2) + f(x), f(y), f(z)))
	elseif pos == "right" then
		ox, oy, oz = table.unpack(GetOffsetFromEntityInWorldCoords(veh, (width / 2) + f(x), f(y), f(z)))
	elseif pos == "middle" then
		ox, oy, oz = table.unpack(GetOffsetFromEntityInWorldCoords(veh, f(x), f(y), (height / 2) + f(z)))
	end

	SetCamCoord(cam, ox, oy, oz)
	PointCamAtCoord(cam, GetOffsetFromEntityInWorldCoords(veh, 0, 0, f(0)))
	RenderScriptCams(1, 1, 1000, 0, 0)
end

-- Controla a câmera com base na parte do veículo especificada
function camControl(c)
	if c == "parachoque-dianteiro" or c == "grelha" or c == "arch-cover" then
		MoveVehCam('front', -0.6, 1.5, 0.4)
	elseif c == "cor-primaria" or c == "cor-secundaria" or c == "decal" then
		MoveVehCam('middle', -2.6, 2.5, 1.4)
	elseif c == "parachoque-traseiro" or c == "escapamento" then
		MoveVehCam('back', -0.5, -1.5, 0.2)
	elseif c == "capô" then
		MoveVehCam('front-top', -0.5, 1.3, 1.0)
	elseif c == "teto" then
		MoveVehCam('middle', -2.2, 2, 1.5)
	elseif c == "vidro" then
		MoveVehCam('middle', -2.0, 2, 0.5)
	elseif c == "farol" or c == "xenon-colors" then
		MoveVehCam('front', -0.6, 1.3, 0.6)
	elseif c == "placa" then
		MoveVehCam('back', 0, -1, 0.2)
	elseif c == "para-lama" or c == "saias" then
		MoveVehCam('left', -1.8, -1.3, 0.7)
	elseif c == "aerofólio" then
		MoveVehCam('back', 0.5, -1.6, 1.3)
	elseif c == "traseira" then
		PointCamAtBone("wheel_lr", -1.4, 0, 0.3)
	elseif c == "dianteira" or c == "wheel-accessories" or c == "wheel-colors" or c == "sport" or c == "muscle" or c == "lowrider" or c == "highend" or c == "suv" or c == "offroad" or c == "tuner" then
		PointCamAtBone("wheel_lf", -1.4, 0, 0.3)
	elseif c == "neon" or c == "neon-colors" or c == "suspensão" then
		if not IsThisModelABike(GetEntityModel(vehicle)) then
			PointCamAtBone("neon_l", -2.0, 2.0, 0.4)
		end
	elseif c == "janela" or c == "interior" or c == "ornaments" or c == "dashboard" or c == "dials" or c == "seats" or c == "roll-cage" then
		MoveVehCam('back-top', 0.0, 4.0, 0.7)
	elseif c == "doors" then
		SetVehicleDoorOpen(vehicle, 0, 0, 0)
		SetVehicleDoorOpen(vehicle, 1, 0, 0)
		doorsopen = true
	elseif IsCamActive(cam) then
		ResetCam()
	else
		if doorsopen then
			SetVehicleDoorShut(vehicle, 0, 0)
			SetVehicleDoorShut(vehicle, 1, 0)
			SetVehicleDoorShut(vehicle, 4, 0)
			SetVehicleDoorShut(vehicle, 5, 0)
			doorsopen = false
		end
	end
end

-- Reseta a câmera para a visão padrão do jogador
function ResetCam()
	SetCamCoord(cam, GetGameplayCamCoords())
	SetCamRot(cam, GetGameplayCamRot(2), 2)
	RenderScriptCams(0, 1, 1000, 0, 0)
	SetCamActive(gameplaycam, true)
	EnableGameplayCam(true)
	SetCamActive(cam, false)
end

-- Controla a câmera livre
function freeCam()
	Citizen.CreateThread(function()
		SetNuiFocus(false, false)
		ResetCam()
		local freecam = true
		while freecam and nui do
			Citizen.Wait(1)
			if IsControlJustPressed(0, 85) then
				freecam = false
				SetNuiFocus(true, true)
				SendNUIMessage({ action = "cam" })
			end
		end
	end)
end

-- Mostra a interface NUI
function showNui()
	print("OPEN MENU")
	SetNuiFocus(true, true)
	SendNUIMessage({ action = "showMenu" })
	nui = true
end

-- Fecha a interface NUI e reseta o estado do veículo
function NOOBKING.closeNui()
	print("Close")
	if IsCamActive(cam) then
		SetCamActive(cam, false)
	end
	SetVehicleLights(vehicle, 0)
	ResetCam()
	SetNuiFocus(false, false)
	SendNUIMessage({ action = "hideMenu" })
	camControl("close")
	setVehicleMods(vehicle, myveh)
	FreezeEntityPosition(vehicle, false)
	TriggerServerEvent("nation:removeVehicle", VehToNet(vehicle))
	nui = false
	vehicle = nil
	cam = nil
	damage = 0
	cart = {["total"] = 0}
	myveh = {}
end

-- Sincroniza as modificações do veículo
RegisterNetEvent('nation:applymods_sync')
AddEventHandler('nation:applymods_sync', function(custom, vnet)
	if NetworkDoesEntityExistWithNetworkId(vnet) then
		local veh = NetToVeh(vnet)
		if DoesEntityExist(veh) then
			if custom and custom.customPcolor then
				setVehicleMods(veh, custom)
				SetVehicleDirtLevel(veh, 0.0)
			end
		end
	end
end)

-- Aplica o chip de tunagem ao veículo
RegisterNetEvent('nation:applytunnerchip')
AddEventHandler('nation:applytunnerchip', function(tunner_customs, vnet)
	if NetworkDoesEntityExistWithNetworkId(vnet) then
		local veh = NetToVeh(vnet)
		if DoesEntityExist(veh) then
			if tunner_customs then
				SetVehicleHandlingFloat(veh, "CHandlingData", "fInitialDriveForce", tunner_customs.boost * 1.0)
				SetVehicleHandlingFloat(veh, "CHandlingData", "fDriveInertia", tunner_customs.fuelmix * 1.0)
				SetVehicleEnginePowerMultiplier(veh, tunner_customs.gearchange * 1.0)
				SetVehicleHandlingFloat(veh, "CHandlingData", "fBrakeBiasFront", tunner_customs.braking * 1.0)
				SetVehicleHandlingFloat(veh, "CHandlingData", "fDriveBiasFront", tunner_customs.drivebiass * 1.0)
				SetVehicleHandlingFloat(veh, "CHandlingData", "fBrakeForce", tunner_customs.brakeforce * 1.0)
			end
		end
	end
end)
