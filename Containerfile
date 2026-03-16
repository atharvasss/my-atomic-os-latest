FROM quay.io/fedora/fedora-silverblue:43

# 1. Handle Repositories
RUN sed -i 's/^enabled=1/enabled=0/' /etc/yum.repos.d/fedora-updates-archive.repo || true

# 2. Atomic Package Management
RUN rpm-ostree override remove firefox firefox-langpacks || true && \
    rpm-ostree install \
        gnome-tweaks \
        distrobox \
        podman \
        podman-compose \
        libnotify && \
    rpm-ostree cleanup -m && \
    ostree container commit

# 3. Setup Global Environment & Aliases
COPY <<EOF /etc/profile.d/custom-settings.sh
alias z="flatpak run dev.zed.Zed ."
alias zen="flatpak run app.zen_browser.zen"
alias pc="podman compose"
EOF

# 4. Background Automation Script
RUN mkdir -p /usr/libexec && \
    printf '#!/usr/bin/env bash\n\
set -euo pipefail\n\
\n\
[ -f "$HOME/.setup-done" ] && exit 0\n\
\n\
# Wait for internet\n\
until curl -s --head https://www.google.com | grep "200" > /dev/null; do\n\
  sleep 5\n\
done\n\
\n\
# Initialize Flatpak\n\
flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo\n\
\n\
# Install apps\n\
flatpak install --user -y flathub app.zen_browser.zen org.videolan.VLC org.onlyoffice.desktopeditors dev.zed.Zed com.github.tchx84.Flatseal com.mattjakeman.ExtensionManager org.gnome.DejaDup com.discordapp.Discord\n\
\n\
# Mark as done\n\
touch "$HOME/.setup-done"\n\
notify-send "Setup Complete" "Your environment is ready."\n' \
    > /usr/libexec/first-run-setup && \
    chmod +x /usr/libexec/first-run-setup

# 5. Autostart Config
RUN mkdir -p /etc/xdg/autostart && \
    printf '[Desktop Entry]\n\
Type=Application\n\
Name=First Run Setup\n\
Exec=/usr/libexec/first-run-setup\n\
Terminal=false\n\
X-GNOME-Autostart-enabled=true\n' \
    > /etc/xdg/autostart/first-run.desktop
