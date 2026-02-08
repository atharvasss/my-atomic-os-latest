FROM quay.io/fedora/fedora-silverblue:43

# 0. Disable broken Fedora 43 updates-archive repo
RUN sed -i 's/^enabled=1/enabled=0/' /etc/yum.repos.d/fedora-updates-archive.repo || true

# 1. Install Host Tools 
RUN rpm-ostree install \
    htop \
    btop \
    nvtop \
    tmux \
    bat \
    gnome-tweaks \
    git \
    nautilus-python \
    fzf \
    distrobox \
    moby-engine \
    docker-compose && \
    rpm-ostree cleanup -m

# 2. Setup Docker Group
RUN groupadd -f docker

# 3. Automation Script (Complete and Fixed)
RUN printf '#!/bin/bash\n\
# --- Docker Group Check ---\n\
if ! groups "$(whoami)" | grep -q "\\bdocker\\b"; then\n\
  sudo usermod -aG docker "$(whoami)"\n\
fi\n\
# --- END DOCKER PERMISSIONS --- \n\
\n\
# --- Flatpak Apps Setup ---\n\
if [ ! -f "$HOME/.flatpak-setup-done" ]; then\n\
  flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo\n\
  flatpak install --user -y flathub \\\n\
    com.spotify.Client \\\n\
    app.zen_browser.zen \\\n\
    org.videolan.VLC \\\n\
    org.onlyoffice.desktopeditors \\\n\
    dev.zed.Zed \\\n\
    com.github.tchx84.Flatseal \\\n\
    com.mattjakeman.ExtensionManager \\\n\
    org.gnome.DejaDup \\\n\
    com.discordapp.Discord\n\
  # Set defaults\n\
  xdg-mime default dev.zed.Zed.desktop text/plain\n\
  xdg-mime default org.gnome.Nautilus.desktop inode/directory\n\
  xdg-settings set default-web-browser app.zen_browser.zen.desktop\n\
  mkdir -p "$HOME/.local/bin"\n\
  printf "#!/bin/bash\\nflatpak run dev.zed.Zed \\"\$@\\"" > "$HOME/.local/bin/zed"\n\
  chmod +x "$HOME/.local/bin/zed"\n\
  touch "$HOME/.flatpak-setup-done"\n\
fi\n' > /usr/bin/auto-setup-apps

RUN chmod +x /usr/bin/auto-setup-apps

# 4. Permissions and Autostart
RUN chmod +x /usr/bin/auto-setup-apps && \
    mkdir -p /etc/xdg/autostart && \
    printf "[Desktop Entry]\nType=Application\nName=Flatpak Auto-Setup\nExec=/usr/bin/auto-setup-apps\nNoDisplay=true\nX-GNOME-Autostart-enabled=true\n" \
    > /etc/xdg/autostart/flatpak-check.desktop

# 5. UI Cleanup & Aliases
# Note: Using /etc/bashrc is good for global aliases on Silverblue custom images
RUN sed -i 's/NoDisplay=false/NoDisplay=true/g' /usr/share/applications/org.gnome.Console.desktop || true && \
    echo 'alias z="flatpak run dev.zed.Zed ."' >> /etc/bashrc && \
    echo 'alias clean="flatpak uninstall --unused -y"' >> /etc/bashrc
    echo 'alias cat="bat"' >> /etc/bashrc
