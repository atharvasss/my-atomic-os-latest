# ⚛️ ATOMIC OS

**Performance. Stability. Automation.**

Atomic OS is a customized, immutable Fedora Silverblue 43 image designed to eliminate setup time. It delivers a "just works" experience for developers and gamers by automating application deployment, system optimization, and environment configuration.

---

### 🚀 Deployment Guide

#### 1. Switch to this Image

If you are already on Fedora Silverblue, run the following to rebase to this image:

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/atharvasss/my-atomic-os-latest:latest

```

#### 2. Local Build (For Developers)

To customize and build this image locally using Podman:

```bash
# Clone the repo
git clone https://github.com/atharvasss/my-atomic-os-latest.git
cd my-atomic-os-latest

# Build the image
podman build -t my-atomic-os .

```

---

### 🎮 Gaming & Graphics

Atomic OS is pre-tuned for a high-performance gaming experience out of the box.

* **Vulkan Ready:** Includes `vulkan-tools` and `steam-devices` (udev rules) pre-installed on the host.
* **Performance Monitoring:** `nvtop` for GPU tracking and `mangohud` for in-game overlays.
* **Gaming Suite:** Steam and Bottles are automatically deployed as Flatpaks on your first login.

---

### 🛠️ Custom Commands & Workflow

This image includes built-in automation and shortcuts to keep your workflow fast.

**System Maintenance**

* `clean`: Alias to remove unused Flatpak runtimes and data.
* `rpm-ostree upgrade`: Check for system-level atomic updates.
* `auto-setup-apps`: The logic that triggers the automated Flatpak installation (run manually if needed).

**Developer Workflow**

* `z`: Opens the current directory in **Zed Editor**.
* `distrobox create -n dev`: Create a mutable development container for your specific language needs.
* `docker-compose up -d`: Native Docker support via `moby-engine`.

---

### 📦 Manifest

| Category | Features |
| --- | --- |
| **OS Core** | Fedora Silverblue 43 (Immutable), GNOME Tweaks |
| **Host Tools** | Git, fzf, Moby-Engine (Docker), Docker-Compose, Distrobox |
| **Gaming** | Steam, Bottles, MangoHud, nvtop, Vulkan-Tools |
| **Flatpaks** | Zen Browser, Zed, Discord, Spotify, VLC, OnlyOffice, Flatseal |
| **Optimizations** | Automated setup script, `updates-archive` repair, Console UI cleanup |

---

### 💡 How the Automation Works

Upon your first login after rebasing, a background script (`auto-setup-apps`) will trigger. It:

1. Adds the Flathub repository to your user space.
2. Installs the curated list of productivity and gaming apps.
3. Sets **Zed** as your default text and folder handler.
4. Creates a persistent `zed` binary in your local path.
