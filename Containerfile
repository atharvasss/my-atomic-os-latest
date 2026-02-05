FROM quay.io/fedora/fedora-silverblue:43

# 1. Install Host Tools
RUN rpm-ostree install \
    vulkan-tools mangohud nvtop gnome-tweaks git kitty \
    nautilus-python fzf distrobox moby-engine docker-compose && \
    rpm-ostree cleanup -m

# 2. Setup Docker Group
RUN groupadd -f docker

# 3. Automation Script (Fixed Escaping & Logic)
# We use a HEREDOC (<<-'EOF') to ensure the script is written exactly as seen
RUN cat <<-'EOF' > /usr/bin/auto-setup-apps
#!/bin/bash
# Safety check: Only run if the 'done' file doesn't exist
if [ ! -f "$HOME/.flatpak-setup-done" ]; then
  # Add Flathub (User-specific)
  flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  
  # Install Packages (User-level avoids sudo prompts)
  flatpak install --user -y flathub \
    com.spotify.Client app.zen_browser.zen com.usebottles.bottles \
    org.videolan.VLC org.onlyoffice.desktopeditors dev.zed.Zed \
    com.github.tchx84.Flatseal com.mattjakeman.ExtensionManager \
    com.valvesoftware.Steam org.gnome.DejaDup com.discordapp.Discord
  
  # Set Zed as Default Handler
  xdg-mime default dev.zed.Zed.desktop text/plain
  xdg-mime default dev.zed.Zed.desktop inode/directory
  
  # Set Kitty as Default Terminal for GNOME
  gsettings set org.gnome.desktop.default-applications.terminal exec "kitty"
  
  # Create a 'zed' binary shortcut in user local path
  mkdir -p "$HOME/.local/bin"
  echo -e '#!/bin/bash\nflatpak run dev.zed.Zed "$@"' > "$HOME/.local/bin/zed"
  chmod +x "$HOME/.local/bin/zed"
  
  # Mark as finished so it never runs again
  touch "$HOME/.flatpak-setup-done"
  notify-send "Setup Complete" "Apps installed. Use 'z' or 'zed' to open Zed." --icon=software-update-available
fi
EOF
RUN chmod +x /usr/bin/auto-setup-apps

# 4. Autostart Trigger
RUN mkdir -p /etc/xdg/autostart && \
    echo -e "[Desktop Entry]\nType=Application\nName=Flatpak Auto-Setup\nExec=/usr/bin/auto-setup-apps\nNoDisplay=true\nX-GNOME-Autostart-enabled=true" > /etc/xdg/autostart/flatpak-check.desktop

# 5. UI Cleanup (Hide default Console)
RUN sed -i 's/NoDisplay=false/NoDisplay=true/g' /usr/share/applications/org.gnome.Console.desktop || echo "NoDisplay=true" >> /usr/share/applications/org.gnome.Console.desktop

# 6. Aliases (Using 'z' instead of '.' to avoid system conflicts)
RUN echo 'alias z="flatpak run dev.zed.Zed ."' >> /etc/bashrc && \
    echo 'alias clean="flatpak uninstall --unused -y"' >> /etc/bashrc
