local library = {} 
local windowCount = 0 
local sizes = {} 
local listOffset = {} 
local windows = {} 
local dropdowns = {} 
local colorPickers = {} 

-- [[ UTILS: ฟังก์ชันเสริม ]]
local function AddCorner(obj, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 6)
    corner.Parent = obj
end

local function Dragify(obj)
    local UIS = game:GetService("UserInputService")
    local dragToggle = nil
    local dragStart = nil
    local startPos = nil

    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragToggle = true
            dragStart = input.Position
            startPos = obj.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragToggle = false
                end
            end)
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if dragToggle then
                local delta = input.Position - dragStart
                obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end
    end)
end

-- [[ MAIN LIBRARY ]]
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ModernUiLib"
ScreenGui.Parent = game.CoreGui

function library:Window(name, themeColor)
    local themeColor = themeColor or Color3.fromRGB(0, 168, 255)
    windowCount = windowCount + 1
    local winCount = windowCount
    local zindex = winCount * 10

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = name .. "_Window"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0, 20 + (winCount-1)*230, 0, 50)
    MainFrame.Size = UDim2.new(0, 210, 0, 35)
    MainFrame.ClipsDescendants = true
    AddCorner(MainFrame, 8)
    Dragify(MainFrame)

    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Parent = MainFrame
    Header.BackgroundColor3 = themeColor
    Header.Size = UDim2.new(1, 0, 0, 35)
    AddCorner(Header, 8)

    local Title = Instance.new("TextLabel")
    Title.Parent = Header
    Title.BackgroundTransparency = 1
    Title.Size = UDim2.new(1, 0, 1, 0)
    Title.Font = Enum.Font.GothamBold
    Title.Text = name
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 14

    local Container = Instance.new("Frame")
    Container.Name = "Container"
    Container.Parent = MainFrame
    Container.BackgroundTransparency = 1
    Container.Position = UDim2.new(0, 0, 0, 40)
    Container.Size = UDim2.new(1, 0, 1, -40)

    local UIList = Instance.new("UIListLayout")
    UIList.Parent = Container
    UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    UIList.Padding = UDim.new(0, 5)
    UIList.SortOrder = Enum.SortOrder.LayoutOrder

    local function Resize()
        MainFrame.Size = UDim2.new(0, 210, 0, UIList.AbsoluteContentSize.Y + 50)
    end
    UIList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(Resize)

    local elements = {}

    -- 1. Label
    function elements:Label(txt)
        local Label = Instance.new("TextLabel")
        Label.Parent = Container
        Label.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        Label.Size = UDim2.new(0, 190, 0, 25)
        Label.Font = Enum.Font.Gotham
        Label.Text = txt
        Label.TextColor3 = Color3.fromRGB(200, 200, 200)
        Label.TextSize = 12
        AddCorner(Label, 4)
        return Label
    end

    -- 2. Button
    function elements:Button(txt, callback)
        local Btn = Instance.new("TextButton")
        Btn.Parent = Container
        Btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        Btn.Size = UDim2.new(0, 190, 0, 30)
        Btn.Font = Enum.Font.GothamMedium
        Btn.Text = txt
        Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        Btn.TextSize = 13
        Btn.AutoButtonColor = true
        AddCorner(Btn, 6)
        
        Btn.MouseButton1Click:Connect(function()
            Btn.BackgroundColor3 = themeColor
            callback()
            task.wait(0.1)
            Btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        end)
    end

    -- 3. Toggle
    function elements:Toggle(txt, default, callback)
        local state = default or false
        local TglBtn = Instance.new("TextButton")
        TglBtn.Parent = Container
        TglBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        TglBtn.Size = UDim2.new(0, 190, 0, 30)
        TglBtn.Text = "  " .. txt
        TglBtn.Font = Enum.Font.Gotham
        TglBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        TglBtn.TextSize = 13
        TglBtn.TextXAlignment = Enum.TextXAlignment.Left
        AddCorner(TglBtn, 6)

        local Indicator = Instance.new("Frame")
        Indicator.Parent = TglBtn
        Indicator.Position = UDim2.new(1, -28, 0.5, -9)
        Indicator.Size = UDim2.new(0, 18, 0, 18)
        Indicator.BackgroundColor3 = state and themeColor or Color3.fromRGB(80, 80, 80)
        AddCorner(Indicator, 4)

        TglBtn.MouseButton1Click:Connect(function()
            state = not state
            Indicator.BackgroundColor3 = state and themeColor or Color3.fromRGB(80, 80, 80)
            callback(state)
        end)
    end

    -- 4. Slider
    function elements:Slider(txt, min, max, default, callback)
        local SliderFrame = Instance.new("Frame")
        SliderFrame.Parent = Container
        SliderFrame.Size = UDim2.new(0, 190, 0, 45)
        SliderFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        AddCorner(SliderFrame, 6)

        local Label = Instance.new("TextLabel")
        Label.Parent = SliderFrame
        Label.BackgroundTransparency = 1
        Label.Position = UDim2.new(0, 10, 0, 5)
        Label.Size = UDim2.new(1, -20, 0, 15)
        Label.Font = Enum.Font.Gotham
        Label.Text = txt .. ": " .. default
        Label.TextColor3 = Color3.fromRGB(255, 255, 255)
        Label.TextSize = 11
        Label.TextXAlignment = Enum.TextXAlignment.Left

        local Background = Instance.new("Frame")
        Background.Parent = SliderFrame
        Background.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        Background.Position = UDim2.new(0, 10, 0, 28)
        Background.Size = UDim2.new(1, -20, 0, 6)
        AddCorner(Background, 3)

        local Fill = Instance.new("Frame")
        Fill.Parent = Background
        Fill.BackgroundColor3 = themeColor
        Fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
        AddCorner(Fill, 3)

        local function Update(input)
            local pos = math.clamp((input.Position.X - Background.AbsolutePosition.X) / Background.AbsoluteSize.X, 0, 1)
            local val = math.floor(min + (max - min) * pos)
            Fill.Size = UDim2.new(pos, 0, 1, 0)
            Label.Text = txt .. ": " .. val
            callback(val)
        end

        Background.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local conn
                conn = game:GetService("RunService").RenderStepped:Connect(function()
                    if game:GetService("UserInputService"):IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                        Update(game:GetService("UserInputService"):GetMouseLocation())
                    else
                        conn:Disconnect()
                    end
                end)
            end
        end)
    end

    -- 5. TextBox (Box)
    function elements:Box(placeholder, callback)
        local Box = Instance.new("TextBox")
        Box.Parent = Container
        Box.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        Box.Size = UDim2.new(0, 190, 0, 30)
        Box.Font = Enum.Font.Gotham
        Box.PlaceholderText = placeholder or "Enter text..."
        Box.Text = ""
        Box.TextColor3 = Color3.fromRGB(255, 255, 255)
        Box.TextSize = 13
        AddCorner(Box, 6)
        
        Box.FocusLost:Connect(function()
            callback(Box.Text)
        end)
    end

    -- 6. Dropdown (Simplified)
    function elements:Dropdown(txt, list, callback)
        local Drp = Instance.new("TextButton")
        Drp.Parent = Container
        Drp.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        Drp.Size = UDim2.new(0, 190, 0, 30)
        Drp.Font = Enum.Font.Gotham
        Drp.Text = txt .. " >"
        Drp.TextColor3 = Color3.fromRGB(255, 255, 255)
        AddCorner(Drp, 6)
        -- (Logic สำหรับการกาง List สามารถเขียนเพิ่มเป็น Frame ใหม่ที่โผล่ออกมาได้)
    end

    return elements
end

return library
