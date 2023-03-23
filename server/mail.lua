-- Functions
local function GenerateMailId()
    return math.random(111111, 999999)
end


-- Events
RegisterNetEvent('qb-phone:server:RemoveMail', function(mailId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not mailId or not Player then return end

    local citizenid = Player.PlayerData.citizenid

    MySQL.query('DELETE FROM player_mails WHERE mailid = ? AND citizenid = ?', {mailId, citizenid})
    SetTimeout(100, function()
        local mails = MySQL.query.await('SELECT * FROM player_mails WHERE citizenid = ? ORDER BY `date` ASC', {citizenid})
        TriggerClientEvent('qb-phone:client:UpdateMails', src, mails)
    end)
end)

RegisterNetEvent('qb-phone:server:sendNewMail', function(mailData, citizenid)
    if not mailData or not mailData.sender or not mailData.subject or not mailData.message then return end
    
    local Player = citizenid and QBCore.Functions.GetPlayerByCitizenId(citizenid) or QBCore.Functions.GetPlayer(source)
    if Player then
        local cid = Player.PlayerData.citizenid
        if mailData.button then
            MySQL.insert('INSERT INTO player_mails (`citizenid`, `sender`, `subject`, `message`, `mailid`, `read`, `button`) VALUES (?, ?, ?, ?, ?, ?, ?)', {cid, mailData.sender, mailData.subject, mailData.message, GenerateMailId(), 0, json.encode(mailData.button)})
        else
            MySQL.insert('INSERT INTO player_mails (`citizenid`, `sender`, `subject`, `message`, `mailid`, `read`) VALUES (?, ?, ?, ?, ?, ?)', {cid, mailData.sender, mailData.subject, mailData.message, GenerateMailId(), 0})
        end

        TriggerClientEvent('qb-phone:client:NewMailNotify', Player.PlayerData.source, mailData)

        SetTimeout(200, function()
            local mails = MySQL.query.await('SELECT * FROM player_mails WHERE citizenid = ? ORDER BY `date` ASC', {cid})
            if mails[1] then
                for _, v in pairs(mails) do
                    if v.button then
                        v.button = json.decode(v.button)
                    end
                end
            end

            TriggerClientEvent('qb-phone:client:UpdateMails', Player.PlayerData.source, mails)
        end)
    elseif citizenid then
        if mailData.button then
            MySQL.insert('INSERT INTO player_mails (`citizenid`, `sender`, `subject`, `message`, `mailid`, `read`, `button`) VALUES (?, ?, ?, ?, ?, ?, ?)', {citizenid, mailData.sender, mailData.subject, mailData.message, GenerateMailId(), 0, json.encode(mailData.button)})
        else
            MySQL.insert('INSERT INTO player_mails (`citizenid`, `sender`, `subject`, `message`, `mailid`, `read`) VALUES (?, ?, ?, ?, ?, ?)', {citizenid, mailData.sender, mailData.subject, mailData.message, GenerateMailId(), 0})
        end
    end
end)
