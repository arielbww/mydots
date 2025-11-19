This repository contains my personal Linux configuration files.
All directories included here correspond to programs I actively use and customize.
Feel free to clone this repository and adapt the configurations to your setup.

## Included Configurations

The following folders correspond to the respective programs:

| Folder      | Program / Purpose                               |
| ----------- | ----------------------------------------------- |
| `swaync`    | SwayNC – Notification center for Wayland        |
| `btop`      | btop – System monitor                           |
| `waybar`    | Waybar – Status bar for Wayland                 |
| `hypr`      | Hyprland – Wayland compositor                   |
| `fastfetch` | Fastfetch – System information tool             |
| `Thunar`    | Thunar – File manager                           |
| `nvim`      | Neovim – Text editor                            |
| `cava`      | Cava – Audio visualizer                         |
| `kitty`     | Kitty – Terminal emulator                       |
| `wofi`      | Wofi – Application launcher for Wayland         |
| `pywal`     | Pywal – Generates color schemes from wallpapers |

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
* **Pywal**

Depending on your distribution, additional packages such as themes, icons, and fonts may be required.

---

# How to Clone & Install

Clone the repository:

```bash
git clone https://github.com/arielbww/mydots.git ~/mydots
```

Enter the directory:

```bash
cd ~/mydots
```

Before installing, **back up your existing configs**:

```bash
mv ~/.config/kitty ~/.config/kitty.backup 2>/dev/null
mv ~/.config/waybar ~/.config/waybar.backup 2>/dev/null
mv ~/.config/hypr ~/.config/hypr.backup 2>/dev/null
```

---

## Option 1 — Copy manually

```bash
cp -r kitty ~/.config/
cp -r waybar ~/.config/
cp -r hypr ~/.config/
```

---

## Option 2 — Create symlinks (recommended)

Remove any old folders:

```bash
rm -rf ~/.config/kitty ~/.config/waybar ~/.config/hypr
```

Create symlinks:

```bash
ln -s ~/mydots/kitty ~/.config/kitty
ln -s ~/mydots/waybar ~/.config/waybar
ln -s ~/mydots/hypr ~/.config/hypr
ln -s ~/mydots/pywal ~/.config/pywal
```

---

## Option 3 — Using GNU Stow (best for maintaining dotfiles)

Install Stow:

```bash
sudo pacman -S stow   # Arch-based
```

In the repository root:

```bash
stow .
```

This automatically creates the correct symlinks inside `~/.config`.

To remove a config:

```bash
stow -D kitty
```

---

## Notes

* Always back up your configs before replacing them.
* Some scripts may require execution permissions:

```bash
chmod +x ~/.config/waybar/scripts/*
```

* Pywal integration may require updating specific config files to load generated colors.
* Configurations are optimized for a Wayland + Hyprland environment and may require adjustments depending on your distribution or hardware.

Só pedir!
