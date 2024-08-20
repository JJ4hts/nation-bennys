local QBCore = exports['qb-core']:GetCoreObject()
local using_bennys = {}

QBCore.Functions.CreateCallback('nation:checkPermission', function(source, cb)
    local src = source
    Player = QBCore.Functions.GetPlayer(src)
    if Player.PlayerData.job.name == config.permissao then
        cb(true)
    elseif config.mechaniconly then
        cb(false)
        TriggerClientEvent("Notify",source,"negado","Essa merda só pode acessar o mecânico",7000)
    elseif not config.mechaniconly then
        cb(true)
    end
end)

QBCore.Functions.CreateCallback('nation:checkPayment', function(source, cb, amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local bankey = Player.Functions.GetMoney('bank')
    local cash = Player.Functions.GetMoney('bank')
    
    if not config.mechaniconly and bankey >= amount then
        if config.societymoney then
            local societyAccount = nil
            TriggerEvent("qb-bank:getSocietyAccount", config.society_name, function(account)
                societyAccount = account
            end)
            Player.Functions.AddMoney('bank', amount)
        end
        Player.Functions.RemoveMoney('bank', amount)
        TriggerClientEvent("Notify", source, "sucesso", "Upgrade <b>Success</b><br>Total Cost <b>$"..tonumber(amount).." $ <b>.", 7000)
        cb(true)
    elseif not config.mechaniconly and cash >= amount then
        if config.societymoney then
            local societyAccount = nil
            TriggerEvent("qb-bank:getSocietyAccount", config.society_name, function(account)
                societyAccount = account
            end)
            societyAccount.addMoney(amount)
        end
        Player.Functions.RemoveMoney('cash', amount)
        TriggerClientEvent("Notify", source, "sucesso", "Upgrade <b>Success</b><br>Total Cost <b>$"..tonumber(amount).." $ <b>.", 7000)
        cb(true)
    elseif (config.mechaniconly and (bankey >= amount or cash >= amount)) then
        if config.societymoney then
            local societyAccount = nil
            TriggerEvent("qb-bank:getSocietyAccount", config.society_name, function(account)
                societyAccount = account
            end)
            societyAccount.removeMoney(amount)
            TriggerClientEvent("Notify", source, "sucesso", "Upgrade <b>Success</b><br>Total Cost <b>$"..tonumber(amount).." $ <b>.", 7000)
            cb(true)
        else
            if bankey >= amount then
                Player.Functions.RemoveMoney('bank', amount)
                TriggerClientEvent("Notify", source, "sucesso", "Upgrade <b>Success</b><br>Total Cost <b>$"..tonumber(amount).." $ <b>.", 7000)
                cb(true)
            elseif cash >= amount then
                Player.Functions.RemoveMoney('cash', amount)
                TriggerClientEvent("Notify", source, "sucesso", "Upgrade <b>Success</b><br>Total Cost <b>$"..tonumber(amount).." $ <b>.", 7000)
                cb(true)
            end
        end
    else
        TriggerClientEvent("Notify", source, "negado", "Você não tem dinheiro suficiente.", 7000)
        cb(false)
    end
end)

RegisterServerEvent("nation:removeVehicle")
AddEventHandler("nation:removeVehicle", function(vehicle)
    using_bennys[vehicle] = nil
    return true
end)

QBCore.Functions.CreateCallback('nation:checkVehicle', function(source, cb, vehicle)
    if using_bennys[vehicle] then
        cb(false)
    else
        using_bennys[vehicle] = true
        cb(true)
    end
end)

AddEventHandler('playerDropped', function (reason)
    print('Player ' .. GetPlayerName(source) .. ' dropped (Reason: ' .. reason .. ')')
end)
  
RegisterServerEvent('saveVehicle')
AddEventHandler('saveVehicle', function(plate, props)
    local Player = QBCore.Functions.GetPlayer(source)
    if props.plate == nil then
        props.plate = plate
    end
    MySQL.Async.fetchAll('SELECT vehicle FROM player_vehicles WHERE plate = @plate', {
        ['@plate'] = props.plate
    }, function(result)
        if result[1] ~= nil and result[1].vehicle then
            local vehicle = json.decode(result[1].vehicle)
            if props.model == vehicle.model then
                MySQL.Async.execute('UPDATE player_vehicles SET vehicle = @vehicle WHERE plate = @plate', {
                    ['@plate'] = props.plate,
                    ['@vehicle'] = json.encode(props)
                })
            else
                print(('NOOB: %s tentou atualizar o veículo com modelo de veículo incompatível!'):format(Player.PlayerData.citizenid))
            end
        end
    end)
end)

RegisterServerEvent("nation:syncApplyMods")
AddEventHandler("nation:syncApplyMods", function(vehicle_tuning, vehicle)
    TriggerClientEvent("nation:applymods_sync", -1, vehicle_tuning, vehicle)
end)
