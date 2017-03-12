persistent_storage = {}

local binser = require("binser.binser")
local file_name = "storage.ser"

local function load_storage()
    if not love.filesystem.isFile(file_name) then
        persistent_storage.storage = {}
    else
        local des = love.filesystem.read(file_name)
        persistent_storage.storage, len = binser.deserialize(des)

        -- for some reason, a table is returned by binser, so we need to get the storage out of the table
        persistent_storage.storage = persistent_storage.storage[1]
    end
    
    print("retrieving:...")
    print_table(persistent_storage.storage)
end 

local function save_storage()
    print("storing:...")
    print_table(persistent_storage.storage)
    love.filesystem.write(file_name, binser.serialize(persistent_storage.storage))
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

    print("setting new variable: "..key)
    if type(value) == "table" then
        print_table(value)
    else
        print(table)
    end

    --- update value
    persistent_storage.storage[key] = value

    --- save storage table on disk immediately
    save_storage()
end