# Swing: Animated Lanterns and Sings.

A little OpenMW mod that procedurally animates surrounding lanterns, making them swing in the wind. 

Video preview below (click it):

[![IMAGE ALT TEXT HERE](https://img.youtube.com/vi/X-1B2kSJ0Pc/0.jpg)](https://www.youtube.com/watch?v=X-1B2kSJ0Pc)

### How to install

- Use Mod Organiser 2.

OR

Using OpenMW launcher: 
- Extract the mod as a folder somewhere (wherever you keep all your mods).
- In OpenMW launcher, add the extracted folder as a new entry in the `Data Directories` tab.

FOR BOTH:

- Activate `AnimatedLanterns.omwscripts` and `AnimatedLanterns.omwaddon` in the `Content Files` tab of the OpenMW launcher.
- Keep the `.omwaddon` file at the very bottom of your load order, or at least below other `.esm` and `.omwaddon` files. 

### Acknowledgement

Thanks to [Kildozery](https://www.nexusmods.com/profile/Kildozery/mods) for OAAB Data lantern configs.

### For developers

`Animated Lanterns and Signs` determines which lanterns to animate based on a partial match between names provided in a config file and object recordId or model name. Config files can be found in the `configs` folder. `base_lantern_config.yaml` already contains a set of configurations that detect and animate many vanilla lanterns. 

If you are using custom lanterns in your mod—they might not be picked up, but you can easily supply a config file within your mod—simply bundle a file `scripts/MaxYari/animated_lanterns/configs/your_mod_name.yaml` with your mod. Note that it does not matter what you call that file as long as it’s located in the correct directory, but try to give it a unique name that will not collide with config files from other mods.

The config also includes a way to blacklist specific lanterns from being animated by their partial record id or mesh name, as well as by a full cell id of the cell to which they belong (i.e its possible to disable a whole cell at once). For the overall config and blacklist syntax, look at `base_lantern_config.yaml`.

**Lua API**
If methods above don't work for your mod - additionally there's a Lua interface you can use to manually ask `Animated Lanterns and Signs` to process a specific collection of lanterns (their names will still be checked against configs and blacklists in yaml file!) this way you can force this mod to process a set of lanterns without waiting for a player to change cell (thats usually when all lanterns are found and processed), e.g if you dynamically placing lanterns into a cell.

```lua
local I = require("openmw.interface")
I.AnimatedLanternsAndSigns.processLanterns(list_of_lantern_objects)
```

You can also replace an existing animated lantern with a new one, preserving all animation state:

```lua
local I = require("openmw.interface")
I.AnimatedLanternsAndSigns.replaceLantern(original_lantern, new_lantern)
```

This will find the lantern data for `original_lantern` (matched by `.id`) and swap the object reference to `new_lantern`, moving the entry to the correct key in the internal lanterns map. Returns `true` on success, `false` if the original lantern was not found. Use this if you are replacing one lantern with a slightly modified copy of that lantern in realtime (e.g lit vs unlit lantern).

This interface is only available on global scripts.
