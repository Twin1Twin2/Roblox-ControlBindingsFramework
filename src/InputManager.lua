--- A system that operates on a group of InputBindings and updates their input value
-- Has a fixed set of InputBindings that are created and added when this object is added to the engine
--

local InputManager = {
    ClassName = "InputManager";
}

InputManager.__index = InputManager


function InputManager:Initialize()

end


function InputManager:Update()

end


function InputManager:Destroy()
    setmetatable(self, nil)
end


function InputManager:Extend(name)

end


function InputManager.new(name)
    assert(type(name) == "string", "InputBinding :: new() Arg [1] is not a string!")

    local self = setmetatable({}, InputManager)

    self.Name = ""

    self.InputBindings = {}
    self.InputBindingList = {}

    self._IsInputManager = true


    return self
end


return InputManager