# Start from the official Fedora Silverblue 41 image
FROM quay.io/fedora/fedora-silverblue:41

# 1. Install Host System Packages
RUN rpm-ostree install \
    vulkan-tools mangohud nvtop gnome-tweaks git kitty nautilus-python && \
    rpm-ostree cleanup -m

# 2. Add Flathub and Install Apps
RUN flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo && \
    flatpak install -y flathub \
    com.spotify.Client app.zen_browser.zen com.usebottles.bottles \
    com.tradingview.TradingView org.videolan.VLC org.onlyoffice.desktopeditors \
    dev.zed.Zed com.github.tchx84.Flatseal com.mattjakeman.ExtensionManager \
    com.valvesoftware.Steam org.gnome.DejaDup com.discordapp.Discord

# 3. FIX: Set Kitty as Default & Hide Old Terminals
# This hides GNOME Console/Ptyxis from your app menu so only Kitty shows up
RUN sed -i 's/NoDisplay=false/NoDisplay=true/g' /usr/share/applications/org.gnome.Console.desktop || echo "NoDisplay=true" >> /usr/share/applications/org.gnome.Console.desktop && \
    sed -i 's/NoDisplay=false/NoDisplay=true/g' /usr/share/applications/org.gnome.Ptyxis.desktop || echo "NoDisplay=true" >> /usr/share/applications/org.gnome.Ptyxis.desktop

# Force GSettings to prefer Kitty (System-wide default)
RUN mkdir -p /usr/share/glib-2.0/schemas/ && \
    echo '[org.gnome.desktop.default-applications.terminal]' > /usr/share/glib-2.0/schemas/99-kitty-default.gschema.override && \
    echo 'exec="kitty"' >> /usr/share/glib-2.0/schemas/99-kitty-default.gschema.override && \
    glib-compile-schemas /usr/share/glib-2.0/schemas/
