local TriggerClientEvent = TriggerClientEvent
local exports = exports
local print = print
local tostring = tostring

local sharedConfig = require 'config.dankutils_shared'
local phone = {}

if IsDuplicityVersion() then
    -- SERVER
    -- Abstracting sending an email
    -- data expects: { sender = string, subject = string, message = string, button = table (optional) }
    phone.sendEmail = function(source, data)
        local phoneType = sharedConfig.Phone
        if phoneType == 'lb-phone' then
            exports["lb-phone"]:SendMail({
                to = source,
                sender = data.sender or "System",
                subject = data.subject or "Notification",
                message = data.message or ""
            })
        elseif phoneType == 'qs-smartphone' then
            -- qs-smartphone expects an event to send mail
            TriggerEvent('qs-smartphone:server:sendNewMail', {
                sender = data.sender or "System",
                subject = data.subject or "Notification",
                message = data.message or "",
                button = data.button
            })
        elseif phoneType == 'qb-phone' then
            TriggerClientEvent('qb-phone:client:sendNewMail', source, {
                sender = data.sender or "System",
                subject = data.subject or "Notification",
                message = data.message or "",
                button = data.button
            })
        elseif phoneType == 'gksphone' then
            TriggerClientEvent('gksphone:client:NewMail', source, {
                sender = data.sender or "System",
                image = '/html/static/img/icons/mail.png',
                subject = data.subject or "Notification",
                message = data.message or ""
            })
        elseif phoneType == 'yseries' or phoneType == 'yphone' then
            exports['yseries']:SendEmail(source, {
                sender = data.sender or "System",
                subject = data.subject or "Notification",
                message = data.message or ""
            })
        else
            print('^3[Dank_Utils] Phone: Unsupported phone system ('..tostring(phoneType)..') for sendEmail.^0')
        end
    end

    -- Abstracting sending an SMS
    -- data expects: { number = string, message = string }
    phone.sendSMS = function(source, data)
        local phoneType = sharedConfig.Phone
        if phoneType == 'lb-phone' then
            exports["lb-phone"]:SendMessage(data.number, data.message)
        elseif phoneType == 'qs-smartphone' then
            TriggerClientEvent('qs-smartphone:client:Notify', source, {
                title = "New Message",
                text = data.message or "",
                icon = "./img/apps/whatsapp.png",
                timeout = 5000
            })
        elseif phoneType == 'qb-phone' then
            -- Note: qb-phone doesn't have a direct "send sms" without an internal number generation usually, we can just notify
            TriggerClientEvent('QBCore:Notify', source, "New SMS: " .. (data.message or ""), "primary", 5000)
        elseif phoneType == 'gksphone' then
            TriggerClientEvent('gksphone:client:SendSMS', source, data.number, data.message)
        elseif phoneType == 'yseries' or phoneType == 'yphone' then
            exports['yseries']:SendSMS(data.number, data.message)
        else
            print('^3[Dank_Utils] Phone: Unsupported phone system ('..tostring(phoneType)..') for sendSMS.^0')
        end
    end
end

return phone
