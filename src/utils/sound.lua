SoundsPlay = {}
SoundsPlay.__index = SoundsPlay

function SoundsPlay:new()
    local self = setmetatable({}, SoundsPlay)
    self.src = {
        coinSound = love.audio.newSource("assets/sounds/pudding.mp3", "static"),
        gameStart = love.audio.newSource("assets/sounds/game-start.mp3", "static"),
        slimeWalk = love.audio.newSource("assets/sounds/slimewalk.mp3", "static"),
        gameOver = love.audio.newSource("assets/sounds/game_over.mp3", "static")
    }
    return self

end

return SoundsPlay
