persistent_storage = {}

local binser = require("binser.binser")
local file_name = "storage.ser"

local function load_storage()
    file_info = love.filesystem.getInfo(file_name)
    if file_info == nil or not file_info["type"] == "file" then
        persistent_storage.storage = {}
    else
        local des = love.filesystem.read(file_name)
        persistent_storage.storage, len = binser.deserialize(des)

        -- for some reason, a table is returned by binser, so we need to get the storage out of the table
        persistent_storage.storage = persistent_storage.storage[1]
    end
end 

local function save_storage()
    return love.filesystem.write(file_name, binser.serialize(persistent_storage.storage))
end 

persistent_storage.get = function(key, default)
    load_storage()
    if not persistent_storage.storage[key] then
        return default
    end

    return persistent_storage.storage[key]
end

persistent_storage.set = function(key, value)
    --- refresh storage in case none existed
    load_storage()
    
    --- update value
    persistent_storage.storage[key] = value

    --- save storage table on disk immediately
    return save_storage()
end
