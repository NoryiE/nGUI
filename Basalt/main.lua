local basaltPath = ".basalt"

local defaultPath = package.path
local format = "path;/path/?.lua;/path/?/init.lua;"
local main = format:gsub("path", basaltPath)
local eleFolder = format:gsub("path", basaltPath.."/elements")
local extFolder = format:gsub("path", basaltPath.."/extensions")
local libFolder = format:gsub("path", basaltPath.."/libraries")
package.path = main..eleFolder..extFolder..libFolder..defaultPath

local loader = require("basaltLoader")
local utils = require("utils")
local log = require("log")

--- The Basalt Core API
--- @class Basalt
local basalt = {log=log, extensionExists = loader.extensionExists}

local threads = {}
local updaterActive = false
local mainFrame, focusedFrame, monFrames = nil, nil, {}
local baseTerm = term.current()
local registeredEvents = {}
local keysDown,mouseDown = {}, {}
loader.setBasalt(basalt)

---- Frame Rendering
local function drawFrames()
    if(updaterActive==false)then return end
    if(mainFrame~=nil)then
        mainFrame:render()
        mainFrame:processRender()
    end
    for _,v in pairs(monFrames)do
        v:render()
        v:processRender()
    end
end

---- Event Handling
local throttle = {mouse_drag=0.05, mouse_move=0.05}
local lastEventTimes = {}
local lastEventArgs = {}

