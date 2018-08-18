
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


function ControlBindingsFramework:Enable()
    if (self._UpdateConnection ~= nil) then
        return
    end

    self._UpdateConnection = RunService.RenderStepped:Connect(function()
        self.Engine:Update()
    end)
end


function ControlBindingsFramework:Disable()
    if (self._UpdateConnection ~= nil) then
        self._UpdateConnection:Destroy()
    end
end


function ControlBindingsFramework:Get() --until i figure stuff out
    return self.Engine
end


for _, InputSystemModule in pairs(inputSystemModules:GetChildren()) do
    local InputSystemName = InputSystemModule.Name
    local InputSystem = require(InputSystemModule)    --idc if your module breaks. make sure it doesn't
    
    ControlBindingsFramework[InputSystemName] = InputSystem
end


return ControlBindingsFramework