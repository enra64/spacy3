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
    through_space = 0.5,
    crystal_space = 0.7,
    i_wouldnt = 0.3,
    the_rush = 0.3,
    nebula = 0.7,
    thumper = 0.7
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

background_music.push = function(category)
    -- begin playing another category, pausing the current song
    if #stack > 0 then
        stack[#stack]:pause()
    end
    
    local track_id = random.choose(tracks[category])
    local track = track_objects[track_id]
    track:setVolume(track_volumes[track_id])
    track:setLooping(true)
    
    stack[#stack + 1] = track
    stack[#stack]:play()
    
    -- avoid starting another song of the old category
    if current_timer then
        timer.cancel(next_song)
    end
    -- when this song ends, start another one in the same category
    current_timer = timer.after(stack[#stack]:getDuration(), next_song)
    
    current_category = category
end

background_music.pop = function()
    -- stop, remove old sound from stack
    if #stack > 0 then
        stack[#stack]:stop()
        stack[#stack] = nil
    end
    
    -- resume last sound
    if #stack > 0 then
        stack[#stack]:resume()
    end
end