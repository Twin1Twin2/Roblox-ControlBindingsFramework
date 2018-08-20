--- A system that iterates through a list of InputBindings in order to calculate it's own input value
-- It's input is defined by the InputBindings it is subscribed to
--

local Signal = require(script.Parent.Signal)
local Table = require(script.Parent.Table)

local TableContains = Table.Contains
local AttemptRemovalFromTable = Table.AttemptRemovalFromTable


local ActionBinding = {
    ClassName = "ActionBinding";
}

ActionBinding.__index = ActionBinding


function ActionBinding:HasInputBinding(name)
    return self._InputBindings[name] ~= nil
end


function ActionBinding:RegisterInputBinding(name, inputBinding)
    self._InputBindings[name] = inputBinding
    inputBinding:RegisterAction(self.Name, self)
end


function ActionBinding:UnregisterInputBinding(name, inputBinding)
    self._InputBindings[name] = nil
    inputBinding:UnregisterAction(self.Name, self)
end


function ActionBinding:SetInputBindings(inputBindingNames, clearOldBindings)
    assert(type(inputBindingNames) == "table")

    if (clearOldBindings == true) then
        self:ClearInputBindings()
    end

    for _, inputBindingName in pairs(inputBindingNames) do
        self:AddInputBinding(inputBindingName)
    end
end


function ActionBinding:AddInputBinding(name)
    assert(type(name) == "string")
    assert(self.Engine ~= nil)

    self.Engine:AddInputBindingsToAction(self, name)
end


function ActionBinding:RemoveInputBinding(name)
    assert(type(name) == "string")
    assert(self.Engine ~= nil)

    self.Engine:RemoveInputBindingsFromAction(self, name)
end


function ActionBinding:ClearInputBindings()
    assert(self.Engine ~= nil)

    for inputBindingName, inputBinding in pairs(self._InputBindings) do
        if (inputBinding ~= nil) then
            self.Engine:RemoveInputBindingsFromAction(self, inputBindingName)
        end
    end
end


function ActionBinding:Update()
    local currentInput = self.Input
    local newInput = 0

    for _, inputBinding in pairs(self._InputBindings) do
        local inputAmount = inputBinding.Input

        if (inputAmount > newInput) then
            newInput = inputAmount
        end
    end

    self.Input = newInput

    if (newInput > 0) then
        self.IsDown = true
        self.OnInputDown:Fire(newInput)
    else
        self.IsDown = false
    end

    if (currentInput ~= newInput) then
        if (currentInput == 0) then
			self.OnInputBegan:Fire()
		elseif (newInput == 0) then
			self.OnInputEnded:Fire()
		else
            self.OnInputChanged:Fire()
        end
    end
end


function ActionBinding:Destroy()
    self.Engine = nil

    self.InputBindingList = nil
    self._InputBindings = nil

    self.OnInputDown:Destroy()
    self.OnInputBegan:Destroy()
    self.OnInputEnded:Destroy()
    self.OnInputChanged:Destroy()

    setmetatable(self, nil)
end


function ActionBinding.new(name)
    assert(type(name) == "string", "ActionBinding :: new() Arg [1] is not a string!")

    local self = setmetatable({}, ActionBinding)

    self.Name = name
    self.Input = 0
    self.IsDown = false

    self.Engine = nil

    self.InputBindingList = {}  --a list of input binding names

    self._InputBindings = {}

    self.OnInputDown = Signal.new()
    self.OnInputBegan = Signal.new()
    self.OnInputEnded = Signal.new()
    self.OnInputChanged = Signal.new()

    self._IsActionBinding = true
    self._WasCreatedByEngine = false


    return self
end


return ActionBinding