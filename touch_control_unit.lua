local touch_control = {}

local function set_dpad_position(control, x, y)
    --- set control knob position
    control.touch_controls.dpad.x = control.dpad_background.x + x - control.touch_controls.dpad.width / 2 + control.dpad_background.width / 2
    control.touch_controls.dpad.y = control.dpad_background.y + y - control.touch_controls.dpad.height / 2 + control.dpad_background.height / 2

    --- limit max movement
    if control.touch_controls.dpad.y < control.dpad_background.y then
        control.touch_controls.dpad.y = control.dpad_background.y
    end
    if control.touch_controls.dpad.y > control.dpad_background.bottom_border then
        control.touch_controls.dpad.y = control.dpad_background.bottom_border - control.touch_controls.dpad.height
    end
    if control.touch_controls.dpad.x < 0 then
        control.touch_controls.dpad.x = 0
    end
    if control.touch_controls.dpad.x + control.touch_controls.dpad.width > control.dpad_background.right_border then
        control.touch_controls.dpad.x = control.dpad_background.right_border - control.touch_controls.dpad.width
    end
end

local function handle_dpad_touch(control, x, y)
    --- position of touch relative to dpad background, negative if the touch is left of/above center
    x = x - control.dpad_background.x - control.dpad_background.width / 2
    y = y - control.dpad_background.y - control.dpad_background.height / 2

    --- scale to dt, update control state
    control.state.x = math.min((x / control.dpad_background.width) * 0.04, .05)
    control.state.y = math.min((y / control.dpad_background.height) * 0.04, .05)

    --- set control knob position
    set_dpad_position(control, x, y)
end

