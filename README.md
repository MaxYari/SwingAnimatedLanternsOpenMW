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

### For developers

`Swing` determines which lanterns to animate based on a partial match between names provided in a config file and object recordId or model name. Config files can be found in the `configs` folder. `base_lantern_config.yaml` already contains a set of configurations that detect and animate many vanilla lanterns. 

If you are using custom lanterns in your mod—they might not be picked up, but you can easily supply a config file within your mod—simply bundle a file `scripts/MaxYari/animated_lanterns/configs/your_mod_name.yaml` with your mod. Note that it does not matter what you call that file as long as it’s located in the correct directory, but try to give it a unique name that will not collide with config files from other mods.

The config also includes a way to blacklist specific lanterns from being animated. For the overall config syntax, look at `base_lantern_config.yaml`.
