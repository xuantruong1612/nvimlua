local wezterm = require("wezterm")
local config = wezterm.config_builder()

--config.window_decorations = "RESIZE"

config.enable_tab_bar = false
config.initial_cols = 105  -- rộng
config.initial_rows = 25   -- cao
config.window_background_image_hsb = {
    brightness = 0.05,
    hue = 1.0,
    saturation = 0.7,
}

local user_home = os.getenv("USERPROFILE")  -- Lấy đường dẫn thư mục user trên Windows
local background_folder = user_home .. "\\wezterm\\bg"  -- Đường dẫn đúng trên Windows

local function get_background_images(folder)
    local handle = io.popen('dir /b "' .. folder .. '"')  -- Sử dụng dir /b trên Windows
    if not handle then return {} end
    
    local files = handle:read("*a")
    handle:close()
    
    local images = {}
    for file in string.gmatch(files, "[^\r\n]+") do  -- Xử lý dòng trên Windows
        table.insert(images, folder .. "\\" .. file)  -- Ghép đường dẫn hợp lệ
    end
    return images
end

local images = get_background_images(background_folder)
table.sort(images) -- Sắp xếp danh sách ảnh để đảm bảo thứ tự cố định
local image_index = 1

local function get_next_background()
    if #images == 0 then
        return nil
    end
    local background = images[image_index]
    image_index = (image_index % #images) + 1
    return background
end

-- Chọn ảnh nền ngẫu nhiên khi khởi động
if #images > 0 then
    math.randomseed(os.time())
    config.window_background_image = images[math.random(#images)]
    wezterm.log_info("Đã thiết lập hình nền ban đầu: " .. config.window_background_image)
else
    wezterm.log_error("Không tìm thấy hình nền để thiết lập khi khởi động")
end

config.keys = {
    {
        key = "b",
        mods = "CTRL|SHIFT",
        action = wezterm.action_callback(function(window, pane)
            local new_background = get_next_background()
            if new_background then
                window:set_config_overrides({
                    window_background_image = new_background,
                })
                wezterm.log_info("Hình nền mới: " .. new_background)
            else
                wezterm.log_error("Không thể tìm thấy hình nền")
            end
        end),
    },
}

return config
