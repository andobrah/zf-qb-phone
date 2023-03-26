local Hashtags = {} -- Located in the Twitter File as well ??
local Calls = {}


-- Functions
local function SplitStringToArray(string)
    local retval = {}
    for i in string.gmatch(string, "%S+") do
        retval[#retval+1] = i
    end
    return retval
end


-- Events
RegisterNetEvent('qb-phone:server:SetCallState', function(bool)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    if not Calls[Player.PlayerData.citizenid] then Calls[Player.PlayerData.citizenid] = {} end
    Calls[Player.PlayerData.citizenid].inCall = bool
end)

RegisterNetEvent('qb-phone:server:CallContact', function(targetData, callId, anonymousCall)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local Target = QBCore.Functions.GetPlayerByPhone(tostring(targetData.number))
    if not Target or not Player then return end

    TriggerClientEvent('qb-phone:client:GetCalled', Target.PlayerData.source, Player.PlayerData.charinfo.phone, callId, anonymousCall)
end)

RegisterNetEvent('qb-phone:server:EditContact', function(newName, newNumber, oldName, oldNumber)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if not Player then return end
    exports.oxmysql:execute('UPDATE player_contacts SET name = ?, number = ? WHERE citizenid = ? AND name = ? AND number = ?', { newName, newNumber, Player.PlayerData.citizenid, oldName, oldNumber })
end)

RegisterNetEvent('qb-phone:server:RemoveContact', function(name, number)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if not Player then return end
    exports.oxmysql:execute('DELETE FROM player_contacts WHERE name = ? AND number = ? AND citizenid = ?', { name, number, Player.PlayerData.citizenid })
end)

RegisterNetEvent('qb-phone:server:AddNewContact', function(name, number)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if not Player then return end
    exports.oxmysql:insert('INSERT INTO player_contacts (citizenid, name, number) VALUES (?, ?, ?)', {Player.PlayerData.citizenid, tostring(name), number})
end)

RegisterNetEvent('qb-phone:server:AddRecentCall', function(type, data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local hour = os.date("%H")
    local minute = os.date("%M")
    local label = hour .. ":" .. minute

    TriggerClientEvent('qb-phone:client:AddRecentCall', src, data, label, type)

    local Target = QBCore.Functions.GetPlayerByPhone(data.number)
    if not Target then return end

    TriggerClientEvent('qb-phone:client:AddRecentCall', Target.PlayerData.source, {
        name = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname,
        number = Player.PlayerData.charinfo.phone,
        anonymous = data.anonymous
    }, label, "outgoing")
end)

RegisterNetEvent('qb-phone:server:GiveContactDetails', function(playerId)
    local src = source
    if not playerId or not src then return end

    local Sender = QBCore.Functions.GetPlayer(src)
    local contactInfo = {
        name = Sender.PlayerData.charinfo.firstname .. " " .. Sender.PlayerData.charinfo.lastname,
        number = Sender.PlayerData.charinfo.phone,
        bank = Sender.PlayerData.charinfo.account,
    }

    TriggerClientEvent('qb-phone:client:giveContactRequest', playerId, contactInfo)
end)

RegisterNetEvent('qb-phone:server:acceptContactRequest', function(contactInfo)
    local src = source
    if not contactInfo or not src then return end
    local Player = QBCore.Functions.GetPlayer(src)
    local citizenid = Player.PlayerData.citizenid

    local result = MySQL.query.await("SELECT * FROM player_contacts WHERE citizenid = ? AND number = ?", {citizenid, contactInfo.number})
    if result[1] then PhoneNotify(src, 'Contacts', 'You already have this number added', 'fas fa-exclamation-circle', '#f25f5c') return end

    exports.oxmysql:insert('INSERT INTO player_contacts (citizenid, name, number) VALUES (?, ?, ?)', {citizenid, tostring(contactInfo.name), contactInfo.number})
    TriggerClientEvent('qb-phone:client:updateContactInfo', src, contactInfo)
end)

RegisterNetEvent('qb-phone:server:CancelCall', function(ContactData)
    local Player = QBCore.Functions.GetPlayerByPhone(tostring(ContactData.TargetData.number))
    if not Player then return end
    TriggerClientEvent('qb-phone:client:CancelCall', Player.PlayerData.source)
end)

RegisterNetEvent('qb-phone:server:AnswerCall', function(CallData)
    local Player = QBCore.Functions.GetPlayerByPhone(CallData.TargetData.number)
    if not Player then return end
    TriggerClientEvent('qb-phone:client:AnswerCall', Player.PlayerData.source)
end)

RegisterNetEvent('qb-phone:server:SaveMetaData', function(MData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    Player.Functions.SetMetaData("phone", MData)
end)


-- Callbacks
QBCore.Functions.CreateCallback('qb-phone:server:GetCallState', function(source, cb, contactData)
    local number = tostring(contactData.number)
    local Player = QBCore.Functions.GetPlayer(source)
    local Target = QBCore.Functions.GetPlayerByPhone(number)

    if not Target then return cb(false, false) end
    if Target.PlayerData.citizenid == Player.PlayerData.citizenid then return cb(false, false) end

    if Calls[Target.PlayerData.citizenid] then
        if Calls[Target.PlayerData.citizenid].inCall then
            cb(false, true)
        else
            cb(true, true)
        end
    else
        cb(true, true)
    end
end)

QBCore.Functions.CreateCallback('qb-phone:server:GetPhoneData', function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not src then return end
    local citizenid = Player.PlayerData.citizenid

    local PhoneData = {
        PlayerContacts = {},
        Chats = {},
        Hashtags = {},
        Invoices = {},
        Garage = {},
        Mails = {},
        Documents = {},
        Adverts = Adverts,
        Tweets = Tweets,
        Images = {},
        ChatRooms = {},
    }

    local result = exports.oxmysql:executeSync('SELECT * FROM player_contacts WHERE citizenid = ? ORDER BY name ASC', { citizenid })
    if result[1] then PhoneData.PlayerContacts = result end

    local Invoices = exports.oxmysql:executeSync('SELECT * FROM phone_invoices WHERE citizenid = ?', { citizenid })
    if Invoices[1] then PhoneData.Invoices = Invoices end

    local Note = exports.oxmysql:executeSync('SELECT * FROM phone_note WHERE citizenid = ?', { citizenid })
    if Note[1] then PhoneData.Documents = Note end

    local messages = exports.oxmysql:executeSync('SELECT * FROM phone_messages WHERE citizenid = ?', { citizenid })
    if messages and next(messages) then PhoneData.Chats = messages end

    if Hashtags and next(Hashtags) then PhoneData.Hashtags = Hashtags end

    local mails = exports.oxmysql:executeSync('SELECT * FROM player_mails WHERE citizenid = ? ORDER BY `date` ASC', { citizenid })
    if mails[1] then PhoneData.Mails = mails end

    local images = exports.oxmysql:executeSync('SELECT * FROM phone_gallery WHERE citizenid = ? ORDER BY `date` DESC',{ citizenid })
    if images and next(images) then PhoneData.Images = images end

    local chat_rooms = MySQL.query.await("SELECT id, room_code, room_name, room_owner_id, room_owner_name, room_members, is_pinned, IF(room_pin = '' or room_pin IS NULL, false, true) AS protected FROM phone_chatrooms")
    if chat_rooms[1] then
        PhoneData.ChatRooms = chat_rooms
        ChatRooms = chat_rooms
    end

    cb(PhoneData)
end)

QBCore.Functions.CreateCallback('qb-phone:server:FetchResult', function(_, cb, input)
    local search = escape_sqli(input)
    local searchData = {}
    local ApaData = {}
    local query = 'SELECT * FROM `players` WHERE `citizenid` = "' .. search .. '"'
    local searchParameters = SplitStringToArray(search)
    if #searchParameters > 1 then
        query = query .. ' OR `charinfo` LIKE "%' .. searchParameters[1] .. '%"'
        for i = 2, #searchParameters do
            query = query .. ' AND `charinfo` LIKE  "%' .. searchParameters[i] .. '%"'
        end
    else
        query = query .. ' OR `charinfo` LIKE "%' .. search .. '%"'
    end
    local ApartmentData = exports.oxmysql:executeSync('SELECT * FROM apartments', {})
    for k, v in pairs(ApartmentData) do
        ApaData[v.citizenid] = ApartmentData[k]
    end
    local result = exports.oxmysql:executeSync(query)
    if result[1] then
        for _, v in pairs(result) do
            local charinfo = json.decode(v.charinfo)
            local metadata = json.decode(v.metadata)
            local appiepappie = {}
            if ApaData[v.citizenid] and next(ApaData[v.citizenid]) then
                appiepappie = ApaData[v.citizenid]
            end
            searchData[#searchData+1] = {
                citizenid = v.citizenid,
                firstname = charinfo.firstname,
                lastname = charinfo.lastname,
                birthdate = charinfo.birthdate,
                phone = charinfo.phone,
                nationality = charinfo.nationality,
                gender = charinfo.gender,
                warrant = false,
                driverlicense = metadata["licences"]["driver"],
                appartmentdata = appiepappie
            }
        end
        cb(searchData)
    else
        cb(nil)
    end
end)
