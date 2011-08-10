#!/usr/bin/env lua
-- ctcp.lua - ctcp functions file for minnet
-- Copyright Stæld Lakorv, 2010-2011 <staeld@staeld.co.cc>
-- This file is part of Minnet.
-- Minnet is released under the GPLv3 - see ../COPYING

-- logctcp(o, req): Log received ctcp request req from origin o
function logctcp(o, req)
    log("Received CTCP " .. req .. " request from " .. o .. " on " .. net.name, "info")
end

function ctcp.action(u, chan, act) -- send an ACTION (/me) to 'channel'
    act = act:gsub("%%", "%%%%")
    sendRaw("PRIVMSG " .. chan .. " :\001ACTION " .. act .. "\001")
    log("Sent CTCP ACTION '" .. act .. "' to " .. net.name .. "/" .. chan, u, "debug")
end
function ctcp.version(arg) -- request a VERSION reply to 'arg'
    arg = arg:match("^(%S+)")
    sendRaw("PRIVMSG " .. arg .. " :\001VERSION\001")
    log("Sent CTCP VERSION request to " .. arg .. " on " .. net.name, u, "info")
end

-- ctcp.check_active(o, t): check if there is an active CTCP request of type 't' for user 'o'
function ctcp.check_active(o, t)
    if not ( o and t ) then return nil end
    local wQ, num
    for i, name in ipairs(ctcp.active[t]) do
        if o:lower() == name:lower() then
            wQ = true
            num = i
            break
        end
    end
    if wQ then
        return true, num
    else
        return nil
    end
end
-- ctcp.rem_active(o, t): remove the active CTCP request of type 't' for user 'o'
function ctcp.rem_active(o, t)
    local _, num = ctcp.check_active(o, t)
    if num then
        table.remove(ctcp.active[t], num)
    else
        err("Out of cheese in ctcp.rem_active()!")
    end
end

-- ctcp.read(line): read a line and parse it to check for valid (recognised) CTCP requests
function ctcp.read(l)
    if not l then return nil end
    -- Catch who is sending:
    local origin = l:match("^:(%S+)!") or ""
    -- Exclude sender from line:
    l = l:gsub("^%:" .. origin .. "%S+%s*", "")

    -- Check if line l matches a known ctcp command:
    --   VERSION
    if l:match("%\001%s*VERSION") then
        if l:match("%\001VERSION%s*%\001") then
            logctcp(origin, "VERSION")
            sendNotice(origin, "\001VERSION Minnet " .. version .. "\001")
        else
            if not ctcp.check_active(origin, "version") then return nil end
            local reply = l:match("VERSION%s*(.-)%\001")
            if reply then
                logctcp(origin, "VERSION")
                send(vchan, "VERSION reply from " .. origin .. ": " .. reply)
            else
                log("Received incomprehensible CTCP VERSION reply from " .. origin .. " on " .. net.name, "debug")
                send(vchan, "Sorry, but I couldn't understand that reply.. You sure it conforms to the RFC?")
            end
            ctcp.rem_active(origin, "version")
        end
    --   SOURCE
    elseif l:match("%\001%s*SOURCE%s*%\001") then
        logctcp(origin, "SOURCE")
        sendNotice(origin, "\001SOURCE git://github.com/staeld/minnet/\001")
    --   TIME
    elseif l:match("%\001%s*TIME%s*%\001") then
        logctcp(origin, "TIME")
        sendNotice(origin, "\001TIME " .. os.date("%F %T %Z") .. "\001")
    --   FINGER
    elseif l:match("%\001%s*FINGER%s*%\001") then
        logctcp(origin, "FINGER")
        sendNotice(origin, "\001FINGER Get your hands off me :|\001")
    --   LICENCE
    elseif l:match("%\001%s*LICENCE%s*%\001") then
        logctcp(origin, "LICENCE")
        sendNotice(origin, "\001LICENCE This program is released under the GNU GPL v3; " ..
            "see http://www.gnu.org/licences/\001")

    --[[ Only for wip debugging
    else
        if not origin or ( origin == "" ) then origin = "UNKNOWN" end
        log("Received unsupported CTCP from " .. origin .. " on " .. net.name .. ", ignoring..", "debug")
    --]]
    end
end

