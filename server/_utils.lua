QBCore = exports['qb-core']:GetCoreObject()

function PhoneNotify(source, title, message, icon, color, timeout)
    TriggerClientEvent('qb-phone:client:CustomNotification', source, title, message, icon, color, timeout or 5000)
end