local events = {
    mouse = {mouse_click=true,mouse_up=true,mouse_drag=true,mouse_scroll=true,mouse_move=true,monitor_touch=true},
    keyboard = {key=true,key_up=true,char=true}
}
local function updateEvent(event, ...)
    local p = {...}
    if(event=="terminate")then basalt.stop() end
    if(event=="mouse_move")then
        if(p[1]==nil)or(p[2]==nil)then return end
    end

    for _,v in pairs(registeredEvents)do
        if(v==event)then
            if not v(event, unpack(p)) then
                return
            end
        end
    end

    if event == "timer" then
        for k,v in pairs(lastEventTimes) do
            if v == p[1] then
                if mainFrame ~= nil and mainFrame[k] ~= nil then
                    mainFrame[k](mainFrame, unpack(lastEventArgs[k]))
                end
                for _,b in pairs(monFrames) do
                    if b[k] ~= nil then
                        b[k](b, unpack(lastEventArgs[k]))
                    end
                end
                lastEventTimes[k] = nil
                lastEventArgs[k] = nil
                drawFrames()
                return
            end
        end
    end

    if throttle[event] ~= nil and throttle[event] > 0 then
        if lastEventTimes[event] == nil then
            lastEventTimes[event] = os.startTimer(throttle[event])
        end
        lastEventArgs[event] = p
        return
    else
        if(event=="key")then
            keysDown[p[1]] = true
        end
        if(event=="key_up")then
            keysDown[p[1]] = false
        end
        if(event=="mouse_click")then
            mouseDown[p[1]] = true
        end
        if(event=="mouse_up")then
            mouseDown[p[1]] = false
            if mainFrame ~= nil and mainFrame.mouse_release ~= nil then
                mainFrame.mouse_release(mainFrame, unpack(p))
            end
        end
        if(events.mouse[event])then
            if(event=="monitor_touch")then
                for _,v in pairs(monFrames) do
                    if v[event] ~= nil then
                        v[event](v, unpack(p))
                    end
                end
            else
                if mainFrame ~= nil and mainFrame.event ~= nil then
                    mainFrame[event](mainFrame, unpack(p))
                end
            end
        elseif(events.keyboard[event])then
            if focusedFrame ~= nil and focusedFrame[event] ~= nil then
                focusedFrame[event](focusedFrame, unpack(p))
            end
        else
            if mainFrame ~= nil and mainFrame.event ~= nil then
                mainFrame:event(event, unpack(p))
            end
            for _,v in pairs(monFrames) do
                if v[event] ~= nil then
                    v[event](v, unpack(p))
                end
            end
        end
        if(#threads>0)then
            for k,v in pairs(threads)do
                if(coroutine.status(v.thread)=="dead")then
                    table.remove(threads, k)
                else
                    if(v.filter~=nil)then
                        if(event~=v.filter)then
                            drawFrames()
                            return
                        end
                        v.filter=nil
                    end
                    local ok, filter = coroutine.resume(v.thread, event, ...)
                    if(ok)then
                        v.filter = filter
                    else
                        basalt.errorHandler(filter)
                    end
                end
            end
        end
        drawFrames()
    end
end

--- Checks if a key is currently pressed
--- @param key number -- Use the key codes from the `keys` table, example: `keys.enter`
--- @return boolean
function basalt.isKeyDown(key)
    return keysDown[key] or false
end

--- Checks if a mouse button is currently pressed
--- @param button number -- Use the button numbers: 1, 2, 3, 4 or 5
--- @return boolean
function basalt.isMouseDown(button)
    return mouseDown[button] or false
end

--- Returns the current main active main frame, if it doesn't exist it will create one
--- @param id? string -- The id of the frame
--- @return BaseFrame
function basalt.getMainFrame(id)
    if(mainFrame==nil)then
        mainFrame = loader.load("BaseFrame"):new(id or "Basalt_Mainframe", nil, basalt)
        mainFrame:init()
    end
    return mainFrame
end

--- Creates a new frame, if main frame doesn't exist it will be set to the new frame.
--- @param id? string -- The id of the frame
--- @return BaseFrame
function basalt.addFrame(id)
    id = id or utils.uuid()
    local frame = loader.load("BaseFrame"):new(id, nil, basalt)
    frame:init()
    if(mainFrame==nil)then
        mainFrame = frame
    end
    return frame
end

--- Switches the main frame to a new frame
--- @param frame BaseFrame -- The frame to switch to
function basalt.switchFrame(frame)
    if(frame:getType()~="BaseFrame")then
        error("Invalid frame type: "..frame:getType().." (expected: BaseFrame)")
    end
    mainFrame = frame
    frame:forceRender()
    basalt.setFocusedFrame(frame)
end

--- Creates a new monitor frame
--- @param id? string -- The id of the monitor
--- @return Monitor
function basalt.addMonitor(id)
    id = id or utils.uuid()
    local frame = loader.load("Monitor"):new(id, nil, basalt)
    frame:init()
    table.insert(monFrames, frame)
    return frame
end

--- Creates a new big monitor frame
--- @param id? string -- The id of the big monitor
--- @return BigMonitor
function basalt.addBigMonitor(id)
    id = id or utils.uuid()
    local frame = loader.load("BigMonitor"):new(id, nil, basalt)
    frame:init()
    table.insert(monFrames, frame)
    return frame
end

--- Creates a new element
--- @param id string -- The id of the element
--- @param parent Container|nil -- The parent frame of the element
--- @param typ string -- The type of the element
--- @param defaultProperties? table -- The default properties of the element
--- @return BasicElement
function basalt.create(id, parent, typ, defaultProperties)
    local l = loader.load(typ)
    if(type(l)=="string")then
        l = load(l, nil, "t", _ENV)()
    end
    local element = l:new(id, parent, basalt)
    if(defaultProperties~=nil)then
        for k,v in pairs(defaultProperties)do
            local fName = "set"..k:sub(1,1):upper()..k:sub(2)
            if(element[fName]~=nil)then
                element[fName](element, v)
            else
                element[k] = v
            end
        end
    end
    return element
end

--- The error Handler which is used by basalt when errors happen. Can be overwritten
--- @param errMsg string -- The error message
function basalt.errorHandler(errMsg)
    baseTerm.clear()
    baseTerm.setCursorPos(1,1)
    baseTerm.setBackgroundColor(colors.black)
    baseTerm.setTextColor(colors.red)
    if(basalt.logging)then
        log(errMsg, "Error")
    end
    print(errMsg)
    baseTerm.setTextColor(colors.white)
    updaterActive = false
end


--- Starts the update loop
--- @param isActive? boolean -- If the update loop should be active
function basalt.autoUpdate(isActive)
    updaterActive = isActive
    if(isActive==nil)then updaterActive = true end
    local function f()
        drawFrames()
        while updaterActive do
            updateEvent(os.pullEventRaw())
        end
    end
    while updaterActive do
        local ok, err = xpcall(f, debug.traceback)
        if not(ok)then
            basalt.errorHandler(err)
        end
    end
end

--- Returns a list of all available elements in the current basalt installation
--- @return table
function basalt.getElements()
    return loader.getElementList()
end

--- Registers a new event listener
--- @param event string -- The event to listen for
--- @param func function -- The function to call when the event is triggered
function basalt.onEvent(event, func)
    if(registeredEvents[event]==nil)then
        registeredEvents[event] = {}
    end
    table.insert(registeredEvents[event], func)
end

--- Removes an event listener
--- @param event string -- The event to remove the listener from
--- @param func function -- The function to remove
function basalt.removeEvent(event, func)
    if(registeredEvents[event]==nil)then return end
    for k,v in pairs(registeredEvents[event])do
        if(v==func)then
            table.remove(registeredEvents[event], k)
        end
    end
end

--- Sets the focused frame
--- @param frame BaseFrame|Monitor|BigMonitor -- The frame to focus
function basalt.setFocusedFrame(frame)
    if(focusedFrame~=nil)then
        focusedFrame:lose_focus()
    end
    if(frame~=nil)then
        frame:get_focus()
    end
    focusedFrame = frame
end


--- Starts a new thread which runs the function parallel to the main thread
--- @param func function -- The function to run
--- @vararg any? -- The arguments to pass to the function
function basalt.thread(func, ...)
    local threadData = {}
    threadData.thread = coroutine.create(func)
    local ok, filter = coroutine.resume(threadData.thread, ...)
    if(ok)then
        threadData.filter = filter
        table.insert(threads, threadData)
        return threadData
    end
    basalt.errorHandler(filter)
end

--- Stops the update loop
function basalt.stop()
    updaterActive = false
end

--- Returns the current term
function basalt.getTerm()
    return baseTerm
end

local extensions = loader.getExtension("Basalt")
if(extensions~=nil)then
    for _,v in pairs(extensions)do
        v.basalt = basalt
        for a,b in pairs(v)do
            basalt[a] = b
        end
    end
end

package.path = defaultPath
return basalt