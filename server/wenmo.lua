RegisterNetEvent('qb-phone:server:wenmo_givemoney_toID', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local Target = QBCore.Functions.GetPlayer(tonumber(data.id))
    local amount = tonumber(data.amount)
    local reason = data.reason

    if src == tonumber(data.id) then return end
    if not Target then return PhoneNotify(src, 'Wenmo', 'The recipient is not available', 'error', 'fas fa-exclamation-circle', '#e76f51') end

    local txt = "Wenmo: " .. reason
    if Player.PlayerData.money.bank >= amount then
        Player.Functions.RemoveMoney('bank', amount, txt)
        Target.Functions.AddMoney('bank', amount, txt)

        if Config.RenewedBanking then
            local pCitizen = Player.PlayerData.citizenid
            local name = ("%s %s"):format(Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname)

            local tCitizen = Target.PlayerData.citizenid
            local name2 = ("%s %s"):format(Target.PlayerData.charinfo.firstname, Target.PlayerData.charinfo.lastname)

            exports['Renewed-Banking']:handleTransaction(pCitizen, "Wenmo Transaction", amount, txt, name2, name, "withdraw")
            exports['Renewed-Banking']:handleTransaction(tCitizen, "Wenmo Transaction", amount, txt, name, name2, "deposit")
        end
    else
        PhoneNotify(src, 'Wenmo', 'You don\'t have enough money', "fas fa-exclamation-circle", "#e76f51")
    end
end)
