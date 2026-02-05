FROM quay.io/fedora/fedora-silverblue:41

# 1. Install Host Tools (Including Distrobox, Docker, fzf, and nautilus-python)
RUN rpm-ostree install \
    vulkan-tools mangohud nvtop gnome-tweaks git kitty \
    nautilus-python fzf distrobox moby-engine docker-compose && \
    rpm-ostree cleanup -m

# 2. Install Flatpaks (removed invalid/troublesome entry)
RUN flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo && \
    flatpak install -y flathub \
    com.spotify.Client \
    app.zen_browser.zen \
    com.usebottles.bottles \
    org.videolan.VLC \
    org.onlyoffice.desktopeditors \
    dev.zed.Zed \
    com.github.tchx84.Flatseal \
    com.mattjakeman.ExtensionManager \
    com.valvesoftware.Steam \
    org.gnome.DejaDup \
    com.discordapp.Discord

# 3. AUTOMATION: Default Terminal (Kitty) & IDE (Zed) & File Handler
RUN mkdir -p /etc/xdg/autostart && \
    echo "[Desktop Entry]\nType=Application\nName=Setup Defaults\nExec=sh -c \"gsettings set org.gnome.desktop.default-applications.terminal exec 'kitty'; xdg-mime default dev.zed.Zed.desktop text/plain; xdg-mime default dev.zed.Zed.desktop inode/directory\"\nNoDisplay=true\nX-GNOME-Autostart-enabled=true" > /etc/xdg/autostart/set-defaults.desktop

# 4. Docker Group Setup
RUN groupadd -f docker

# 5. Hide the old GNOME Console icon
RUN sed -i 's/NoDisplay=false/NoDisplay=true/g' /usr/share/applications/org.gnome.Console.desktop || echo "NoDisplay=true" >> /usr/share/applications/org.gnome.Console.desktop