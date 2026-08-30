Config = {}

Config.Debug = false

-- Item given to the player when they win an item prize.
-- Make sure these items exist in your inventory.
Config.RewardItemPrefix = 'pulltab_'

-- Whether the pull tab item is removed when the player starts a game.
-- If false, you can use your own inventory handling.
Config.RemoveTabOnStart = true

-- How long a player has to finish a pull tab before the session expires.
Config.SessionTimeout = 10 * 60 -- seconds

-- Cash account: 'cash' or 'bank'
Config.DefaultMoneyAccount = 'cash'

-- Add as many pull tabs as you want.
-- image = NUI image path. Put custom images in html/images/.
--
-- Each line has its own prize table.
-- type = 'money' or 'item'
--
-- weight controls the chance within that line's prize table.
-- Example: weight 60 + 30 + 10 = 60%, 30%, 10%.
--
-- IMPORTANT:
-- Prize selection and rewards are SERVER-SIDE. The NUI never decides the reward.
Config.PullTabs = {
    ["lucky7"] = {
        item = "pulltab_lucky7",
        label = "Lucky 7 Pull Tab",
        price = 0,
        image = "images/lucky7.png",

        -- You can change this to 3, 5, 8, etc.
        lines = {
            {
                label = "Line 1",
                prizes = {
                    { type = "money", amount = 0, weight = 55 },
                    { type = "money", amount = 250, weight = 25 },
                    { type = "money", amount = 500, weight = 15 },
                    { type = "money", amount = 1000, weight = 5 },
                }
            },
            {
                label = "Line 2",
                prizes = {
                    { type = "money", amount = 0, weight = 55 },
                    { type = "money", amount = 250, weight = 25 },
                    { type = "money", amount = 750, weight = 15 },
                    { type = "money", amount = 1500, weight = 5 },
                }
            },
            {
                label = "Line 3",
                prizes = {
                    { type = "money", amount = 0, weight = 60 },
                    { type = "money", amount = 500, weight = 20 },
                    { type = "money", amount = 1000, weight = 15 },
                    { type = "money", amount = 2500, weight = 5 },
                }
            },
            {
                label = "Line 4",
                prizes = {
                    { type = "money", amount = 0, weight = 65 },
                    { type = "money", amount = 500, weight = 20 },
                    { type = "money", amount = 1500, weight = 12 },
                    { type = "money", amount = 3500, weight = 3 },
                }
            },
            {
                label = "Line 5",
                prizes = {
                    { type = "money", amount = 0, weight = 70 },
                    { type = "money", amount = 500, weight = 17 },
                    { type = "money", amount = 2000, weight = 10 },
                    { type = "money", amount = 5000, weight = 3 },
                }
            },
        }
    },

    ["bigwins"] = {
        item = "pulltab_bigwins",
        label = "Big Wins Pull Tab",
        price = 0,
        image = "images/bigwins.png",

        lines = {
            {
                label = "Line 1",
                prizes = {
                    { type = "money", amount = 0, weight = 55 },
                    { type = "money", amount = 250, weight = 25 },
                    { type = "money", amount = 500, weight = 15 },
                    { type = "money", amount = 2000, weight = 5 },
                }
            },
            {
                label = "Line 2",
                prizes = {
                    { type = "money", amount = 0, weight = 55 },
                    { type = "money", amount = 250, weight = 25 },
                    { type = "money", amount = 750, weight = 15 },
                    { type = "money", amount = 2500, weight = 5 },
                }
            },
            {
                label = "Line 3",
                prizes = {
                    { type = "money", amount = 0, weight = 60 },
                    { type = "money", amount = 500, weight = 20 },
                    { type = "money", amount = 1000, weight = 15 },
                    { type = "money", amount = 3500, weight = 5 },
                }
            },
            {
                label = "Line 4",
                prizes = {
                    { type = "money", amount = 0, weight = 65 },
                    { type = "money", amount = 500, weight = 20 },
                    { type = "money", amount = 1500, weight = 12 },
                    { type = "money", amount = 4500, weight = 3 },
                }
            },
            {
                label = "Line 5",
                prizes = {
                    { type = "money", amount = 0, weight = 70 },
                    { type = "money", amount = 500, weight = 17 },
                    { type = "money", amount = 2000, weight = 10 },
                    { type = "money", amount = 6000, weight = 3 },
                }
            },
        }
    },

    ["carshow"] = {
        item = "pulltab_carshow",
        label = "Car Show Pull Tab",
        price = 0,
        image = "images/carshow.png",

        lines = {
            {
                label = "Line 1",
                prizes = {
                    { type = "money", amount = 0, weight = 55 },
                    { type = "money", amount = 250, weight = 25 },
                    { type = "money", amount = 850, weight = 15 },
                    { type = "item", item = "pulltab_carshow", amount = 1, weight = 5 },
                }
            },
            {
                label = "Line 2",
                prizes = {
                    { type = "money", amount = 0, weight = 55 },
                    { type = "money", amount = 500, weight = 25 },
                    { type = "money", amount = 1000, weight = 15 },
                    { type = "item", item = "pulltab_carshow", amount = 1, weight = 5 },
                }
            },
            {
                label = "Line 3",
                prizes = {
                    { type = "money", amount = 0, weight = 60 },
                    { type = "money", amount = 750, weight = 20 },
                    { type = "money", amount = 1500, weight = 15 },
                    { type = "item", item = "pulltab_carshow", amount = 1, weight = 5 },
                }
            },
            {
                label = "Line 4",
                prizes = {
                    { type = "money", amount = 0, weight = 65 },
                    { type = "money", amount = 1000, weight = 20 },
                    { type = "money", amount = 2500, weight = 12 },
                    { type = "item", item = "pulltab_carshow", amount = 2, weight = 3 },
                }
            },
            {
                label = "Line 5",
                prizes = {
                    { type = "money", amount = 0, weight = 70 },
                    { type = "money", amount = 1000, weight = 17 },
                    { type = "money", amount = 2500, weight = 10 },
                    { type = "money", amount = 5000, weight = 3 },
                }
            },
        }
    }
}
