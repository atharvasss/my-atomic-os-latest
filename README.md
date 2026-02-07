
# Fedora Silverblue Atomic Setup
## 🎮 Steam (Flatpak) + 💻 Desktop & Developer Configuration

This repository provides a **Fedora Silverblue / Atomic** setup optimized for immutable workflows, high-performance gaming, and containerized development.

---

## 🚀 Post-Installation Setup

Once you have installed Fedora Atomic Silverblue, follow these steps to switch to this custom image and optimize your setup.

### 1️⃣ Rebase to this Image
To switch your system from the default Fedora image to this custom build, run the following command in your terminal:

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/atharvasss/my-atomic-os:latest

```

> ⚠️ **Note:** After the process completes, restart your computer to boot into the new image.

### 2️⃣ Verify the Installation

After rebooting, verify that you are running the correct deployment:

```bash
rpm-ostree status

```

Look for the dot (**●**) next to the `ghcr.io/atharvasss/my-atomic-os` entry.

### 3️⃣ System Maintenance

To keep your system and apps updated in the future, you only need one command:

* **Update everything:**
```bash
rpm-ostree upgrade

```


* **Rollback if something breaks:** If an update causes issues, you can instantly revert to your previous working state:
```bash
rpm-ostree rollback

```



---

## 🏗️ Base Image Details

```dockerfile
FROM quay.io/fedora/fedora-silverblue:43

```

This image disables the broken Fedora 43 updates-archive repo, installs host tools, sets up Docker, and includes a one-time automation script for Flatpak apps.

---

## 🛠️ Layered System Packages

Installed via `rpm-ostree` for deep system integration:

* **Monitoring:** `nvtop` (GPU monitoring)
* **UI/UX:** `gnome-tweaks`, `nautilus-python`
* **Development:** `git`, `distrobox`, `moby-engine` (Docker), `docker-compose`
* **CLI Tools:** `fzf`

---

## ⚡ Automatic First Login Setup

On first login, a **one-time autostart script** runs per user to set up your environment automatically.

### Flatpak Apps Installed Automatically

* **Media:** Spotify 🎵, VLC 🎬
* **Web:** Zen Browser 🌐
* **Office/Dev:** ONLYOFFICE 📝, Zed Editor ✏️
* **Utility:** Flatseal 🔧, Extension Manager 🧩, Déjà Dup 💾, Discord 💬

### Desktop Defaults

* **Default Editor:** Zed
* **Default File Manager:** Nautilus
* **Default Web Browser:** Zen Browser
* **CLI:** Adds `zed` launcher to `~/.local/bin`
* **Marker File:** Prevents re-running via `~/.flatpak-setup-done`

---

## 🖥️ Global Shell Aliases

Available system-wide for convenience:

```bash
z       # Open Zed in current directory
clean   # Remove unused Flatpaks and runtimes

```

---

## 🎮 Steam Setup Guide (Flatpak)

> ⚠️ **Manual Steam Settings Required:** Some steps must be done manually inside Steam after installation. You will need to enable **Steam Play for all titles** and **Shader Pre-Caching**.

### 1️⃣ Install Steam & Runtimes

To fix SteamClient / Steamworks SDK errors, run this command:

```bash
flatpak install -y flathub com.valvesoftware.Steam \
com.valvesoftware.Steam.CompatibilityTool.SteamLinuxRuntime \
com.valvesoftware.Steam.CompatibilityTool.Proton

```

### 2️⃣ Set Flatpak Permissions for Steam

```bash
flatpak override --user \
--filesystem=home \
--filesystem=xdg-data/Steam \
--device=all \
--share=network \
com.valvesoftware.Steam

```

### 3️⃣ Configure Steam Manually ⚙️

Inside the Steam application:

1. **Settings → Compatibility:** Enable *Steam Play for all titles*.
2. **Settings → Shader Pre-Caching:** Enable.
3. **Restart Steam.**

---

## 📝 Notes & Workflow

* **Immutable-friendly:** Keep the base image clean; prefer Flatpak installs.
* **Development:** Use **Distrobox** for mutable development environments.
* **Permissions:** Use **Flatseal** to manage Flatpak permissions.

```

```
