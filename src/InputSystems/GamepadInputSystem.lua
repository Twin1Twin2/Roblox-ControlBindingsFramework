
local ContextActionService = game:GetService("ContextActionService")

local InputSystem = require(script.Parent.Parent.InputSystem)

local CAS_BIND_ACTION_NAME = "GamepadInputSystem"

local GAMEPAD_INPUT_BINDING_POSTFIXES  = {
    ["BUTTONX"] = Enum.KeyCode.ButtonX;
    ["BUTTONY"] = Enum.KeyCode.ButtonY;
    ["BUTTONA"] = Enum.KeyCode.ButtonA;
    ["BUTTONB"] = Enum.KeyCode.ButtonB;
    ["BUTTONR1"] = Enum.KeyCode.ButtonR1;
    ["BUTTONR2"] = Enum.KeyCode.ButtonR2;
    ["BUTTONR3"] = Enum.KeyCode.ButtonR3;
    ["BUTTONL1"] = Enum.KeyCode.ButtonL1;
    ["BUTTONL2"] = Enum.KeyCode.ButtonL2;
    ["BUTTONL3"] = Enum.KeyCode.ButtonL3;
    ["BUTTONSTART"] = Enum.KeyCode.ButtonStart;
    ["BUTTONSELECT"] = Enum.KeyCode.ButtonSelect;
    ["DPADLEFT"] = Enum.KeyCode.DPadLeft;
    ["DPADRIGHT"] = Enum.KeyCode.DPadRight;
    ["DPADUP"] = Enum.KeyCode.DPadUp;
    ["DPADDOWN"] = Enum.KeyCode.DPadDown;
    ["THUMBSTICK1"] = Enum.KeyCode.Thumbstick1;
    ["THUMBSTICK2"] = Enum.KeyCode.Thumbstick2;
}

local GAMEPAD_THUMBSTICK_INPUT_POSTFIXES = {
    ["_X"] = true;
    ["_Y"] = true;
    ["_UP"] = true;
    ["_DOWN"] = true;
    ["_LEFT"] = true;
    ["_RIGHT"] = true;
}


local GAMEPAD_INPUT_ENUMTYPES = {}

for i, v in pairs (GAMEPAD_INPUT_BINDING_POSTFIXES) do
    GAMEPAD_INPUT_ENUMTYPES[v.Name] = i;
end

local GAMEPAD_INPUT_CHANGED_INPUTS = {
    [Enum.KeyCode.ButtonR2.Name] = true;
    [Enum.KeyCode.ButtonL2.Name] = true;
    [Enum.KeyCode.Thumbstick1.Name] = true;
    [Enum.KeyCode.Thumbstick2.Name] = true;
}

local GAMEPAD_THUMBSTICK_INPUTS = {
    [Enum.KeyCode.Thumbstick1.Name] = true;
    [Enum.KeyCode.Thumbstick2.Name] = true;
}

local GAMEPAD_ANALOG_BUTTON_INPUTS = {
    [Enum.KeyCode.ButtonR2.Name] = true;
    [Enum.KeyCode.ButtonL2.Name] = true;
}

local GAMEPAD_INPUT_BINDING_PREFIXES = {
    [1] = "GAMEPAD1";
    [2] = "GAMEPAD2";
    [3] = "GAMEPAD3";
    [4] = "GAMEPAD4";
    [5] = "GAMEPAD5";
    [6] = "GAMEPAD6";
    [7] = "GAMEPAD7";
    [8] = "GAMEPAD8";
}


local GAMEPAD_INDEXES = {
    [1] = Enum.UserInputType.Gamepad1;
    [2] = Enum.UserInputType.Gamepad2;
    [3] = Enum.UserInputType.Gamepad3;
    [4] = Enum.UserInputType.Gamepad4;
    [5] = Enum.UserInputType.Gamepad5;
    [6] = Enum.UserInputType.Gamepad6;
    [7] = Enum.UserInputType.Gamepad7;
    [8] = Enum.UserInputType.Gamepad8;
}


local GamepadInputSystem = {
    ClassName  = "GamepadInputSystem";
}

GamepadInputSystem.__index = GamepadInputSystem
setmetatable(GamepadInputSystem, InputSystem)

GamepadInputSystem.GAMEPAD_INPUT_BINDING_PREFIXES = GAMEPAD_INPUT_BINDING_PREFIXES
GamepadInputSystem.GAMEPAD_INDEXES = GAMEPAD_INDEXES


function GamepadInputSystem:UpdateThumbstick(thumbstickName, position)
    local xPos = position.X
    local yPos = position.Y

    self:SetBindingInput(thumbstickName, position.Magnitude)
    self:SetBindingInput(thumbstickName .. "_X", math.abs(xPos))
    self:SetBindingInput(thumbstickName .. "_Y", math.abs(yPos))

    self:SetBindingInput(thumbstickName .. "_RIGHT", math.max(0, xPos))
    self:SetBindingInput(thumbstickName .. "_LEFT", -math.min(0, xPos))
    self:SetBindingInput(thumbstickName .. "_UP", math.max(0, yPos))
    self:SetBindingInput(thumbstickName .. "_DOWN", -math.min(0, yPos))
end


function GamepadInputSystem:UpdateAnalogButton(buttonName, position)
    self:SetBindingInput(buttonName, position)
end


