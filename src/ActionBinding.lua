--- A system that iterates through a list of InputBindings in order to calculate it's own input value
-- It's input is defined by the InputBindings it is subscribed to
--

local Table = require(script.Table)

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


function ActionBinding:AddInputBinding(name)
    assert(type(name) == "string")
    assert(self.Engine ~= nil)

    self.Engine:AddInputBindingsToAction(self, name)
end


function ActionBinding:RemoveInputBinding(name)
    assert(type(name) == "string")
    assert(self.Engine ~= nil)

    self.Engine:RemoveInputBindingsToAction(self, name)
end


function ActionBinding:Update()
    local input = 0

    for _, inputBinding in pairs(self._InputBindings) do
        local inputAmount = inputBinding.Input

        if (inputAmount > input) then
            input = inputAmount
        end
    end

    self.Input = input
end


function ActionBinding:Destroy()
    setmetatable(self, nil)
end


function ActionBinding.new(name)
    assert(type(name) == "string", "ActionBinding :: new() Arg [1] is not a string!")

    local self = setmetatable({}, ActionBinding)

    self.Name = name
    self.Input = 0

    self.Engine = nil

    self.InputBindingList = {}  --a list of input binding names

    self._InputBindings = {}

    self._IsActionBinding = true


    return self
end


return ActionBinding