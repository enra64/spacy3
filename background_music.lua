require("common")
local timer = require("hump.timer")

background_music = {}

local stack = {}
local current_category
local current_timer

local track_objects = {
    through_space = love.audio.newSource("tracks/through_space.ogg"),
    crystal_space = love.audio.newSource("tracks/crystal_space.ogg"),
    i_wouldnt = love.audio.newSource("tracks/i_wouldnt.mp3"),
    the_rush = love.audio.newSource("tracks/the_rush.mp3"),
    nebula = love.audio.newSource("tracks/nebula.ogg"),
    thumper = love.audio.newSource("tracks/thumper.mp3")
}

local track_volumes = {
    through_space = 0.4,
    crystal_space = 0.6,
    i_wouldnt = 0.25,
    the_rush = 0.25,
    nebula = 0.6,
    thumper = 0.6
}

local tracks = {
    store = {"through_space", "crystal_space"},
    ingame = {"i_wouldnt", "the_rush", "thumper"},
    killscreen = {"nebula"},
    main_menu = {"through_space", "crystal_space"}
}

local function next_song()
    background_music.pop()
    background_music.push(current_category)
end

local function get_track_object(category)
    local track_id = random.choose(tracks[category])
    local track = track_objects[track_id]
    
    local song_object = {
        track = track,
        category = category,
        track_timer = timer.after(track:getDuration(), next_song),
        track_id = track_id,
        -- abort play-next-song timer, stop playing track
        stop = function(tbl) track:stop(); timer.cancel(tbl.track_timer) end
    }
    
    -- forward unknown calls to the source object (song_object.track...)
    setmetatable(song_object, {__index = function(_, req_func) return function(song_obj, ...) track[req_func](track, ...) end end})
    
    return song_object
end

background_music.push = function(category)
    -- begin playing another category, pausing the current song
    if #stack > 0 then
        stack[#stack]:pause()
    end
    
    local track_id = random.choose(tracks[category])
    local track = get_track_object(category)
        
    print("pushing "..track_id.." from "..category)
    print(debug.traceback())
    
    track:setVolume(track_volumes[track_id])
    track:setLooping(false)
    track:play()
    
    stack[#stack + 1] = track
    current_category = category
end

background_music.pop = function()
    -- stop, remove old sound from stack
    if #stack > 0 then
        stack[#stack]:stop()
        stack[#stack] = nil
    end
    
    print("popping")
    print(debug.traceback())
    
    -- resume last sound
    if #stack > 0 then
        stack[#stack]:resume()
    end
end