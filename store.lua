require("player_ship_upgrade_state")
require("difficulty_handler")

store = {}

local vertical_margin = 20
local item_count = 0
local credits
local click_sound = love.audio.newSource("sounds/button_click.ogg")

function store:update()
    
end

function store:create_buttons()
    -- recalculate menu dimensions
    local menu_width =  love.graphics.getWidth()  * 0.7
    local menu_height = love.graphics.getHeight() * 0.7
    local menu_x =      love.graphics.getWidth()  * 0.15
    local menu_y =      love.graphics.getHeight() * 0.1
    
    -- determine required scaling for the button background texture
    self.button_rectangle_x_scale = menu_width / self.button_texture:getWidth()
    self.button_rectangle_y_scale = math.scale_from_to(
        self.button_texture:getHeight(),
        (menu_height - vertical_margin * item_count) / item_count
    )

    --- clear collider so updating buttons by calling create_buttons again doesnt fuck up
    self.hc_world = require("hc").new()

    --- empty rectangle table
    self.buttons = {}

    local i = 1
    local lowest_button_position
    for key, item in pairs(self.items) do
        -- update item state
        item.has_reached_max_state = player_ship_upgrade_state.has_max(key)
        
        -- create table for this button
        self.buttons[key] = {}
        -- create button background rectangles
        local button_rect = {}
        button_rect.width = menu_width
        button_rect.height = self.button_rectangle_y_scale * self.button_texture:getHeight()
        button_rect.x = menu_x
        button_rect.y = 
            menu_y + 
            ((i - 1) * (button_rect.height + vertical_margin)) + 
            button_rect.height / 5
        
        button_rect.collider = self.hc_world:rectangle(button_rect.x, button_rect.y, button_rect.width, button_rect.height)
        button_rect.collider.item_key = key
                
        lowest_button_position = button_rect.y + button_rect.height
            
        self.buttons[key].background = button_rect
        
        -- create image rectangle
        local image_rect = {}
        image_rect.height = button_rect.height * 0.9
        image_rect.width = image_rect.height
        image_rect.x = button_rect.x + button_rect.height * 0.05
        image_rect.y = button_rect.y + button_rect.height * 0.05
        self.buttons[key].image = image_rect
        
        -- create description rectangle
        local desc_rect = {}
        desc_rect.width = button_rect.width - 100 - image_rect.width
        desc_rect.height = 0.75 * image_rect.height
        desc_rect.x = image_rect.x + image_rect.width + image_rect.height * 0.05
        desc_rect.y = image_rect.y + 0.25 * image_rect.height
        self.buttons[key].description = desc_rect
        
        -- create title text rectangle
        local title_rect = {}
        title_rect.x = desc_rect.x
        title_rect.y = image_rect.y
        title_rect.width = desc_rect.width * 0.7
        title_rect.height = 0.25 * image_rect.height
        self.buttons[key].title = title_rect
        
        -- create price text rectangle
        local price_rect = {}
        price_rect.x = title_rect.x + title_rect.width
        price_rect.y = title_rect.y
        price_rect.width = desc_rect.width * 0.3
        price_rect.height = title_rect.height
        self.buttons[key].price = price_rect
        
        i = i + 1
    end
    
    --- add current credits display
    local title_font = self.font_config.get_font("store_title")
    self.current_credits = {}
    self.current_credits.x = menu_x + menu_width - title_font:getWidth("$400000")
    self.current_credits.y = 15 -- hardcoded, see title
    self.current_credits.width = title_font:getWidth("$400000")
    self.current_credits.height = title_font:getHeight()

    --- add exit button
    self.exit_button = {}
    self.exit_button.y = lowest_button_position + vertical_margin
    self.exit_button.x = menu_x + menu_width / 4
    self.exit_button.width = menu_width / 2
    self.exit_button.height = 40
    self.exit_button.collider = self.hc_world:rectangle(
        self.exit_button.x,
        self.exit_button.y,
        self.exit_button.width,
        self.exit_button.height
    )
    self.exit_button.collider.item_key = "exit_button"
end

