--
-- Created by IntelliJ IDEA.
-- User: arne
-- Date: 10.03.17
-- Time: 14:43
-- To change this template use File | Settings | File Templates.
--

local functions = {}
require("scaling")

-- values are stored in scaling.lua
functions.get_font = function(font_type) return scaling.get("fonts_"..font_type) end

return functions