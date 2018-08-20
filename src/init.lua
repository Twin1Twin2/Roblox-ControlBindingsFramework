
local RunService = game:GetService("RunService")

local Signal = require(script.Signal)

local ActionBinding = require(script.ActionBinding)
local CBEngine = require(script.CBEngine)
local InputSystem = require(script.InputSystem)


local inputSystemModules = script.InputSystems


local ControlBindingsFramework = {}

ControlBindingsFramework.ActionBinding = ActionBinding
ControlBindingsFramework.Engine = CBEngine.new()
ControlBindingsFramework.InputSystem = InputSystem

ControlBindingsFramework._UpdateConnection = nil


function ControlBindingsFramework:Get() --until i figure stuff out
    return self.Engine
end


for _, inputSystemModule in pairs(inputSystemModules:GetChildren()) do
    local inputSystemName = inputSystemModule.Name
    local inputSystem = require(inputSystemModule)    --idc if your module breaks. make sure it doesn't
    
    ControlBindingsFramework[inputSystemName] = inputSystem
end


return ControlBindingsFramework