function GamepadInputSystem:UpdateChangedInputBinding(inputName, inputObject, keyCodeName)
    self.ChangedInputBindings[inputName].Changed = true

    if (GAMEPAD_THUMBSTICK_INPUTS[keyCodeName]) then
        self:UpdateThumbstick(inputName, inputObject)
    elseif (GAMEPAD_ANALOG_BUTTON_INPUTS[keyCodeName]) then
        self:UpdateAnalogButton(inputName, inputObject)
    end
end


function GamepadInputSystem:UpdateDigitalInputBinding(buttonName, userInputState)
    local newInput = 0

    if (userInputState == Enum.UserInputState.Begin or userInputState == Enum.UserInputState.Changed) then
        newInput = 1
    end

    self:SetBindingInput(buttonName, newInput)
end


function GamepadInputSystem:UpdateInput(actionName, userInputState, inputObject)
    local keyCode = inputObject.KeyCode
    local keyCodeName = keyCode.Name
    local inputName = GAMEPAD_INPUT_ENUMTYPES[keyCodeName]

    asssert(inputName ~= nil)

    if (GAMEPAD_INPUT_CHANGED_INPUTS[keyCodeName] == true) then
        self:UpdateChangedInputBinding(inputName, inputObject, keyCodeName)
    else
        self:UpdateDigitalInputBinding(inputName, userInputState)
    end
end


function GamepadInputSystem:SetBindingInput(name, input)
    name = self.InputBindingPrefix .. name
    InputSystem.SetBindingInput(self, name, input)
end


function GamepadInputSystem:Enable()
    self.Enabled = true

    local function OnInput(actionName, userInputState, inputObject)
        self:UpdateInput(actionName, userInputState, inputObject)
    end

    ContextActionService:BindAction(self.BindActionNamee, OnInput, false, self.GamepadEnum)

    self.Engine:AddInputSystemToUpdater(self)
end


function GamepadInputSystem:Disable()
    self.Enabled = false

    ContextActionService:UnbindAction(self.BindActionName)

    self.Engine:RemoveInputSystemFromUpdater(self)
end


function GamepadInputSystem.GenerateInputBindingNames(inputBindingPrefix)
    local inputBindingList = {}

    for postfix, enumItem in pairs(GAMEPAD_INPUT_BINDING_POSTFIXES) do
        local enumItemName = enumItem.Name
        local inputBindingName = inputBindingPrefix .. postfix
        table.insert(inputBindingList, inputBindingName)

        if (GAMEPAD_THUMBSTICK_INPUTS[enumItem.Name] == true) then
            for thumbstickPostfix, _ in pairs(GAMEPAD_THUMBSTICK_INPUT_POSTFIXES) do
                local thumbstickInputBindingName = inputBindingPrefix .. postfix .. thumbstickPostfix
                table.insert(inputBindingList, thumbstickInputBindingName)
            end
        end
    end

    return inputBindingList
end


function GamepadInputSystem:Initialize()
    local inputBindingList = GamepadInputSystem.GenerateInputBindingNames(self.InputBindingPrefix)

    for _, inputBindingName in pairs(inputBindingList) do
        table.insert(self.InputBindingList, inputBindingName)
    end

    for inputChangedInputName, _ in pairs(GAMEPAD_INPUT_CHANGED_INPUTS) do
        self.ChangedInputBindings[inputChangedInputName] = {
            Changed = false;
            Stopped = true;
        }
    end
end


function GamepadInputSystem:BindingAdded(name, inputBinding)
    if (self.Enabled == false) then
        self:Enable()
    end
end


function GamepadInputSystem:BindingRemoved(name, inputBinding)
    if (self.InputBindingCount == 0) then
        self:Disable()
    end
end


function GamepadInputSystem:UpdateChangedThumbstick(name, data)
    if (data.Changed == true) then
        data.Changed = false
        data.Stopped = false
    elseif (data.Stopped == false) then
        data.Stopped = true
        data:UpdateThumbstick(name, Vector3.new(0, 0, 0))
    end
end


function GamepadInputSystem:UpdateChangedAnalogButton(name, data)
    if (data.Changed == true) then
        data.Changed = false
        data.Stopped = false
    elseif (data.Stopped == false) then
        data.Stopped = true
        data:UpdateAnalogButton(name, 0)
    end
end


function GamepadInputSystem:Update()
    for keyCodeName, _ in pairs(GAMEPAD_THUMBSTICK_INPUTS) do
        local inputName = GAMEPAD_INPUT_ENUMTYPES[keyCodeName]
        self:UpdateChangedThumbstick(inputName, self.ChangedInputBindings[keyCodeName])
    end

    for keyCodeName, _ in pairs(GAMEPAD_INPUT_CHANGED_INPUTS) do
        local inputName = GAMEPAD_INPUT_ENUMTYPES[keyCodeName]
        self:UpdateChangedAnalogButton(inputName, self.ChangedInputBindings[keyCodeName])
    end
end


function GamepadInputSystem.new(gamepadNumber)
    assert(type(gamepadNumber) == "number" and gamepadNumber > 0 and gamepadNumber <= 8)

    local gamepadEnum = GAMEPAD_INDEXES[gamepadNumber]
    local inputBindingPrefix = GAMEPAD_INPUT_BINDING_PREFIXES[gamepadNumber]

    local inputSystemName = "Gamepad" .. tostring(gamepadNumber) .. "InputSystem"

    local self = setmetatable(InputSystem.new(inputSystemName), GamepadInputSystem)

    self.GamepadEnum = gamepadEnum
    self.InputBindingPrefix = inputBindingPrefix
    self.BindActionName = nil
    
    self.Enabled = false

    self.ChangedInputBindings = {}
    

    return self
end


return GamepadInputSystem