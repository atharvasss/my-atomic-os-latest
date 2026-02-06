# ⚛️ ATOMIC OS

**Performance. Stability. Automation.**

Atomic OS is a customized, immutable Fedora Silverblue 43 image designed to eliminate setup time. It delivers a "just works" experience for developers and gamers by automating application deployment and system optimization.

---

### 🚀 Deployment Guide

#### 1. Switch to this Image

If you are already on Fedora Silverblue, run the following to rebase:

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

### 🎮 Gaming Support

Atomic OS comes pre-configured with a "Game-Ready" stack, reducing the friction usually found in immutable systems.

* **Pre-installed Hubs:** Steam, Heroic Games Launcher (Epic/GOG), and Bottles are ready out of the box.
* **Performance Overlays:** Includes `mangohud` for real-time FPS and hardware monitoring.
* **System Tweaks:** * **GameMode:** Integrated `gamemode` to request CPU/GPU priority during play.
* **Kernel Optimizations:** Pre-applied `split_lock_detect=off` kernel argument to prevent stutters/crashes in heavy titles and anti-cheat software.
* **Latency Reduction:** Tweaked `zram` and `swappiness` levels for better memory management under heavy loads.



---

### 🛠️ Post-Install Commands

Once you reboot into Atomic OS, the system handles the heavy lifting. Here is how to interact with it:

**System Maintenance**

* `rpm-ostree upgrade`: Check for system-level updates.
* `clean`: Removes unused Flatpak runtimes and data.
* `auto-setup-apps`: Force-run the automated app installer (Spotify, Steam, etc.).

**Developer Workflow**

* `z`: Opens the current directory in **Zed Editor**.
* `distrobox create -n dev`: Create a mutable development container.
* `docker-compose up -d`: Launch your local stack immediately.

**Performance Monitoring**

* `nvtop`: Check your GPU usage and temps.
* `mangohud <game>`: Launch games with the performance overlay (e.g., `mangohud steam`).

---

### 📦 Manifest

| Category | Features |
| --- | --- |
| **System** | Fedora Silverblue 43 (Immutable), GNOME Tweaks |
| **Tools** | Git, fzf, Moby-Engine (Docker), Distrobox |
| **Apps** | Zen Browser, Zed, Discord, Spotify, Steam, Bottles |
| **Gaming** | MangoHud, GameMode, Proton-GE (via auto-setup) |
| **Fixes** | Automated Fedora updates-archive repair, Non-free Codecs |
