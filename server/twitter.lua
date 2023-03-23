Tweets = {}

-- Functions
local function AddNewTweet(TweetData)
    local tweetID = TweetData and TweetData.tweetId or "TWEET-"..math.random(11111111, 99999999)

    MySQL.insert('INSERT INTO phone_tweets (citizenid, firstName, lastName, message, url, tweetid, type) VALUES (@citizenid, @firstname, @lastname, @message, @url, @tweetid, @type)', {
        ['@citizenid'] = TweetData.citizenid,
        ['@firstname'] = TweetData.firstName:gsub("[%<>\"()\'$]",""),
        ['@lastname'] = TweetData.lastName:gsub("[%<>\"()\'$]",""),
        ['@message'] = TweetData.message:gsub("[%<>\"()\'$]",""),
        ['@url'] = TweetData.url,
        ['@tweetid'] = tweetID,
        ['@type'] = TweetData.type or "tweet",
    }, function(id)
        if id then
            Tweets[#Tweets+1] = {
                id = id,
                citizenid = TweetData.citizenid or "TEMP332",
                firstName = TweetData.firstName:gsub("[%<>\"()\'$]",""),
                lastName = TweetData.lastName:gsub("[%<>\"()\'$]",""),
                message = TweetData.message:gsub("[%<>\"()\'$]",""),
                url = TweetData.url or "",
                tweetId = tweetID,
                type = TweetData.type or "tweet",
                date = os.date('%Y-%m-%d %H:%M:%S')
            }

            TriggerClientEvent('qb-phone:client:UpdateTweets', -1, 0, Tweets, false)
        end
    end)
end exports("AddNewTweet", AddNewTweet)


-- Events
RegisterNetEvent('qb-phone:server:DeleteTweet', function(tweetId)
    local src = source
    local citizenid = QBCore.Functions.GetPlayer(src).PlayerData.citizenid
    local delete = false
    
    for i = 1, #Tweets do
        if Tweets[i].tweetId == tweetId and Tweets[i].citizenid == citizenid then
            table.remove(Tweets, i)
            delete = true
            break
        end
    end
    
    if not delete then return end
    TriggerClientEvent('qb-phone:client:UpdateTweets', -1, src, Tweets, true)
end)

RegisterNetEvent('qb-phone:server:UpdateTweets', function(TweetData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local hasVPN = exports[Config.Exports.Inventory]:HasItem(src, Config.VPNItem)
    
    if (TweetData.showAnonymous and hasVPN) then
        TweetData.firstName = "Anonymous"
        TweetData.lastName = ""
    end

    MySQL.insert('INSERT INTO phone_tweets (citizenid, firstName, lastName, message, url, tweetid, type) VALUES (@citizenid, @firstname, @lastname, @message, @url, @tweetid, @type)', {
        ['@citizenid'] = TweetData.citizenid,
        ['@firstname'] = TweetData.firstName:gsub("[%<>\"()\'$]",""),
        ['@lastname'] = TweetData.lastName:gsub("[%<>\"()\'$]",""),
        ['@message'] = TweetData.message:gsub("[%<>\"()\'$]",""),
        ['@url'] = TweetData.url,
        ['@tweetid'] = TweetData.tweetId,
        ['@type'] = TweetData.type,
    }, function(id)
        if id then
            Tweets[#Tweets+1] = {
                id = id,
                citizenid = TweetData.citizenid,
                firstName = TweetData.firstName:gsub("[%<>\"()\'$]",""),
                lastName = TweetData.lastName:gsub("[%<>\"()\'$]",""),
                message = TweetData.message:gsub("[%<>\"()\'$]",""),
                url = TweetData.url,
                tweetId =TweetData.tweetId,
                type = TweetData.type,
                date = os.date('%Y-%m-%d %H:%M:%S')
            }

            TriggerClientEvent('qb-phone:client:UpdateTweets', -1, src, Tweets, false)
        end
    end)
end)


-- Thread
CreateThread(function()
    local tweetsSelected = MySQL.query.await('SELECT * FROM phone_tweets WHERE `date` > NOW() - INTERVAL ? hour', {Config.TweetDuration})
    Tweets = tweetsSelected
end)
