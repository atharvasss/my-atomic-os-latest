FROM quay.io/fedora/fedora-silverblue:43

# 1. Install Host Tools (disable broken updates-archive repo)
RUN rpm-ostree install \
    --disable-repo=updates-archive \
    vulkan-tools \
    mangohud \
    nvtop \
    gnome-tweaks \
    git \
    kitty \
    nautilus-python \
    fzf \
    distrobox \
    moby-engine \
    docker-compose && \
    rpm-ostree cleanup -m

# 2. Setup Docker Group
RUN groupadd -f docker

# 3. Automation Script (Flatpak user setup)
RUN cat <<-'EOF' > /usr/bin/auto-setup-apps
#!/bin/bash

if [ ! -f "$HOME/.flatpak-setup-done" ]; then
  flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

  flatpak install --user -y flathub \
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

  xdg-mime default dev.zed.Zed.desktop text/plain
  xdg-mime default dev.zed.Zed.desktop inode/directory

  gsettings set org.gnome.desktop.default-applications.terminal exec "kitty"

  mkdir -p "$HOME/.local/bin"
  echo -e '#!/bin/bash\nflatpak run dev.zed.Zed "$@"' > "$HOME/.local/bin/zed"
  chmod +x "$HOME/.local/bin/zed"

  touch "$HOME/.flatpak-setup-done"
  notify-send "Setup Complete" "Apps installed. Use 'z' or 'zed' to open Zed."
fi
EOF

RUN chmod +x /usr/bin/auto-setup-apps

# 4. Autostart Trigger
RUN mkdir -p /etc/xdg/autostart && \
    printf "[Desktop Entry]\nType=Application\nName=Flatpak Auto-Setup\nExec=/usr/bin/auto-setup-apps\nNoDisplay=true\nX-GNOME-Autostart-enabled=true\n" \
    > /etc/xdg/autostart/flatpak-check.desktop

# 5. UI Cleanup (Hide GNOME Console)
RUN sed -i 's/NoDisplay=false/NoDisplay=true/g' \
    /usr/share/applications/org.gnome.Console.desktop || true

# 6. Aliases
RUN echo 'alias z="flatpak run dev.zed.Zed ."' >> /etc/bashrc && \
    echo 'alias clean="flatpak uninstall --unused -y"' >> /etc/bashrc