touch_control.new = function(enable_move_pad)
    local ctrl = {}

    --- touch only stuff
    ctrl.touch_collider = require("hc").new()
    ctrl.touch_controls = {}
    ctrl.dpad_background = {}
    ctrl.store_button = {}
    ctrl.enable_move_pad = true

    ctrl.state = {x = 0, y = 0, button_a_pressed = false, button_b_pressed = false, button_escape_pressed = false, button_store_pressed = false}

    ctrl.type = "touch"

    -- whether or not this touch control should draw and use the move pad
    ctrl.enable_move_pad = enable_move_pad

    -- subscribe to rumble events
    signal.register("weapon_fired", function()
        love.system.vibrate(0.3)
    end)

    local control_textures = {
        button_a = love.graphics.newImage("img/touch_controls/button_a.png"),
        button_b = love.graphics.newImage("img/touch_controls/button_b.png"),
        button_escape = love.graphics.newImage("img/touch_controls/button_escape.png"),
        button_store = love.graphics.newImage("img/touch_controls/button_store.png")
    }

    if enable_move_pad then
        ctrl.dpad_background.texture = love.graphics.newImage("img/touch_controls/dpad_background.png")
        ctrl.dpad_background.x = 50
        ctrl.dpad_background.y = love.graphics.getHeight() - ctrl.dpad_background.texture:getHeight() - 50
        ctrl.dpad_background.width = ctrl.dpad_background.texture:getWidth()
        ctrl.dpad_background.height = ctrl.dpad_background.texture:getHeight()
        ctrl.dpad_background.opacity = 100
        ctrl.dpad_background.right_border = ctrl.dpad_background.width + ctrl.dpad_background.x
        ctrl.dpad_background.bottom_border = ctrl.dpad_background.height + ctrl.dpad_background.y
        ctrl.dpad_background.shape = ctrl.touch_collider:rectangle(
            ctrl.dpad_background.x,
            ctrl.dpad_background.y,
            ctrl.dpad_background.width,
            ctrl.dpad_background.height
        )
        ctrl.dpad_background.shape.control_type = "dpad"

        control_textures.dpad = love.graphics.newImage("img/touch_controls/dpad_knob.png")
    end

    for control_type, texture in pairs(control_textures) do
        local new_control = {}
        new_control.touch_id = nil
        new_control.texture = texture
        new_control.width = new_control.texture:getWidth()
        new_control.height = new_control.texture:getHeight()
        new_control.opacity = 150

        ctrl.touch_controls[control_type] = new_control

        if control_type == "dpad" then
            set_dpad_position(ctrl, 0, 0)
        elseif control_type == "button_a" then
            new_control.x = love.graphics.getWidth() - 2 * new_control.width
            new_control.y = love.graphics.getHeight() - new_control.height
        elseif control_type == "button_b" then
            new_control.x = love.graphics.getWidth() - new_control.width
            new_control.y = love.graphics.getHeight() - 2 * new_control.height
        elseif control_type == "button_escape" then
            new_control.x = love.graphics.getWidth() - new_control.width
            new_control.y = 0
        elseif control_type == "button_store" then
            -- note: this is, sadly, highly dependent on not changing the above formulas because pairs is not guaranteed to iterate in input order
            new_control.x = love.graphics.getWidth() - 2 * control_textures["button_a"]:getHeight()
            new_control.y = love.graphics.getHeight() - 2 * control_textures["button_b"]:getHeight()
        else
            print("unknown control type")
        end

        new_control.shape = ctrl.touch_collider:rectangle(new_control.x, new_control.y, new_control.width, new_control.height)
        new_control.shape.control_type = control_type
    end
    ctrl.touchmoved = function(control, id, x, y)
        if control.enable_move_pad and id == control.touch_controls.dpad.touch_id then
            handle_dpad_touch(control, x, y)
        end
    end
    ctrl.touchreleased = function(control, id)
        if id == control.touch_controls.button_a.touch_id then
            control.state.button_a_pressed = false
            control.touch_controls.button_a.touch_id = nil
        elseif id == control.touch_controls.button_b.touch_id then
            control.state.button_b_pressed = false
            control.touch_controls.button_b.touch_id = nil
        elseif id == control.touch_controls.button_escape.touch_id then
            control.state.button_escape_pressed = false
            control.touch_controls.button_escape.touch_id = nil
        elseif id == control.touch_controls.button_store.touch_id then
            control.state.button_store_pressed = false
            control.store_button.touch_id = nil
        elseif control.enable_move_pad and id == control.touch_controls.dpad.touch_id then
            control.state.x = 0
            control.state.y = 0
            set_dpad_position(control, 0, 0)
            control.touch_controls.dpad.touch_id = nil
        end
    end
    ctrl.touchpressed = function(control, id, x, y)
        local touch_point = control.touch_collider:point(x, y)

        --- handle button clicks
        for shape, _ in pairs(control.touch_collider:collisions(touch_point)) do
            --- retrieve the control type stored in the collision shape
            local ctrl_type = shape.control_type

            --- update stored touch id
            control.touch_controls[ctrl_type].touch_id = id

            --- update control state
            if ctrl_type == "button_a" then
                control.state.button_a_pressed = true
            elseif ctrl_type == "button_b" then
                control.state.button_b_pressed = true
            elseif ctrl_type == "button_escape" then
                control.state.button_escape_pressed = true
            elseif ctrl_type == "button_store" then
                control.state.button_store_pressed = true
            end
        end
    end
    ctrl.draw = function(control, store_triggered) 
        love.graphics.setColor(255, 255, 255, control.dpad_background.opacity)
        love.graphics.draw(control.dpad_background.texture, control.dpad_background.x, control.dpad_background.y)
        
        for control_type, control in pairs(control.touch_controls) do
            local opacity_touch = control.opacity
            -- increase opacity for pressed buttons
            if control.touch_id ~= nil then
                opacity_touch = 255
            end
            
            -- hide the store button if it is not triggered
            if control_type == "button_store" and not store_triggered then
                opacity_touch = 0
            end
            
            love.graphics.setColor(255, 255, 255, opacity_touch)
            love.graphics.draw(control.texture, control.x, control.y)
        end
        love.graphics.setColor(255, 255, 255, 255)
    end
    ctrl.update = function(control, dt) end
    return ctrl
end

return touch_control