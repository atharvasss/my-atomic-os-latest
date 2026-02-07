# Fedora Silverblue Atomic Setup
## Steam (Flatpak) + Desktop & Developer Configuration

This repository provides a **Fedora Silverblue / Atomic** setup optimized for:

- Immutable OS workflows (`rpm-ostree`)
- Flatpak-first desktop applications
- Steam (Flatpak only) with Proton
- Docker / Distrobox development
- Clean GNOME defaults and quality-of-life tweaks

---

## Base Image

```dockerfile
FROM quay.io/fedora/fedora-silverblue:43
```

This image disables the broken Fedora 43 updates-archive repo, installs host tools, sets up Docker, and includes a one-time automation script for Flatpak apps.

---

## System Update (Required) 🔄

After booting the image:

```bash
rpm-ostree upgrade
systemctl reboot
```

Always reboot after an OSTree upgrade.

---

## Layered System Packages 🛠️

Installed via `rpm-ostree`:

- `nvtop` – GPU monitoring
- `gnome-tweaks`
- `git`
- `nautilus-python`
- `fzf`
- `distrobox`
- `moby-engine` (Docker)
- `docker-compose`

Docker group is created automatically.

---

## Automatic First Login Setup 🚀

On first login, a **one-time autostart script** runs per user.

### Flatpak Apps Installed Automatically

- Spotify 🎵  
- Zen Browser 🌐  
- VLC 🎬  
- ONLYOFFICE 📝  
- Zed Editor ✏️  
- Flatseal 🔧  
- Extension Manager 🧩  
- Déjà Dup 💾  
- Discord 💬  

### Desktop Defaults

- Default editor: **Zed**  
- Default file manager: **Nautilus**  
- Default web browser: **Zen Browser**  
- Adds `zed` launcher to `~/.local/bin`  

Marker file prevents re-running:

```text
~/.flatpak-setup-done
```

---

## Global Shell Aliases 🖥️

Available system-wide:

```bash
z        # Open Zed in current directory
clean    # Remove unused Flatpaks
```

---

# 🎮 Steam Setup Guide (Flatpak)

> ⚠️ **Manual Steam Settings Required:** Some steps must be done manually inside Steam after installation.  
> You will need to enable **Steam Play for all titles** and **Shader Pre-Caching**.

---

### 1️⃣ Enable Flathub

```bash
flatpak remote-add --if-not-exists flathub \
https://flathub.org/repo/flathub.flatpakrepo
```

---

### 2️⃣ Install Steam

```bash
flatpak install -y flathub com.valvesoftware.Steam
```

---

### 3️⃣ Install Steam Runtimes and Proton ⚠️ (Manual Step)

To fix SteamClient / Steamworks SDK errors, run **manually**:

```bash
flatpak install -y flathub \
com.valvesoftware.Steam.CompatibilityTool.SteamLinuxRuntime \
com.valvesoftware.Steam.CompatibilityTool.Proton
```

> ⚠️ Steam requires user approval for runtime installations and Proton versions.

---

### 4️⃣ Set Flatpak Permissions for Steam 🔑

```bash
flatpak override --user \
--filesystem=home \
--filesystem=xdg-data/Steam \
--device=all \
--share=network \
com.valvesoftware.Steam
```

---

### 5️⃣ Launch Steam

```bash
flatpak run com.valvesoftware.Steam
```

---

### 6️⃣ Configure Steam Manually ⚙️

Inside Steam, do the following:

1. **Settings → Compatibility**  
   - Enable *Steam Play for all titles*  
2. **Settings → Shader Pre-Caching**  
   - Enable  

Restart Steam after applying changes.

---

## Notes 📝

- Flatpak-first design  
- Immutable-friendly configuration  
- Minimal system layering  
- Docker-ready for development  
- Steam + Proton fully supported  

---

## Recommended Workflow ✅

- Use **Distrobox** for mutable development environments  
- Use **Flatseal** to manage Flatpak permissions  
- Keep the base image clean; prefer Flatpak installs
