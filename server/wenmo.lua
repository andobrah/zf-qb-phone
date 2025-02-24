-- Events
RegisterNetEvent('qb-phone:server:wenmo_givemoney_toID', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local Target = QBCore.Functions.GetPlayer(tonumber(data.id))
    local amount = tonumber(data.amount)
    local reason = data.reason

    if src == tonumber(data.id) then PhoneNotify(src, 'Wenmo', 'You can\'t send yourself money', "fas fa-exclamation-circle", "#e76f51") return end
    if not Target then return PhoneNotify(src, 'Wenmo', 'The recipient is not available', 'error', 'fas fa-exclamation-circle', '#e76f51') end

    local txt = "Wenmo: " .. reason
    if Player.Functions.GetMoney('bank') >= amount then
        Player.Functions.RemoveMoney('bank', amount, txt)
        Target.Functions.AddMoney('bank', amount, txt)

        if Config.RenewedBanking then
            local pCitizen = Player.PlayerData.citizenid
            local pName = ("%s %s"):format(Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname)
            local tCitizen = Target.PlayerData.citizenid
            local tName = ("%s %s"):format(Target.PlayerData.charinfo.firstname, Target.PlayerData.charinfo.lastname)

            local transaction = exports['Renewed-Banking']:handleTransaction(pCitizen, "Wenmo Transaction", amount, txt, tName, pName, "withdraw")
            exports['Renewed-Banking']:handleTransaction(tCitizen, "Wenmo Transaction", amount, txt, pName, tName, "deposit", transaction.trans_id)
        end
    else
        PhoneNotify(src, 'Wenmo', 'You don\'t have enough money', "fas fa-exclamation-circle", "#e76f51")
    end
end)
