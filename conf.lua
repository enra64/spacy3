--
-- Created by IntelliJ IDEA.
-- User: arne
-- Date: 21.02.17
-- Time: 17:24
-- To change this template use File | Settings | File Templates.
--

function love.conf(def_conf)
    def_conf.identity = spacy3
    def_conf.title = "spacy3"
    def_conf.window.title = "spacy3"
    def_conf.window.icon = "img/icon.png"

    def_conf.modules.physics = false

    io.stdout:setvbuf("no")
end