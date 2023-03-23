-- Events
RegisterNetEvent('qb-phone:server:PayMyInvoice', function(society, amount, invoiceId, sendercitizenid, resource)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local Sender = QBCore.Functions.GetPlayerByCitizenId(sendercitizenid)

    if Player.Functions.GetMoney('bank') >= amount then
        Player.Functions.RemoveMoney('bank', amount, "paid-invoice")

        if Sender and Config.BillingCommissions and Config.BillingCommissions[society] then
            local commission = math.ceil(amount * Config.BillingCommissions[society])
            Sender.Functions.AddMoney('bank', commission)
        end

        if Sender then
            PhoneNotify(Sender.PlayerData.source, 'Employement', "Invoice of $" .. amount .. " paid by " .. Sender.PlayerData.charinfo.firstname, 'fas fa-file-invoice-dollar', '#247ba0')
        end

        TriggerClientEvent('qb-phone:client:RemoveInvoiceFromTable', src, invoiceId)
        TriggerEvent("qb-phone:server:InvoiceHandler", true, amount, src, resource)
        exports.oxmysql:execute('DELETE FROM phone_invoices WHERE id = ?', {invoiceId})
    end
end)

RegisterNetEvent('qb-phone:server:DeclineMyInvoice', function(amount, invoiceId, sendercitizenid, resource)
    local Player = QBCore.Functions.GetPlayer(source)
    local SenderPlayer = QBCore.Functions.GetPlayerByCitizenId(sendercitizenid)
    if not Player then return end

    exports.oxmysql:execute('DELETE FROM phone_invoices WHERE id = ?', {invoiceId})
    if SenderPlayer then
        PhoneNotify(SenderPlayer.PlayerData.source, 'Invoice', 'Invoice of $' .. amount .. ' has been declined', 'fas fa-file-invoice-dollar', '#ffe066')
    end
    TriggerClientEvent('qb-phone:client:RemoveInvoiceFromTable', source, invoiceId)
    TriggerEvent("qb-phone:server:InvoiceHandler", false, amount, source, resource)
end)

RegisterNetEvent('qb-phone:server:CreateInvoice', function(billed, biller, amount)
    local resource = GetInvokingResource()
    local Receiver = QBCore.Functions.GetPlayer(tonumber(billed))
    local Sender = QBCore.Functions.GetPlayer(biller)

    if not tonumber(amount) or not Receiver or not Sender then return end
    MySQL.Async.insert('INSERT INTO phone_invoices (citizenid, amount, society, sender, sendercitizenid) VALUES (?, ?, ?, ?, ?)', {
        Receiver.PlayerData.citizenid,
        tonumber(amount),
        Sender.PlayerData.job.name,
        Sender.PlayerData.charinfo.firstname,
        Sender.PlayerData.citizenid
    }, function(id)
        if id then TriggerClientEvent('qb-phone:client:AcceptorDenyInvoice', Receiver.PlayerData.source, id, Sender.PlayerData.charinfo.firstname, Sender.PlayerData.job.name, Sender.PlayerData.citizenid, tonumber(amount), resource) end
    end)
end)


-- Callbacks
QBCore.Functions.CreateCallback('qb-phone:server:GetInvoices', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    local invoices = exports.oxmysql:executeSync('SELECT * FROM phone_invoices WHERE citizenid = ?', {Player.PlayerData.citizenid})
    cb(invoices)
end)
