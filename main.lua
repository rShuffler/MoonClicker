-- Луна-кликер с системой скинов и достижениями

local moonImage
local moonScale = 0.5
local clicks = 0
local particles = {}
local upgradeCost = 10
local pointsPerClick = 1

-- Для пульсации
local scalePulse = 0
local pulseActive = false
local pulseDuration = 0.3
local pulseTime = 0

-- Достижения
local achievements = {}
local achievementUnlocked = false
local achievementMessage = ""
local achievementTimer = 0
local achievementDisplayDuration = 3
local achievementX = 0
local achievementTargetX = 0

-- Скины: добавлены пути к скинам
local currentSkinIndex = 1
local skinChangeTimer = 0
local skinChangeInterval = 30 * 60 -- 30 минут в секундах
local availableSkins = {
    "skin1.png",
    "skin2.png",
    "skin3.png",
    "skin4.png"
}

-- Автоклик
local autoClickEnabled = false
local autoClickRate = 10
local autoClickTimer = 0

function love.load()
    -- Загрузка первого скина
    moonImage = love.graphics.newImage(availableSkins[currentSkinIndex])
    love.window.setTitle("Moon Clicker")

    -- Настраиваем достижения
    achievements = {
        { clicks = 100, name = "100 Clicks!" },
        { clicks = 500, name = "500 Clicks!" },
        { clicks = 1000, name = "Auto Click Unlocked!" }
    }

    -- Инициализация позиции для анимации достижений
    achievementX = love.graphics.getWidth()
    achievementTargetX = love.graphics.getWidth() - 250
end

function love.update(dt)
    -- Анимация пульсации
    if pulseActive then
        pulseTime = pulseTime + dt
        if pulseTime >= pulseDuration then
            pulseActive = false
            pulseTime = 0
            scalePulse = 0
        else
            scalePulse = math.sin((pulseTime / pulseDuration) * math.pi) * 0.1
        end
    end

    -- Таймер смены скинов
    skinChangeTimer = skinChangeTimer + dt
    if skinChangeTimer >= skinChangeInterval then
        skinChangeTimer = 0
        currentSkinIndex = math.random(1, #availableSkins)
        moonImage = love.graphics.newImage(availableSkins[currentSkinIndex])
    end

    -- Проверка достижений
    for _, achievement in ipairs(achievements) do
        if clicks >= achievement.clicks and not achievement.unlocked then
            achievement.unlocked = true
            achievementUnlocked = true
            achievementMessage = achievement.name
            achievementTimer = achievementDisplayDuration
            achievementX = love.graphics.getWidth()
            if achievement.clicks == 1000 then
                autoClickEnabled = true
            end
        end
    end

    -- Таймер уведомления достижений
    if achievementUnlocked then
        achievementTimer = achievementTimer - dt
        if achievementTimer <= 0 then
            achievementUnlocked = false
        end
    end

    -- Анимация достижения
    if achievementUnlocked and achievementX > achievementTargetX then
        achievementX = achievementX - 300 * dt
    end

    -- Автоклик
    if autoClickEnabled then
        autoClickTimer = autoClickTimer + dt
        if autoClickTimer >= 1 / autoClickRate then
            clicks = clicks + pointsPerClick
            autoClickTimer = 0
        end
    end

    -- Обновляем частицы
    for i = #particles, 1, -1 do
        local particle = particles[i]
        particle.x = particle.x + particle.dx * dt
        particle.y = particle.y + particle.dy * dt
        particle.life = particle.life - dt
        if particle.life <= 0 then
            table.remove(particles, i)
        end
    end
end

function love.draw()
    -- Луна с пульсацией
    local moonWidth = moonImage:getWidth() * (moonScale + scalePulse)
    local moonHeight = moonImage:getHeight() * (moonScale + scalePulse)
    local moonX = love.graphics.getWidth() / 2 - moonWidth / 2
    local moonY = love.graphics.getHeight() / 2 - moonHeight / 2
    love.graphics.draw(moonImage, moonX, moonY, 0, moonScale + scalePulse, moonScale + scalePulse)

    -- Частицы
    for _, particle in ipairs(particles) do
        love.graphics.setColor(1, 1, 1, particle.life)
        love.graphics.circle("fill", particle.x, particle.y, 3)
    end
    love.graphics.setColor(1, 1, 1, 1)

    -- Счётчик кликов
    love.graphics.print("Clicks: " .. clicks, 10, 10)

    -- Кнопка улучшения
    love.graphics.rectangle("fill", 10, love.graphics.getHeight() - 60, 120, 50)
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.print("Upgrade (" .. upgradeCost .. ")", 20, love.graphics.getHeight() - 50)
    love.graphics.setColor(1, 1, 1, 1)

    -- Уведомление о достижении
    if achievementUnlocked then
        love.graphics.setColor(0, 1, 0, 1)
        love.graphics.rectangle("fill", achievementX, 20, 220, 40)
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.printf(achievementMessage, achievementX + 10, 30, 200, "center")
        love.graphics.setColor(1, 1, 1, 1)
    end

    -- Отображение текущего скина
    love.graphics.print("Current Skin: " .. currentSkinIndex, 10, love.graphics.getHeight() - 100)
end

function love.mousepressed(x, y, button, istouch, presses)
    if button == 1 then
        -- Луна
        local moonWidth = moonImage:getWidth() * moonScale
        local moonHeight = moonImage:getHeight() * moonScale
        local moonX = love.graphics.getWidth() / 2 - moonWidth / 2
        local moonY = love.graphics.getHeight() / 2 - moonHeight / 2
        
        if x > moonX and x < moonX + moonWidth and y > moonY and y < moonY + moonHeight then
            clicks = clicks + pointsPerClick
            pulseActive = true
            scalePulse = 0

            -- Частицы
            for i = 1, 10 do
                table.insert(particles, {
                    x = x,
                    y = y,
                    dx = love.math.random(-50, 50),
                    dy = love.math.random(-50, 50),
                    life = 1
                })
            end
        end

        -- Кнопка улучшения
        if x > 10 and x < 130 and y > love.graphics.getHeight() - 60 and y < love.graphics.getHeight() - 10 then
            if clicks >= upgradeCost then
                clicks = clicks - upgradeCost
                pointsPerClick = pointsPerClick + 1
                upgradeCost = math.floor(upgradeCost * 1.5)
            end
        end
    end
end
