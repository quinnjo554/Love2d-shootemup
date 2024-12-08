
function setFullscreen(fullscreen)
    if fullscreen then
        love.window.setMode(1920, 1080, { fullscreen = true })
    else
        love.window.setMode(800, 600, { fullscreen = false })
    end
end

function drawBackground()
    local windowWidth, windowHeight = love.graphics.getDimensions()
    local offsetX = (windowWidth - backgroundWidth * scale) / 2
    local offsetY = (windowHeight - backgroundHeight * scale) / 2
    love.graphics.draw(background, offsetX, offsetY, 0, scale, scale)
end
