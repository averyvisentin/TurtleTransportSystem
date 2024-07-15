require("state")


-- SET LABEL
os.setComputerLabel('Turtle ' .. os.getComputerID())

-- OPEN REDNET
for _, side in pairs({'back', 'top', 'left', 'right'}) do
    if peripheral.getType(side) == 'modem' then
        rednet.open(side)
        break
    end
end





-- Define global variables for state
local state = {}

function Log_movement(direction, state) --adjust location and orientation based on movement
    if direction == 'up' then --so y plus is upvalue
        state.location.y = state.location.y + 1
    elseif direction == 'down' then
        state.location.y = state.location.y - 1
    elseif direction == 'forward' then
        bump = Bumps[state.orientation]
        state.location = {x = state.location.x + bump[1], y = state.location.y + bump[2], z = state.location.z + bump[3]}
    elseif direction == 'back' then
        bump = Bumps[state.orientation]
        state.location = {x = state.location.x - bump[1], y = state.location.y - bump[2], z = state.location.z - bump[3]}
    elseif direction == 'left' then
        state.orientation = left_shift[state.orientation]
    elseif direction == 'right' then
        state.orientation = right_shift[state.orientation]
    end
    return true
end

-- Define function to calibrate the turtle's position and orientation
local function Calibrate()
    -- Attempt to determine current position using GPS
    local sx, sy, sz = gps.locate()
    if not sx or not sy or not sz then
        print("GPS signal not found. Cannot calibrate.")
        return false
    end

    -- Try moving to an adjacent block and back to detect orientation
    for i = 1, 4 do
        -- Check if there's an empty adjacent block
        if not turtle.detect() then
            break
        end
        if not turtle.turnRight() then
            print("Failed to turn right during calibration.")
            return false
        end
    end

    -- If still detecting a block, attempt to dig to clear the path
    if turtle.detect() then
        for i = 1, 4 do
            turtle.dig()
            if not turtle.detect() then
                break
            end
            if not turtle.turnRight() then
                print("Failed to turn right after digging during calibration.")
                return false
            end
        end

        -- If still detecting a block after attempting to clear, return false
        if turtle.detect() then
            print("Could not clear path during calibration.")
            return false
        end
    end

    -- Move forward to finalize orientation detection
    if not turtle.forward() then
        print("Failed to move forward during calibration.")
        return false
    end

    -- Recheck position after moving forward
    local nx, ny, nz = gps.locate()
    if not nx or not ny or not nz then
        print("GPS signal lost after calibration movement.")
        return false
    end

    -- Determine orientation based on change in coordinates
    if nx == sx + 1 then
        state.orientation = 'east'
    elseif nx == sx - 1 then
        state.orientation = 'west'
    elseif nz == sz + 1 then
        state.orientation = 'south'
    elseif nz == sz - 1 then
        state.orientation = 'north'
    else
        print("Could not determine orientation after calibration.")
        return false
    end

    -- Update turtle's current location state
    state.location = {x = nx, y = ny, z = nz}

    -- Log the movement and orientation change
    Log_movement(state.orientation)

    return true
end

-- Main startup routine
local function main()
    -- Perform calibration at startup
    print("Turtle is starting up...")
    if not Calibrate() then
        print("Calibration failed. Check position and try again.")
        return
    end

    -- Continue with other startup tasks
    print("Calibration successful. Continuing startup tasks...")
end

-- Run the main function
main()
