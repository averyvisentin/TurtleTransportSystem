-- Load required modules
require("state")
require("in")
require("out")

-- Set the computer label
os.setComputerLabel('Hub ' .. os.getComputerID())

-- Open Rednet on available modems
local function openRednet()
    for _, side in pairs({'back', 'top', 'left', 'right'}) do
        if peripheral.getType(side) == 'modem' then
            rednet.open(side)
        end
    end
end

openRednet()

-- Table to keep track of turtle states
local turtleStates = {}

-- Function to handle incoming messages from turtles
local function handleMessages()
    while true do
        local senderId, message, protocol = rednet.receive()
        if protocol == "turtle_status" then
            print("Received status from Turtle " .. senderId .. ": " .. message)
            -- Update turtle state
            turtleStates[senderId] = message
            -- Display the updated state
            displayTurtleStates()
        elseif protocol == "turtle_command" then
            -- Process command response
            print("Received command response from Turtle " .. senderId .. ": " .. message)
        end
    end
end

-- Function to send commands to turtles
local function sendCommand(turtleId, command)
    rednet.send(turtleId, command, "turtle_command")
end

-- Function to display turtle states
local function displayTurtleStates()
    term.clear()
    term.setCursorPos(1, 1)
    print("Turtle States:")
    for id, state in pairs(turtleStates) do
        print("Turtle " .. id .. ": " .. state)
    end
end

-- Example user interface for sending commands
local function userInterface()
    while true do
        term.clear()
        term.setCursorPos(1, 1)
        print("Enter Turtle ID and Command:")
        local input = read()
        local turtleId, command = string.match(input, "(%d+)%s(.+)")
        if turtleId and command then
            sendCommand(tonumber(turtleId), command)
        else
            print("Invalid input. Please enter in the format: <TurtleID> <Command>")
        end
    end
end

-- Run the main functions
parallel.waitForAny(handleMessages, userInterface)
