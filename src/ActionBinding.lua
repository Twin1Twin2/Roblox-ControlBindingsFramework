--- A system that iterates through a list of InputBindings in order to calculate it's own input value
-- It's input is defined by the InputBindings it is subscribed to
--

local ActionBinding = {
    ClassName = "ActionBinding";
}

ActionBinding.__index = ActionBinding


function ActionBinding:HasInputBinding(name)
    return self._InputBindings[name] ~= nil
end


function ActionBinding:AddInputBinding(name)

end


function ActionBinding:RemoveInputBinding(name)

end


function ActionBinding:Update()
    
end


function ActionBinding:Destroy()
    setmetatable(self, nil)
end


function ActionBinding.new(name)
    assert(type(name) == "string", "ActionBinding :: new() Arg [1] is not a string!")

    local self = setmetatable({}, ActionBinding)

    self.Name = name
    self.Input = nil    --Extend this class to set it's value; idk

    self.InputBindingList = {}  --a list of input binding names

    self._InputBindings = {}

    self._IsActionBinding = true


    return self
end


return ActionBinding