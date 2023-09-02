local mod_id = "Redart-Science-Randomizer-"
data:extend(
    {
        {
            type = "int-setting",
            name = mod_id .. "random-seed",
            setting_type = "startup",
            default_value = 0,
            minimum_value = 0,
            order = "aaaa"
        },
        {
            type = "bool-setting",
            name = mod_id .. "allow-raw",
            setting_type = "startup",
            default_value = false,
            order = "aaba"
        },
        {
            type = "bool-setting",
            name = mod_id .. "allow-fluid",
            setting_type = "startup",
            default_value = false,
            order = "aabb"
        },
        {
            type = "bool-setting",
            name = mod_id .. "allow-science",
            setting_type = "startup",
            default_value = false,
            order = "aabc"
        },
        {
            type = "bool-setting",
            name = mod_id .. "allow-grown",
            setting_type = "startup",
            default_value = false,
            order = "aabd"
        },
        {
            type = "bool-setting",
            name = mod_id .. "balanced",
            setting_type = "startup",
            default_value = true,
            order = "aabd"
        },
        {
            type = "bool-setting",
            name = mod_id .. "in-tier",
            setting_type = "startup",
            default_value = true,
            order = "aabd"
        },
        {
            type = "string-setting",
            name = mod_id .. "set-packs",
            setting_type = "startup",
            default_value = "",
            allow_blank = true,
            allow_trim = true,
            hidden = true,
            order = "aaab"
        },
    }
)
