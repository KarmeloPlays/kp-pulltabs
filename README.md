# KP Pull Tabs

<img width="1920" height="1080" alt="kppulltabs" src="https://github.com/user-attachments/assets/b9a5723d-3622-435d-91d5-54cf2afddd61" />

A QBCore pull-tab gambling resource with:

- Custom pull-tab images
- Multiple pull lines per ticket
- Player must physically drag/pull each line
- Server-side weighted prize selection
- Item or Money prizes
- Multiple different pull-tab types
- Configurable odds and line numbers

## Installation

1. Put `kp-pulltabs` in your resources folder.
2. Add this to `server.cfg`:

```cfg
ensure kp-pulltabs
```

3. Add the pull-tab items to your QBCore shared items.

Example:

```lua
['pulltab_lucky7'] = {
    name = 'pulltab_lucky7',
    label = 'Lucky 7 Pull Tab',
    weight = 50,
    type = 'item',
    image = 'pulltab_lucky7.png',
    unique = false,
    useable = true,
    shouldClose = true,
    description = 'A Lucky 7 pull tab.'
},

['pulltab_bigwins'] = {
    name = 'pulltab_bigwins',
    label = 'Big Wins Pull Tab',
    weight = 50,
    type = 'item',
    image = 'pulltab_bigwins.png',
    unique = false,
    useable = true,
    shouldClose = true,
    description = 'A Big Wins pull tab.'
},

['pulltab_carshow'] = {
    name = 'pulltab_carshow',
    label = 'Car Show Pull Tab',
    weight = 50,
    type = 'item',
    image = 'pulltab_carshow.png',
    unique = false,
    useable = true,
    shouldClose = true,
    description = 'A Car Show pull tab.'
},
```

4. Put your inventory item images in the normal QBCore inventory image folder.
5. Put your pull-tab UI images inside:

`kp-pulltabs/html/images/`

6. Change the images and prizes in `config.lua`.

## Prize configuration

Money:

```lua
{
    type = "money",
    amount = 5000,
    weight = 20
}
```

Money to bank:

```lua
{
    type = "money",
    amount = 5000,
    account = "bank",
    weight = 20
}
```

Item:

```lua
{
    type = "item",
    item = "repairkit",
    amount = 1,
    weight = 10
}
```

## Odds

Weights are relative.

For:

```lua
weight = 60
weight = 30
weight = 10
```

the approximate chances are:

- 60%
- 30%
- 10%

The actual random result is selected on the server.

## How it works

The player uses a pull-tab item.

The server removes one ticket and creates a server-side session.

The player must pull Line 1, then Line 2, then Line 3, etc.

The server chooses the prize when that line is pulled and awards it immediately.

The NUI only displays the result; it does not control the reward.

## Important

The default script does NOT refund a ticket if the player closes the UI early. This is intentional so players cannot open/close tickets to manipulate the gambling system.

If you want a different ticket/session behavior, change the server logic before going live.
