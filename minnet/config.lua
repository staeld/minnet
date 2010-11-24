#!/usr/bin/env lua
-- husken.lua - config file for minnet
-- Copyright Stæld Lakorv, 2010 <staeld@staeld.co.cc>
c   = { net = {} } -- Connection list
ctcp= {}
vchan = "Lakorv"
msg = {
    noargs = "invalid arguments specified. See --help",
    notowner = "Hey, I'm not taking commands from you."
}
owner = {
    uname1 = "a6af798b68",
    uname2 = "~Staeld",
    host = "%.id%.au$"
}
bot = {
    nick  = "Minnet",
    uname = "Minnet",
    rname = "Minnet",
    cmdstring = "^%%",
    nets  = {
        { name = "furnet", addr = "eu.irc.furnet.org", c = { } },
--        { name = "scoutlink", addr = "irc.scoutlink.org", c = { "#test" } }
    },
    cmds  = {
        {
            name    = "test",
            comment = "dummy command",
            rep     = "Go test yourself! Sheesh."
        },
        {
            name    = "be",
            comment = "make me be what you think I should be.",
            action  = function(n, u, chan, m)
                arg = getarg(m)
                if not arg then
                    c.net[n]:sendChat(chan, u.nick .. ": Be what?")
                else
                    if string.match(m, "%s+sad$") then
                        smile = " :("
                    elseif string.match(m, "%s+happy$") then
                        smile = " :D"
                    elseif string.match(m, "%s+angry$") then
                        smile = " >:|"
                    elseif string.match(m, "%s+dumb$") then
                        smile = " :B"
                    else
                        smile = ""
                    end
                    ctcp.action(n, chan, "is " .. arg .. smile)
                end
            end
        },
        {
            name    = "join",
            comment = "make me join a channel.",
            action  = function(n, u, chan, m)
                m = getarg(m)
                if isowner(u) then
                    ctcp.action(n, chan, "flaps off to " .. m)
                    c.net[n]:join(m)
                else
                    c.net[n]:sendChat(chan, msg.notowner)
                end
            end
        },
        {
            name    = "version",
            comment = "ctcp version someone.",
            action  = function(n, u, chan, m)
                arg = getarg(m)
                if not arg then
                    c.net[n]:sendChat(chan, u.nick .. ": Version who?")
                else
                    c.net[n]:send("PRIVMSG " .. arg .. " :\001VERSION\001")
                    vchan = chan
                end
            end
        },
        {
            name    = "quit",
            comment = "shut down bot",
            action  = function(n, u, chan, m)
                if isowner(u) then
                    c.net[n]:sendChat(chan, "Bye.")
                    for i = 1, #c.net do
                        c.net[i]:disconnect("Minnet quitting..")
                    end
                else
                    c.net[n]:sendChat(chan, msg.notowner)
                end
            end
        }
    }
}
for i = 1, #bot.cmds do
    if not bot.cmds.list then
        bot.cmds.list = bot.cmds[i].name
    else
        bot.cmds.list = bot.cmds.list .. ", " .. bot.cmds[i].name
    end
end
table.insert(bot.cmds,{
    name    = "help",
    comment = "help message with cmd list",
    action  = function(n, u, chan, m)
        arg = getarg(m)
        if arg then
            found = false
            for i = 1, #bot.cmds do
                if ( bot.cmds[i].name == arg ) then
                    c.net[n]:sendChat(chan, bot.cmds[i].name .. ": " .. bot.cmds[i].comment)
                    found = true
                    break
                end
            end
            if ( found ~= true ) then
                c.net[n]:sendChat(chan, "I don't know that command!")
            end
        else
            c.net[n]:sendChat(chan, name)
            c.net[n]:sendChat(chan, "Commands: " .. bot.cmds.list .. ", help")
        end
    end
})
-- }}}
-- EOF
