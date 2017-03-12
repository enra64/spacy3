--
-- Created by IntelliJ IDEA.
-- User: arne
-- Date: 22.02.17
-- Time: 18:35
-- To change this template use File | Settings | File Templates.
--
gamestate = require "hump.gamestate"
require("persistent_storage")

--- remove annoying 0 parameter in draw calls
NO_ROTATION = 0

--- overwrite luas "dofile" to work on android
function dofile(file)
    return love.filesystem.load(file)()
end

--http://stackoverflow.com/a/15706820
function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

-- https://coronalabs.com/blog/2014/09/02/tutorial-printing-table-contents/
function print_table( t )  
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            print(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        print(indent.."["..pos.."] => "..tostring(t).." {")
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        print(indent..string.rep(" ",string.len(pos)+6).."}")
                    elseif (type(val)=="string") then
                        print(indent.."["..pos..'] => "'..val..'"')
                    else
                        print(indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                print(indent..tostring(t))
            end
        end
    end
    if (type(t)=="table") then
        print(tostring(t).." {")
        sub_print_r(t,"  ")
        print("}")
    else
        sub_print_r(t,"  ")
    end
    print()
end

function math.clamp(val, lower, upper)
    assert(val and lower and upper, "missing argument for math.clamp")
    if lower > upper then lower, upper = upper, lower end -- swap if boundaries supplied the wrong way
    return math.max(lower, math.min(upper, val))
end

function math.scale_from_to(from, to)
    return to / from
end

function on_pause_button_clicked(button_text)
    -- for when i get confused: print(function_location() .. ": " .. button_text)
    if (button_text == "new game") then
        --- push game on gamestate stack
        gamestate.push(dofile("game_gamestate.lua"))
    elseif (button_text == "view highscores") then
        gamestate.push(dofile("highscore_view.lua"))
    elseif button_text == "quit" then
        love.event.quit()
    end
end

local function highscore_dialog_finished(result, entered_text, score)
    local highscores = persistent_storage.get("highscores", {})
    
    -- insert new table with name and score in highscores table
    table.insert(highscores, {entered_text, score})

    -- store sorted highscores
    persistent_storage.set("highscores", highscores)

    -- also store lowest value
    persistent_storage.set("lowest_highscore", highscores[#highscores])

    -- pop highscore entering dialog
    gamestate.pop()
end     

function function_location()
    local w = debug.getinfo(2, "S")
    return w.short_src .. ":" .. w.linedefined
end

function player_wants_to_quit(score)
    local quit_confirmation = dofile("menu.lua")
    gamestate.push(quit_confirmation)
    quit_confirmation:add_button("really quit")
    quit_confirmation:add_button("abort quitting")
    quit_confirmation:set_title("confirm quitting")
    quit_confirmation.on_button_clicked = function(button_txt)
        if button_txt == "really quit" then
            love.event.push("quit")
        elseif button_txt == "abort quitting" then
            gamestate.pop()
        end
    end
end

function player_wants_back_to_main(score)
    local quit_confirmation = dofile("menu.lua")
    gamestate.push(quit_confirmation)
    quit_confirmation:add_button("really back to main")
    quit_confirmation:add_button("abort going to main")
    quit_confirmation:set_title("confirm back to main menu")
    quit_confirmation.on_button_clicked = function(button_txt)
        if button_txt == "really back to main" then
            gamestate.pop() -- pop warning
            gamestate.pop() -- pop game
        elseif button_txt == "abort going to main" then
            gamestate.pop()
        end
    end
end

function player_died(score)
    local quit_confirmation = dofile("menu.lua")
    gamestate.push(quit_confirmation)
    quit_confirmation:add_button("back to main")

    if score > persistent_storage.get("lowest_highscore", {"", 0})[2] then
        quit_confirmation:add_button("enter highscore")
    end 

    quit_confirmation:add_button("quit")
    quit_confirmation:set_title("you made " .. score .. " points.\nyou also horifically failed your colony.")
    quit_confirmation.on_button_clicked = function(button_txt)
        if button_txt == "back to main" then
            gamestate.pop() -- pop warning
            gamestate.pop() -- pop game
        elseif button_txt == "enter highscore" then
            gamestate.pop() -- pop warning
            gamestate.pop() -- pop game

            -- show highscore entry thingy
            local highscore_entry = dofile("highscore_entry.lua")
            gamestate.push(highscore_entry)
            highscore_entry:set_title("enter your score of "..score.." points")
            highscore_entry:set_score(score)
            highscore_entry:set_callback(highscore_dialog_finished)
        elseif button_txt == "quit" then
            love.event.push("quit")
        end
    end
end

function love.load(arg)
    --- enable zerobrane ide debugging
    if arg[#arg] == "-debug" then require("mobdebug").start() end
    
    --- unshittify random numbers
    math.randomseed(os.time())

    --- set some window size
    love.window.setMode(1366, 768)

    --love.window.setMode(1920, 1080)
    --love.window.setFullscreen(true)

    --- initialise all fonts
    require("font_config").init()

    --- register event callbacks
    gamestate.registerEvents()

    --- push main menu onto stack
    local main_menu = dofile("menu.lua")
    gamestate.push(main_menu)

    --- configure main menu
    main_menu:add_button("new game")
    main_menu:add_button("view highscores")
    main_menu:add_button("quit")
    main_menu:set_title("main menu")

    --- set main menu callback
    main_menu.on_button_clicked = on_pause_button_clicked
end