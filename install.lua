local function copyFiles(sourceDir, destinationDir)
    for _, file in ipairs(fs.list(sourceDir)) do
        local sourcePath = fs.combine(sourceDir, file)
        local destinationPath = fs.combine(destinationDir, file)
        
        if fs.isDir(sourcePath) then
            fs.makeDir(destinationPath)
            copyFiles(sourcePath, destinationPath)
        else
            fs.copy(sourcePath, destinationPath)
        end
    end
end

local sourceDir = "disk/"
local destinationDir = "/"
copyFiles(sourceDir, destinationDir)
print("Complete.")