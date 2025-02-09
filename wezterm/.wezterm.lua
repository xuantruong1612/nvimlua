local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.enable_tab_bar = false
--config.window_decorations = "RESIZE"

config.window_background_opacity = 0.8

config.window_background_image_hsb = {
    brightness = 0.05,
    hue = 1.0,
    saturation = 0.7,
}

-- Đường dẫn tới thư mục chứa hình nền
local user_home = os.getenv("HOME")
local background_folder = user_home .. "/.config/nvim/bg"

local function pick_random_background(folder)
    local handle = io.popen('ls "' .. folder .. '"')
    local files = handle:read("*a")
    handle:close()

    local images = {}
    for file in string.gmatch(files, "[^\n]+") do
        table.insert(images, file)
    end

    if #images > 0 then
        return folder .. "/" .. images[math.random(#images)]
    else
        return nil
    end
end

-- nền khi mở WezTerm
local initial_background = pick_random_background(background_folder)
if initial_background then
    config.window_background_image = initial_background
    wezterm.log_info("Đã thiết lập hình nền ban đầu: " .. initial_background)
else
    wezterm.log_error("Không tìm thấy hình nền để thiết lập khi khởi động")
end

-- phím tắt 
config.keys = {
    {
        key = "b",
        mods = "CTRL|SHIFT",
        action = wezterm.action_callback(function(window, pane)
            local new_background = pick_random_background(background_folder)
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
