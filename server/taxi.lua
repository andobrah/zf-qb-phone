-- Callbacks
QBCore.Functions.CreateCallback('qb-phone:server:GetAvailableTaxiDrivers', function(_, cb)
    local TaxiDrivers = {}

    for i = 1, #Config.TaxiJob do
        local job = Config.TaxiJob[i]
        TaxiDrivers[job.Job] = {}
        TaxiDrivers[job.Job].Players = {}
    end

    for _,id in pairs(QBCore.Functions.GetPlayers()) do
        local Player = QBCore.Functions.GetPlayer(id)
        if Player then
            local job = Player.PlayerData.job.name
            if TaxiDrivers[job] and Player.PlayerData.job.onduty then
                TaxiDrivers[job].Players[#TaxiDrivers[job].Players + 1] = {
                    Name = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname,
                    Phone = Player.PlayerData.charinfo.phone,
                }
            end
        end
    end
    cb(TaxiDrivers)
end)
