FROM quay.io/fedora/fedora-silverblue:43

############################################
# 1. Repository Configuration
############################################
RUN sed -i 's/^enabled=1/enabled=0/' /etc/yum.repos.d/fedora-updates-archive.repo || true

############################################
# 2. Base Package Layer
############################################
RUN rpm-ostree override remove firefox firefox-langpacks || true && \
    rpm-ostree install \
        gnome-tweaks \
        distrobox \
        podman \
        podman-compose \
        libnotify && \
    rpm-ostree cleanup -m && \
    ostree container commit

############################################
# 3. Global Environment Configuration
############################################
RUN printf '%s\n' \
'alias z="flatpak run dev.zed.Zed ."' \
'alias zen="flatpak run app.zen_browser.zen"' \
'alias pc="podman compose"' \
> /etc/profile.d/devops-env.sh


############################################
# 4. System Utilities
############################################
RUN install -d /usr/libexec

############################################
# 5. First Boot Setup Script
############################################
RUN cat <<'EOF' > /usr/libexec/first-run-setup
#!/usr/bin/env bash
set -euo pipefail

[ -f "$HOME/.setup-done" ] && exit 0

# Wait for internet
until curl -s --head https://www.google.com | grep "200" > /dev/null; do
  sleep 5
done

# Setup Flatpak
flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Install applications
flatpak install --user -y flathub \
  app.zen_browser.zen \
  org.videolan.VLC \
  org.onlyoffice.desktopeditors \
  dev.zed.Zed \
  com.github.tchx84.Flatseal \
  com.mattjakeman.ExtensionManager \
  org.gnome.DejaDup \
  com.discordapp.Discord

touch "$HOME/.setup-done"

notify-send "Setup Complete" "Your environment is ready."
EOF

RUN chmod +x /usr/libexec/first-run-setup

############################################
# 6. Desktop Autostart
############################################
RUN mkdir -p /etc/xdg/autostart && \
cat <<'EOF' > /etc/xdg/autostart/first-run.desktop
[Desktop Entry]
Type=Application
Name=First Run Setup
Exec=/usr/libexec/first-run-setup
Terminal=false
X-GNOME-Autostart-enabled=true
EOF
