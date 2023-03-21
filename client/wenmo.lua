-- NUI Callback

RegisterNUICallback('wenmo_givemoney_toID', function(data)
    TriggerServerEvent('qb-phone:server:wenmo_givemoney_toID', data)
end)

RegisterNetEvent('QBCore:Client:OnMoneyChange', function(account, amount, type, reason)
    if not account == 'bank' then return end
    local color = type == 'remove' and "#f5a15b" or "#8ee074"
    local amount = type == 'remove' and "- $" .. amount or "+ $" .. amount
    if reason == 'unknown' then reason = false end
    
    SendNUIMessage({
        action = "ChangeMoney_Wenmo",
        color = color,
        amount = amount,
        reason = reason,
    })
end)
