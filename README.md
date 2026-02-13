# ⚛️ Fedora Silverblue Atomic Setup

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

# 🎮 Steam Setup (Flatpak) – Fedora Atomic Silverblue

> ⚠️ **Manual configuration required inside Steam**
> You must enable **Steam Play for all titles** and configure **Shader Cache settings** after installation.

---

## 1️⃣ Enable Flathub

```bash
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
```

---

## 2️⃣ Install Steam (Flatpak)
Bash


```bash
flatpak install -y flathub com.valvesoftware.Steam && \
rpm-ostree install steam-devices

```

> ✅ Proton and Steam Linux Runtime are downloaded automatically by Steam.
> 
> ⚠️ Reboot Required: You must restart your system for the steam-devices rules to allow controller/VR detection.

---

## 3️⃣ (Optional) Fix Missing Runtime / Compatibility Tool Errors

Only run this if Steam reports missing runtime or compatibility tool errors:

```bash
flatpak install -y flathub \
com.valvesoftware.Steam.CompatibilityTool.SteamLinuxRuntime \
com.valvesoftware.Steam.CompatibilityTool.Proton
```

---

## 4️⃣ (Optional) Grant Additional Permissions

Steam works out of the box for most users.

If you experience controller, drive access, or GPU issues, apply:

```bash
flatpak override --user \
--filesystem=xdg-data/Steam \
com.valvesoftware.Steam
```

> ⚠️ Avoid `--device=all` and full home access unless troubleshooting specific hardware issues.

---

## 5️⃣ Launch Steam

```bash
flatpak run com.valvesoftware.Steam
```

Allow Steam to fully update before continuing.

---

# ⚙️ Post-Install Configuration (Inside Steam)

## 🔹 Enable Proton (Steam Play)

Open:

**Steam → Settings → Compatibility**

* ✅ Set Default **Compatibility tool → Latest Proton (like Proton 9.x or Proton Experimental)**

---

## 🔹 Enable Shader Pre-Caching (New Steam UI Location)

Open:

**Steam → Settings → Downloads**

Scroll down to **Shader Cache**

* ✅ Enable **Shader Pre-Caching**
* ✅ Allow background processing of Vulkan shaders

> 💡 Recommended for Fedora Silverblue (especially with AMD/Intel GPUs) to reduce in-game stutter.

---

## 🔄 Restart Steam

Restart Steam after applying the changes.

---

# ✅ Done

Steam is now fully configured for:

* Native Linux gaming
* Proton gaming
* Vulkan shader pre-caching
* Fedora Atomic Silverblue (Flatpak environment)

---

## 📝 Notes & Workflow

* 🧊 **Immutable-first:** Keep the base image clean
* 📦 Prefer **Flatpaks** for apps
* 🐳 Use **Distrobox** for mutable dev environments
* 🔐 Manage Flatpak permissions with **Flatseal**

---
