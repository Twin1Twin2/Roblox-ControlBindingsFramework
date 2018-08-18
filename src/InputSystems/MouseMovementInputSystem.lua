
local ContextActionService = game:GetService("ContextActionService")

local InputSystem = require(script.Parent.Parent.InputSystem)

local CAS_BIND_ACTION_NAME = "MouseMovementInputSystem"

local MouseMovementInputSystem = InputSystem:Extend("MouseMovementInputSystem")

MouseMovementInputSystem.InputBindingList = {
    "MOUSE_MOVE";
    "MOUSE_MOVE_X";
    "MOUSE_MOVE_Y";

    "MOUSE_MOVE_LEFT";
    "MOUSE_MOVE_RIGHT";
    "MOUSE_MOVE_UP";
    "MOUSE_MOVE_DOWN";

    "MOUSE_MOVE_DELTA";
    "MOUSE_MOVE_DELTA_X";
    "MOUSE_MOVE_DELTA_Y";

    "MOUSE_MOVE_DELTA_LEFT";
    "MOUSE_MOVE_DELTA_RIGHT";
    "MOUSE_MOVE_DELTA_UP";
    "MOUSE_MOVE_DELTA_DOWN";
}

MouseMovementInputSystem.Enabled = false

MouseMovementInputSystem.LastPosition = Vector3.new(0, 0, 0)
MouseMovementInputSystem.Changed = false
MouseMovementInputSystem.Stopped = true


function MouseMovementInputSystem:SetDeltaInput(newVector)
    local xInput = newVector.X
    local yInput = newVector.Y

    self:SetBindingInput("MOUSE_MOVE_DELTA", newVector.Magnitude)
    self:SetBindingInput("MOUSE_MOVE_DELTA_X", xInput)
    self:SetBindingInput("MOUSE_MOVE_DELTA_Y", yInput)

    self:SetBindingInput("MOUSE_MOVE_DELTA_LEFT", -math.min(0, xInput))
    self:SetBindingInput("MOUSE_MOVE_DELTA_RIGHT", math.max(0, xInput))
    self:SetBindingInput("MOUSE_MOVE_DELTA_UP", -math.min(0, yInput))
    self:SetBindingInput("MOUSE_MOVE_DELTA_DOWN", math.max(0, yInput))
end


function MouseMovementInputSystem:SetPositionInput(newVector)
    local lastPosition = self.LastPosition
    local difference = newVector - lastPosition
    local xDiff = difference.X
    local yDiff = difference.Y

    self:SetBindingInput("MOUSE_MOVE", difference.Magnitude)
    self:SetBindingInput("MOUSE_MOVE_X", math.abs(xDiff))
    self:SetBindingInput("MOUSE_MOVE_Y", math.abs(yDiff))

    self:SetBindingInput("MOUSE_MOVE_LEFT", -math.min(0, xDiff))
    self:SetBindingInput("MOUSE_MOVE_RIGHT", math.max(0, xDiff))
    self:SetBindingInput("MOUSE_MOVE_UP", -math.min(0, yDiff))
    self:SetBindingInput("MOUSE_MOVE_DOWN", math.max(0, yDiff))

    self.LastPosition = newVector
end


function MouseMovementInputSystem:UpdateInput(inputName, userInputState, inputObject)
    self.Changed = true

    local delta = inputObject.Delta
    local position = inputObject.Position

    self:SetDeltaInput(delta)
    self:SetPositionInput(position)
end


function MouseMovementInputSystem:Enable()
    self.Enabled = true

    local function OnInput(inputName, userInputState, inputObject)
        self:UpdateInput(inputName, userInputState, inputObject)
    end

    ContextActionService:BindAction(CAS_BIND_ACTION_NAME, OnInput, false, Enum.UserInputType.MouseMovement)

    self.Engine:AddInputSystemToUpdater(self)
end


function MouseMovementInputSystem:Disable()
    self.Enabled = false

    ContextActionService:BindAction(CAS_BIND_ACTION_NAME, OnInput, false, Enum.UserInputType.MouseMovement)

    self.Engine:RemoveInputSystemFromUpdater(self)
end


function MouseMovementInputSystem:Initialize()
    
end


function MouseMovementInputSystem:BindingAdded(name, inputBinding)
    if (self.Enabled == false) then
        self:Enable()
    end
end


function MouseMovementInputSystem:BindingRemoved(name, inputBinding)
    if (self.InputBindingCount == 0) then
        self:Disable()
    end
end


function MouseMovementInputSystem:Update()
    if (self.Changed == true) then
        self.Changed = false
        self.Stopped = false
    elseif (self.Stopped == false) then
        self:SetDeltaInput(Vector3.new(0, 0, 0))
        self:SetPositionInput(self.LastPosition)
        self.Stopped = true
    end
end


return MouseMovementInputSystem