FROM quay.io/fedora/fedora-silverblue:41

# 1. Install Host Tools
RUN rpm-ostree install \
    vulkan-tools mangohud nvtop gnome-tweaks git kitty \
    nautilus-python fzf distrobox moby-engine docker-compose && \
    rpm-ostree cleanup -m

# 2. Setup Docker Group
RUN groupadd -f docker

# 3. Automation Script (Flatpaks, Defaults, and Shortcuts)
RUN echo '#!/bin/bash\n\
if [ ! -f ~/.flatpak-setup-done ]; then\n\
  # Add Flathub\n\
  flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo\n\
  \n\
  # Install Packages\n\
  flatpak install -y flathub com.spotify.Client app.zen_browser.zen com.usebottles.bottles \
  org.videolan.VLC org.onlyoffice.desktopeditors dev.zed.Zed com.github.tchx84.Flatseal \
  com.mattjakeman.ExtensionManager com.valvesoftware.Steam org.gnome.DejaDup com.discordapp.Discord\n\
  \n\
  # Set Zed as Default Handler for files and folders\n\
  xdg-mime default dev.zed.Zed.desktop text/plain\n\
  xdg-mime default dev.zed.Zed.desktop inode/directory\n\
  \n\
  # Set Kitty as Default Terminal for GNOME\n\
  gsettings set org.gnome.desktop.default-applications.terminal exec "kitty"\n\
  \n\
  # Create the "zed" command shortcut\n\
  mkdir -p ~/.local/bin\n\
  echo -e "#!/bin/bash\nflatpak run dev.zed.Zed \"\$@\"" > ~/.local/bin/zed\n\
  chmod +x ~/.local/bin/zed\n\
  \n\
  # Finish and Notify\n\
  touch ~/.flatpak-setup-done\n\
  notify-send "Setup Complete" "Kitty & Zed ready. Try typing: . zed" --icon=software-update-available\n\
fi' > /usr/bin/auto-setup-apps && chmod +x /usr/bin/auto-setup-apps

# 4. Autostart Trigger
RUN mkdir -p /etc/xdg/autostart && \
    echo "[Desktop Entry]\nType=Application\nName=Flatpak Auto-Setup\nExec=/usr/bin/auto-setup-apps\nNoDisplay=true\nX-GNOME-Autostart-enabled=true" > /etc/xdg/autostart/flatpak-check.desktop

# 5. UI Cleanup (Hide default Console)
RUN if [ -f /usr/share/applications/org.gnome.Console.desktop ]; then \
    echo "NoDisplay=true" >> /usr/share/applications/org.gnome.Console.desktop; \
    fi

# 6. Aliases (The ". zed" command and "clean" command)
# We add these to bashrc so they work in every Kitty session
RUN echo 'alias . zed="flatpak run dev.zed.Zed ."' >> /etc/bashrc && \
    echo 'alias clean="flatpak uninstall --unused -y"' >> /etc/bashrc
