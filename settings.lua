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
    }
)