function store:draw()
    -- clear to black background
    love.graphics.clear()
    
    --- draw title in white
    love.graphics.setFont(self.font_config.get_font("menu_title"))
    love.graphics.setColor(255, 255, 255)
    love.graphics.printf(self.title,
        0,
        15,
        love.graphics.getWidth(),
        "center",
        0, 
        1)
    
    -- draw current player credits
    love.graphics.printf("$"..credits,
        self.current_credits.x,
        self.current_credits.y,
        self.current_credits.width,
        "right",
        0,
        1)

    --- draw buttons
    for key, button in pairs(self.buttons) do
        -- draw image and background with full colors
        love.graphics.setColor(255, 255, 255)
        
        -- draw background first
        love.graphics.draw(self.button_texture, button.background.x, button.background.y, NO_ROTATION, self.button_rectangle_x_scale, self.button_rectangle_y_scale)
        
        -- retrieve the item corresponding to this button
        local item = self.items[key]
        
        -- draw image
        local image
        if item.has_reached_max_state then
            image = love.graphics.newImage("img/store_no_further_upgrade.png")
        else
            image = item.images[item.state + 1]
        end
        
        local scale
        if image:getWidth() > image:getHeight() then
            scale = math.scale_from_to(image:getWidth(), button.image.width)
        else
            scale = math.scale_from_to(image:getHeight(), button.image.height)
        end
        
        local w, h = image:getWidth() * scale, image:getHeight() * scale
        local x = button.image.x + (button.image.width - w) / 2
        local y = button.image.y + (button.image.height - h) / 2
        
        love.graphics.draw(
            image,
            x,
            y,
            NO_ROTATION, 
            scale
        )
        
        -- draw all text in black
        love.graphics.setColor(0, 0, 0)
        
        -- draw title 
        love.graphics.setFont(self.font_config.get_font("store_title"))
        love.graphics.printf(item.title, button.title.x, button.title.y, button.title.width, 'left')
        
        -- draw price
        local price_text
        if item.has_reached_max_state then
            price_text = "max"
        else
            -- red only if not at max, and not enough credits
            if credits < item.prices[item.state] then
                love.graphics.setColor(150, 0, 0)
            end
            price_text = item.prices[item.state]
        end
        
        -- draw price
        love.graphics.printf(
            price_text, 
            button.price.x, 
            button.price.y, 
            button.price.width, 
            'right')
        
        love.graphics.setColor(0, 0, 0)
        
        -- draw description
        love.graphics.setFont(self.font_config.get_font("store_description"))
        love.graphics.printf(item.description, button.description.x, button.description.y, button.description.width)
    end
    
    
    --- draw exit button...
    love.graphics.setColor(255, 255, 255)
    
    -- draw exit button texture
    love.graphics.draw(
        self.button_texture, 
        self.exit_button.x,
        self.exit_button.y, 
        NO_ROTATION, 
        math.scale_from_to(self.button_texture:getWidth(), self.exit_button.width),
        math.scale_from_to(self.button_texture:getHeight(), self.exit_button.height))
    
    love.graphics.setColor(0, 0, 0)
    local font = self.font_config.get_font("store_description")
    love.graphics.setFont(font)
    
    -- print "exit"
    love.graphics.printf(
        "exit", 
        self.exit_button.x,
        self.exit_button.y + (self.exit_button.height - font:getHeight()) / 2,
        self.exit_button.width,
        "center"
    )
    
    -- reset font color
    love.graphics.setColor(255, 255, 255)
end

function store:init()
    click_sound:setVolume(1.5)
    self.button_texture = love.graphics.newImage("img/ui/button_texture.png")
    self.font_config = require("font_config")
    self.title = "store"
    self.items = {
        heat_diffuser = {
            title = "Heat diffuser",
            description = "An upgraded diffuser can dissipate the heat generated by your laser more quickly, leading to less cooldown time.",
            images = {
                love.graphics.newImage("img/cooling_fan.png"),
                love.graphics.newImage("img/cooling_fan.png"),
                love.graphics.newImage("img/compressed_air.png")
            },
            prices = difficulty.get("heat_diffuser_upgrade_costs"),
            state = player_ship_upgrade_state.get_state("heat_diffuser"),
        },
        ship_hull = {
            title = "Hull upgrade",
            description = "An upgraded hull withstands some impacts from enemy ships or asteroids.",
            images = {
                love.graphics.newImage("img/player_ships/upgrade_0/main.png"),
                love.graphics.newImage("img/player_ships/upgrade_1/main.png"),
                love.graphics.newImage("img/player_ships/upgrade_2/main.png")
            },
            prices = difficulty.get("hull_upgrade_costs"),
            state = player_ship_upgrade_state.get_state("ship_hull")
        }
    }
    
    -- count the number of items in a table - thanks, lua...
    for _, _ in pairs(self.items) do
        item_count = item_count + 1
    end
    
    self:create_buttons()
end

function store:enter()
    credits = player_ship_upgrade_state.get_credits()
    love.graphics.setFont(self.font_config.get_font("menu"))
    background_music.push("store")
end

function store:leave()
    background_music.pop()
end

function store:mousepressed(x, y)
    local mouse_point = self.hc_world:point(x, y) 
    for button, _ in pairs(self.hc_world:collisions(mouse_point)) do
        local item_key = button.item_key
        click_sound:play()
        if item_key == "exit_button" then
            gamestate.pop()
        else
            player_ship_upgrade_state.upgrade(item_key)
            self.items[item_key].state = player_ship_upgrade_state.get_state(item_key)
            self:create_buttons()
            credits = player_ship_upgrade_state.get_credits()
        end
    end
    self.hc_world:remove(mouse_point)
end

function store:keypressed(key)
    if key == "escape" then
        gamestate.pop()
    end
end

return store