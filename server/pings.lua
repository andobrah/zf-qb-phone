-- Events
RegisterNetEvent("qb-phone:server:sendPing", function(id)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local Receiver = QBCore.Functions.GetPlayer(tonumber(id))
    local hasVPN = exports[Config.Exports.Inventory]:HasItem(src, Config.VPNItem)
    local name = hasVPN and 'Anonymous' or Player.PlayerData.charinfo.firstname

    if not Receiver then PhoneNotify(src, 'Ping', 'No receiver found with that id.', 'fas fa-exclamation-circle', '#f25f5c') return end

    local info = { type = 'ping', Other = tonumber(id), Player = src, Name = name, OtherName = Other.PlayerData.charinfo.firstname }
    if Player.PlayerData.citizenid ~= Other.PlayerData.citizenid then
        TriggerClientEvent("qb-phone:client:sendNotificationPing", tonumber(id), info)
        PhoneNotify(src, 'Ping', 'Request Sent.', 'fas fa-check-circle', '#70c1b3')
    else
        PhoneNotify(src, 'Ping', 'You cannot send a ping to yourself.', 'fas fa-exclamation-circle', '#70c1b3')
    end
end)

RegisterNetEvent("qb-phone:server:sendingPing", function(Other, Player, Name, OtherName)
    PhoneNotify(Player, 'Ping', OtherName .. ' Accepted your Ping!', 'fas fa-map-pin', '#247ba0')
    TriggerClientEvent("qb-phone:client:sendPing", Other, Name, GetEntityCoords(GetPlayerPed(Player)))
end)
