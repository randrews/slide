require 'Animation'

player = {x = 5, y = 5}
current_anim = nil
player_spr = nil
shower_visible = false

sprites = {}

function _draw()
    --[[
    graphics.setColor(100, 200, 235)
    
    graphics.push()
    graphics.translate(100, 100)
    
    graphics.translate(50, 50)
    graphics.rotate(ang)
    graphics.translate(-50, -50)
    graphics.rectangle('fill', 0, 0, 100, 100)
    graphics.pop()
    
    graphics.scale(0.5, 2)
    graphics.rectangle('line', 1, 1, 200, 50)
    --]]
end

function _swipe(dir)
    print(dir)

    if current_anim then return end

    local pt, anim
    if dir == 'down' then pt, anim = try_move(player, 0, -1)
    elseif dir == 'up' then pt, anim = try_move(player, 0, 1)
    elseif dir == 'left' then pt, anim = try_move(player, -1, 0)
    elseif dir == 'right' then pt, anim = try_move(player, 1, 0) end

    if pt then
        anim.finished = function()
            player = pt
            player_spr:position(pt.x*32, pt.y*32)
            
            if pt.x == 0 and not shower_visible then
                sprites.shower:add()
                shower_visible = true
            end
        end
        current_anim = anim
    end

end

function _update(dt)
    if current_anim then
        current_anim:tick(dt)
        if not current_anim.complete then
            local x, y = player.x * 32, player.y * 32
            if current_anim.var == 'x' then x = x + current_anim.current
            else y = y + current_anim.current end
            player_spr:position(x, y)
        end
    end

    if current_anim and current_anim.complete then current_anim = nil end
end

function addPart(x, y)
    local part = graphics.particle('Galaxy.plist', x, y)
    part:add()
end

MAP = {
    '..........',
    '..###.....',
    '..#.#.....',
    '..........',
    '..........',
    '..........',
    '..........',
    '..#####...',
    '..#.......',
    '..........',
    '.......#..',
    '..........',
    '..........',
    '..........',
    '..........'    
}

function each_cell(fn)
    for y = 1, 15 do
        local s = MAP[y]
        for x = 1, 10 do
            local c = s:sub(x, x)
            fn(c, x-1, 15-y)
        end
    end
end

function char_at(x, y)
    local str = MAP[15-y]
    return str:sub(x+1, x+1)
end

function in_bounds(x,y)
    return x >= 0 and x < 10 and y >= 0 and y<14
end

function try_move(pt, dx, dy)
    local x, y = pt.x, pt.y
    if not in_bounds(x+dx, y+dy) or char_at(x+dx, y+dy) == '#' then
        return false
    else
        local anim = Animation.new{
            value1 = 0,
            value2 = 32*(dx+dy),
            duration = 0.1
        }
        
        local pt2 = {x = pt.x + dx, y = pt.y + dy}
        if dx ~= 0 then anim.var = 'x' else anim.var = 'y' end

        return pt2, anim
    end
end

function _init()
    local w, h = 320, 480
        
    sprites.bg = graphics.sprite('bg.png', 160, 240)
    sprites.bg:add()
    
    sprites.shower = graphics.particle('BurstPipe.plist', 160, 440)

    each_cell(function(c, x, y)
        if c == '#' then
            local s = graphics.sprite('tiles.png', x*32, y*32, 0, 0, 32, 32)
            s:add()
            table.insert(sprites, s)
        end
    end)
    
    player_spr = graphics.sprite('tiles.png', 32*player.x, 32*player.y, 32, 0, 32, 32)
    player_spr:add()
end