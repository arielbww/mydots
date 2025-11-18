This repository contains my personal Linux configuration files.
All directories included here correspond to programs I actively use and customize.
Feel free to clone this repository and adapt the configurations to your setup.

## Included Configurations

The following folders correspond to the respective programs:

| Folder      | Program / Purpose                              |
| ----------- | ---------------------------------------------- |
| `swaync`    | SwayNC – Notification center for Wayland       |
| `btop`      | btop – System monitor                          |
| `waybar`    | Waybar – Status bar for Wayland                |
| `hypr`      | Hyprland – Wayland compositor                  |
| `fastfetch` | Fastfetch – System information tool            |
| `Thunar`    | Thunar – File manager                          |
| `nvim`      | Neovim – Text editor                           |
| `cava`      | Cava – Audio visualizer                        |
| `kitty`     | Kitty – Terminal emulator                      |
| `wofi`      | Wofi – Application launcher / menu for Wayland |

## Dependencies

To fully use these dotfiles, install the following programs:

* **Hyprland**
* **Waybar**
* **SwayNC**
* **Wofi**
* **Kitty**
* **Neovim**
* **Cava**
* **Fastfetch**
* **Thunar**
* **btop**

Depending on your distribution, additional packages like themes, icons, and fonts may be required.

## How to Clone

Clone the repository:

```bash
git clone https://github.com/arielbww/mydots.git
```

Enter the directory:

```bash
cd mydots
```

You may copy the config folders manually into `$HOME/.config`, or create symlinks for a cleaner setup.

Example using symlinks:

```bash
ln -s ~/mydots/kitty ~/.config/kitty
ln -s ~/mydots/waybar ~/.config/waybar
ln -s ~/mydots/wofi ~/.config/wofi
```

## Notes

* Always back up your current configs before replacing them.
* These configurations are optimized for a Wayland + Hyprland environment.
* Some adjustments may be necessary depending on your distribution or hardware.


