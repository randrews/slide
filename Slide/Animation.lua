module('Animation', package.seeall)

local instance = {
    value1 = 0,
    value2 = 1,
    duration = 0.25, -- sec
    current = 0
}

function new(tbl)
    local a = setmetatable(tbl or {}, {__index = instance})
    return a:init()
end

function instance.init(self)
    self.current = self.value1
    self.step = (self.value2 - self.value1) / self.duration
    self.backwards = self.value2 < self.value1
    self.complete = false
    return self
end

function instance.tick(self, delta)
    self.current = self.current + self.step * delta
    
    if (not self.backwards and self.current >= self.value2) or
        (self.backwards and self.current <= self.value2) then
        self.complete = true
        self:finished()
    end

    return self
end

function instance.finished(self) end
