local mod_id = "Redart-Science-Randomizer-"
data:extend(
    {
        {
            type = "int-setting",
            name = mod_id .. "random-seed",
            setting_type = "startup",
            default_value = 0,
            order = "aaaa"
        },
        {
            type = "int-setting",
            name = mod_id .. "min-ingredients",
            setting_type = "startup",
            default_value = 2,
            minimum_value = 0,
            maximum_value = 30,
            order = "aaab"
        },
        {
            type = "int-setting",
            name = mod_id .. "max-ingredients",
            setting_type = "startup",
            default_value = 7,
            minimum_value = 2,
            maximum_value = 30,
            order = "aaac"
        }
    }
)
