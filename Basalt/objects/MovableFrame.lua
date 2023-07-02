local max,min,sub,rep = math.max,math.min,string.sub,string.rep

return function(name, basalt)
    local base = basalt.getObject("Frame")(name, basalt)
    base:setType("MovableFrame")
    local parent

    local dragXOffset, dragYOffset, isDragging = 0, 0, false
    local renderThrottle = basalt.getRenderingThrottle()

    base:addProperty("DraggingMap", "table", {{x1 = 1, x2 = "width", y1 = 1, y2 = 1}})

    local object = {
        getBase = function(self)
            return base
        end,

        load = function(self)
            base.load(self)
            self:listenEvent("mouse_click")
            self:listenEvent("mouse_up")
            self:listenEvent("mouse_drag")
        end,

        removeChildren = function(self)
            base.removeChildren(self)
            self:listenEvent("mouse_click")
            self:listenEvent("mouse_up")
            self:listenEvent("mouse_drag")
        end,

        dragHandler = function(self, btn, x, y)
            if(base.dragHandler(self, btn, x, y))then
                if (isDragging) then
                    local parentX = 1
                    local parentY = 1
                    parentX, parentY = parent:getAbsolutePosition()
                    self:setPosition(x + dragXOffset - (parentX - 1), y + dragYOffset - (parentY - 1))
                    self:updateDraw()
                end
                return true
            end
        end,

        mouseHandler = function(self, btn, x, y, ...)
            if(base.mouseHandler(self, btn, x, y, ...))then
                parent:setImportant(self)
                local fx, fy = self:getAbsolutePosition()
                local w, h = self:getSize()
                local dragMap = self:getDraggingMap()
                for k,v in pairs(dragMap)do
                    local x1, x2 = v.x1=="width" and w or v.x1, v.x2=="width" and w or v.x2
                    local y1, y2= v.y1=="height" and h or v.y1, v.y2=="height" and h or v.y2
                    if(x>=fx+x1-1)and(x<=fx+x2-1)and(y>=fy+y1-1)and(y<=fy+y2-1)then
                        renderThrottle = basalt.getRenderingThrottle()
                        basalt.setRenderingThrottle(50)
                        isDragging = true
                        dragXOffset = fx - x
                        dragYOffset = fy - y
                        return true
                    end
                end
                return true
            end
        end,

        mouseUpHandler = function(self, ...)
            isDragging = false
            basalt.setRenderingThrottle(0)
            return base.mouseUpHandler(self, ...)
        end,

        setParent = function(self, p, ...)
            base.setParent(self, p, ...)
            parent = p
            return self
        end,
    }

    object.__index = object
    return setmetatable(object, base)
end