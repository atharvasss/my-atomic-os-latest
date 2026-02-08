# 🧊 Fedora Silverblue Atomic Setup

### 🎮 Steam (Flatpak) • 💻 Desktop • 🛠️ Developer Workflow

A **Fedora Silverblue / Atomic** setup optimized for **immutable workflows**, **high-performance gaming**, and **containerized development**.

---

## 🚀 Post-Installation Setup

After installing **Fedora Silverblue (Atomic)**, follow these steps to switch to the custom image and complete the setup.

---

### 1️⃣ Rebase to the Custom Image

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/atharvasss/my-atomic-os:latest
```

> ⚠️ **Reboot required** after the rebase completes.

---

### 2️⃣ Verify the Deployment

```bash
rpm-ostree status
```

Ensure a **●** appears next to:

```
ghcr.io/atharvasss/my-atomic-os
```

---

### 3️⃣ System Updates & Maintenance

**Check for updates**

```bash
rpm-ostree update
```

**Apply updates**

```bash
rpm-ostree upgrade
```

**Rollback if something breaks**

```bash
rpm-ostree rollback
```

---

## 🏗️ Base Image

```dockerfile
FROM quay.io/fedora/fedora-silverblue:43
```

**Image behavior**

* Disables the broken Fedora 43 `updates-archive` repo
* Installs essential host tools
* Configures Docker
* Runs a **one-time Flatpak automation script** on first login

---

## 🛠️ Layered System Packages (rpm-ostree)

Installed directly on the host for deep integration:

**Monitoring**

* `nvtop`

**UI / UX**

* `gnome-tweaks`
* `nautilus-python`

**Development**

* `git`
* `distrobox`
* `moby-engine` (Docker)
* `docker-compose`

**CLI Utilities**

* `fzf`

---

## ⚡ Automatic First-Login Setup

A **one-time per-user autostart script** configures the desktop automatically.

### 📦 Flatpak Apps Installed

**Media**

* Spotify 🎵
* VLC 🎬

**Web**

* Zen Browser 🌐

**Office / Dev**

* ONLYOFFICE 📝
* Zed Editor ✏️

**Utilities**

* Flatseal 🔧
* Extension Manager 🧩
* Déjà Dup 💾
* Discord 💬

### 🖥️ Desktop Defaults

* **Editor:** Zed
* **File Manager:** Nautilus
* **Browser:** Zen Browser
* **CLI:** `zed` launcher added to `~/.local/bin`
* **Marker File:** `~/.flatpak-setup-done` (prevents re-run)

---

## 🖥️ Global Shell Aliases

Available system-wide:

```bash
z       # Open Zed in the current directory
clean   # Remove unused Flatpaks and runtimes
```

---

## 🎮 Steam Setup (Flatpak)

> ⚠️ **Manual configuration required inside Steam**
> You must enable **Steam Play for all titles** and **Shader Pre-Caching**.

---

### 1️⃣ Enable Flathub

```bash
flatpak remote-add --if-not-exists flathub \
https://flathub.org/repo/flathub.flatpakrepo
```

---

### 2️⃣ Install Steam (Flatpak Only)

```bash
flatpak install -y flathub com.valvesoftware.Steam
```

---

### 3️⃣ Install Steam Runtimes & Proton

Fixes Steamworks SDK / SteamClient errors.

```bash
flatpak install -y flathub \
com.valvesoftware.Steam.CompatibilityTool.SteamLinuxRuntime \
com.valvesoftware.Steam.CompatibilityTool.Proton
```

---

### 4️⃣ Grant Required Permissions

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

Let Steam fully update before continuing.

---

### 6️⃣ Configure Steam (Inside App) ⚙️

1. **Settings → Compatibility**
   Enable **Steam Play for all titles**
2. **Settings → Shader Pre-Caching**
   Enable
3. **Restart Steam**

---

## 📝 Notes & Workflow

* 🧊 **Immutable-first:** Keep the base image clean
* 📦 Prefer **Flatpaks** for apps
* 🐳 Use **Distrobox** for mutable dev environments
* 🔐 Manage Flatpak permissions with **Flatseal**

---
