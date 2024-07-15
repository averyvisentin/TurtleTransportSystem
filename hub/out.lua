-- Function to send a command to a turtle
function sendCommand(turtleId, command)
    rednet.send(turtleId, command, "turtle_command")
end

-- Example usage
---sendCommand(2, "move_forward")
