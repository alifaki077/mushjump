-- Collision detection taken function from http://love2d.org/wiki/BoundingBox.lua
-- -- Returns true if two boxes overlap, false if they don't
-- -- x1,y1 are the left-top coords of the first box, while w1,h1 are its width and height
-- -- x2,y2,w2 & h2 are the same, but for the second box
function collide(ob1, ob2)
    x1, y1, w1, h1 = ob1.x, ob1.y, ob1.w, ob1.h
    x2, y2, w2, h2 = ob2.x, ob2.y, ob2.w, ob2.h
    return x1 < x2+w2 and
           x2 < x1+w1 and
           y1 < y2+h2 and
           y2 < y1+h1
end

FILE = "assets/level-1.lua"

Game = {}

function Game:init()
    local ob = {}

    music = love.audio.newSource("assets/music.mp3", "stream")
    music:setLooping(true)
    music:play()

    ob.bg = love.graphics.newImage("assets/bg.jpg")

    ob.ground = love.graphics.newImage("assets/ground.png")

    font = love.graphics.newFont("assets/font.ttf", 30)
    love.graphics.setFont(font)

--    love.window.setIcon(love.graphics.newImage("assets/mush.png"))

    self.__index = self
    return setmetatable(ob, self)
end

function Game:_load()
    self.level = love.filesystem.load(FILE)()
    self.pause = self.level.meta.pause
    self.info = self.level.meta.info

    self.blocks = {}

    for _, ob in ipairs(self.level.blocks) do
        block = Block:init(ob.x, ob.y)
        table.insert(self.blocks, block)
    end

    self.player = Player:init(20, 200, self)


    end

function Game:draw()
    love.graphics.setColor(255, 255, 255)

    love.graphics.draw(self.bg, 0, 0)
    self.player:draw()


    for i = 0, 33 do
        love.graphics.draw(self.ground, i * 31, 200 + 32)
    end


    -- love.graphics.rectangle("fill", 0, 200 + 32, 1200, 5)

    for _, ob in ipairs(self.blocks) do
        ob:draw()
    end


    love.graphics.setColor(0, 0, 0)
    love.graphics.print(self.info, 350, 300)
end

function Game:update(dt)
    for _, ob in ipairs(self.blocks) do
        ob:update(dt)
    end

    self.player:update(dt, self.pause)

    for _, ob in ipairs(self.blocks) do
        if collide(self.player, ob) then
            self:_load()
        end
    end

    if self.player.x > 1000 then
        FILE = self.level.meta._next
        self:_load()
    end
end

function Game:keypressed(key)

    if key == "space" and self.player.yv == 0 then

        self.pause = false
        self.player.yv = -self.player.oyv
    end
end

Player = {}

function Player:init(x, y)
    local ob = {}

    ob.x = x
    ob.y = y
    ob.w = 32 
    ob.h = 32
    ob.xv = 300
    ob.yv = 0
    ob.oyv = 300
    ob.g = 600

    self.img = love.graphics.newImage("assets/mush.png")
    self.__index = self
    return setmetatable(ob, self)
end

function Player:draw()
    love.graphics.draw(self.img, self.x, self.y)
end

function Player:update(dt, pause)

    if pause then
        return
    end

    self.x = self.x + self.xv * dt

    if self.yv ~= 0 then
        self.y = self.y + self.yv * dt
        self.yv = self.yv + self.g * dt
    end

    if self.y > 200 then
        self.y = 200
        self.yv = 0
    end
end

Block = {}

function Block:init(x, y)
    local ob = {}

    ob.x = x
    ob.y = y
    ob.w = 32
    ob.h = 32

    ob.img = love.graphics.newImage("assets/block.png")

    self.__index = self
    return setmetatable(ob, self)
end

function Block:draw()
    -- love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
    love.graphics.draw(self.img, self.x, self.y)
end

function Block:update(dt)
end

function love.load()
    game = Game:init()
    game:_load()
end

function love.draw()
    game:draw()

end

function love.update(dt)
    game:update(dt)
end

function love.keypressed(key)
    if key == "escape" then
        love.event.push("quit")
    end

    game:keypressed(key)
end
