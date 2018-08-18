
local ContextActionService = game:GetService("ContextActionService")

local InputSystem = require(script.Parent.Parent.InputSystem)

local CAS_BIND_ACTION_NAME = "MouseWheelInputSystem"
local MOUSE_WHEEL_ENUM_NAME = Enum.UserInputType.MouseWheel.Name

local MouseWheelInputSystem = InputSystem:Extend("MouseWheelInputSystem")

MouseWheelInputSystem.InputBindingList = {
    MOUSE_WHEEL_ENUM_NAME;
    "MOUSE_WHEEL";
    "MOUSE_WHEEL_UP";
    "MOUSE_WHEEL_DOWN";
}

MouseWheelInputSystem.Enabled = false

MouseWheelInputSystem.Changed = false
MouseWheelInputSystem.Stopped = true


function MouseWheelInputSystem:SetPositionInput(position)
    self:SetBindingInput(MOUSE_WHEEL_ENUM_NAME, math.abs(position))
    self:SetBindingInput("MOUSE_WHEEL", math.abs(position))
    self:SetBindingInput("MOUSE_WHEEL_UP", math.max(0, position))
    self:SetBindingInput("MOUSE_WHEEL_DOWN", -math.min(0, position))
end


function MouseWheelInputSystem:UpdateInput(inputName, userInputState, inputObject)
    self.Changed = true

    self:SetPositionInput(inputObject.Position.Z)
end


function MouseWheelInputSystem:Enable()
    self.Enabled = true

    local function OnInput(inputName, userInputState, inputObject)
        self:UpdateInput(inputName, userInputState, inputObject)
    end

    ContextActionService:BindAction(CAS_BIND_ACTION_NAME, OnInput, false, Enum.UserInputType.MouseWheel)

    self.Engine:AddInputSystemToUpdater(self)
end


function MouseWheelInputSystem:Disable()
    self.Enabled = false

    ContextActionService:UnbindAction(CAS_BIND_ACTION_NAME)

    self.Engine:RemoveInputSystemFromUpdater(self)
end


function MouseWheelInputSystem:BindingAdded(name, inputBinding)
    if (self.Enabled == false) then
        self:Enable()
    end
end


function MouseWheelInputSystem:BindingRemoved(name, inputBinding)
    if (self.InputBindingCount == 0) then
        self:Disable()
    end
end


function MouseWheelInputSystem:Update()
    if (self.Changed == true) then
        self.Changed = false
        self.Stopped = false
    elseif (self.Stopped == false) then
        self.Stopped = true
        self:SetPositionInput(0)
    end
end


return MouseWheelInputSystem