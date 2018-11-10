require("common")
local timer = require("hump.timer").new()

background_music = {}

local stack = {}
local current_category
local current_timer
local DEBUG = false

local track_objects = {
    through_space = love.audio.newSource("tracks/through_space.ogg", "stream"),
    crystal_space = love.audio.newSource("tracks/crystal_space.ogg", "stream"),
    i_wouldnt = love.audio.newSource("tracks/i_wouldnt.mp3", "stream"),
    the_rush = love.audio.newSource("tracks/the_rush.mp3", "stream"),
    nebula = love.audio.newSource("tracks/nebula.ogg", "stream")
}

local track_volumes = {
    through_space = 0.4,
    crystal_space = 0.6,
    i_wouldnt = 0.25,
    the_rush = 0.25,
    nebula = 0.6
}

local tracks = {
    store = {"through_space", "crystal_space"},
    ingame = {"i_wouldnt", "the_rush"},
    killscreen = {"nebula"},
    main_menu = {"through_space", "crystal_space"}
}

local function next_song()
    stack[#stack]:stop()
    background_music.pop()
    background_music.push(current_category)
end

local function get_track_object(category)
    local track_id = random.choose(tracks[category])
    local track = track_objects[track_id]
    
    local song_object = {
        track = track,
        category = category,
        track_timer = timer:after(track:getDuration(), next_song),
        track_id = track_id,
        volume = 0.2,
        track_last_position = nil,
        max_volume = track_volumes[track_id],
        remaining_time = nil,
        -- pause the track, update the remaining duration, cancel the timer
        pause = function(tbl)
            tbl.track:pause()
            tbl.remaining_time = timer:remaining_time(tbl.track_timer)
            tbl.track_last_position = tbl.track:tell()
            if DEBUG then print("pause "..tbl.track_id.."remaining: "..tbl.remaining_time..", or "..tbl.track:tell("seconds")) end
            timer:cancel(tbl.track_timer)
        end,
        resume = function(tbl)
            tbl.track = track_objects[track_id]
            tbl.track:seek(tbl.track_last_position)
            tbl.track:play()
            if DEBUG then print("resuming "..tbl.track_id.." at volume "..tbl.track:getVolume().." is playing? "..tostring(tbl.track:isPlaying())) end
            tbl.track_timer = timer:after(tbl.remaining_time, next_song)
        end,
        play = function(tbl)
            if DEBUG then print("start "..tbl.track_id) end
            tbl.track:stop()
            tbl.track:play()
        end,
        -- abort play-next-song timer, stop playing track
        stop = function(tbl)
            if DEBUG then print("stopping "..tbl.track_id) end
            tbl.track:stop()
            timer:cancel(tbl.track_timer)
            timer:cancel(tbl.volume_in_tweener)
            timer:cancel(tbl.volume_out_tween_timer)
            timer:cancel(tbl.volume_updater)
        end
    }

    -- forward unknown calls to the source object (song_object.track...)
    setmetatable(song_object, {__index = function(_, req_func) return function(song_obj, ...) track[req_func](track, ...) end end})

    song_object:setVolume(song_object.volume)
    song_object:setLooping(false)

    song_object.volume_in_tweener = timer:tween(40, song_object, {volume = 1}, 'out-quad')
    song_object.volume_out_tween_timer = timer:after(track:getDuration() - 20, function() timer:tween(20, song_object, {volume = 0.1}, 'in-quart') end)
    song_object.volume_updater = timer:every(0.1, 
        function() 
            song_object:setVolume(song_object.volume)
            return song_object.volume < song_object.max_volume -- stop updater at max volume
        end
    )
    
    return song_object
end

background_music.update = function(dt)
    timer:update(dt)
end

background_music.push = function(category)
    local track = get_track_object(category)
    local track_id = track.track_id

    if DEBUG then print("pushing "..track_id) end

    -- begin playing another category, pausing the current song
    if #stack > 0 then
        stack[#stack]:pause()
    end

    track:play()
    
    stack[#stack + 1] = track
    current_category = category
end

background_music.pop = function()

    -- stop, remove old sound from stack; timer will be stopped by stop
    if #stack > 0 then
        stack[#stack]:stop()
        stack[#stack] = nil
    end

    -- resume last sound
    if #stack > 0 then
        stack[#stack]:resume()
        current_category = stack[#stack].category
    end
end
