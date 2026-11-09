import { App, Gtk } from "astal/gtk4";
import Gio from "gi://Gio";
import GLib from "gi://GLib";

const ACCENT = "#70d6d0";
const MUTED = "#91a4b9";

function label(text, css = "") {
    const widget = new Gtk.Label({ label: text, xalign: 0 });
    if (css) widget.add_css_class(css);
    return widget;
}

function makeButton(text, callback, primary = false) {
    const button = new Gtk.Button({ label: text });
    button.add_css_class("overos-button");
    button.add_css_class(primary ? "primary" : "secondary");
    button.set_hexpand(true);
    button.connect("clicked", callback);
    return button;
}

function makeAppTile(info) {
    const button = new Gtk.Button();
    button.add_css_class("overos-app-tile");
    const content = new Gtk.Box({
        orientation: Gtk.Orientation.VERTICAL,
        spacing: 8,
        halign: Gtk.Align.CENTER,
        valign: Gtk.Align.CENTER,
    });
    const icon = new Gtk.Image({
        gicon: info.get_icon(),
        pixel_size: 30,
    });
    const title = new Gtk.Label({
        label: info.get_display_name(),
        ellipsize: 3,
        max_width_chars: 12,
        wrap: true,
        justify: Gtk.Justification.CENTER,
    });
    content.append(icon);
    content.append(title);
    button.set_child(content);
    button.connect("clicked", () => {
        try { info.launch([], null); }
        catch (error) { printerr("OverOS launcher: " + error); }
    });
    return button;
}

function buildLauncher() {
    const launcher = new Gtk.Box({
        orientation: Gtk.Orientation.VERTICAL,
        spacing: 14,
    });
    launcher.add_css_class("overos-launcher");

    const heading = new Gtk.Box({ spacing: 10 });
    heading.append(label("Aplicativos", "overos-title"));
    const spacer = new Gtk.Box();
    spacer.set_hexpand(true);
    heading.append(spacer);
    heading.append(label("OVEROS", "overos-chip"));
    launcher.append(heading);

    const search = new Gtk.SearchEntry({
        placeholder_text: "Pesquisar aplicativos…",
        hexpand: true,
    });
    search.add_css_class("overos-launcher-search");
    launcher.append(search);

    const flow = new Gtk.FlowBox({
        selection_mode: Gtk.SelectionMode.NONE,
        row_spacing: 10,
        column_spacing: 10,
        max_children_per_line: 5,
        min_children_per_line: 2,
        homogeneous: true,
    });
    flow.set_valign(Gtk.Align.START);

    const apps = Gio.AppInfo.get_all()
        .filter(info => info.should_show())
        .sort((a, b) => a.get_display_name().localeCompare(b.get_display_name()));

    for (const info of apps) flow.append(makeAppTile(info));

    search.connect("search-changed", () => {
        const query = search.get_text().toLocaleLowerCase();
        let child = flow.get_first_child();
        while (child) {
            const tile = child.get_child();
            const name = tile.get_child().get_last_child().get_label().toLocaleLowerCase();
            child.set_visible(!query || name.includes(query));
            child = child.get_next_sibling();
        }
    });

    const scroll = new Gtk.ScrolledWindow({
        vexpand: true,
        hscrollbar_policy: Gtk.PolicyType.NEVER,
        child: flow,
    });
    launcher.append(scroll);
    return launcher;
}

function buildControlCenter() {
    const panel = new Gtk.Box({
        orientation: Gtk.Orientation.VERTICAL,
        spacing: 12,
    });
    panel.add_css_class("overos-control-center");
    panel.append(label("Central de controle", "overos-title"));
    panel.append(label("Ações disponíveis dependem dos serviços e drivers instalados.", "overos-muted"));

    const row = new Gtk.Box({ spacing: 10 });
    row.append(makeButton("Configurações", () => {
        const info = Gio.DesktopAppInfo.new("overos-settings.desktop");
        if (info) info.launch([], null);
    }));
    row.append(makeButton("Bloquear sessão", () => {
        try { GLib.spawn_command_line_async("loginctl lock-session"); }
        catch (error) { printerr(String(error)); }
    }));
    panel.append(row);
    return panel;
}

function buildWindow(monitor) {
    const window = new Gtk.Window({
        application: App,
        title: "OverOS",
        default_width: 900,
        default_height: 620,
    });
    window.add_css_class("overos-shell");

    const root = new Gtk.Box({
        orientation: Gtk.Orientation.VERTICAL,
        spacing: 16,
    });
    root.set_margin_top(18);
    root.set_margin_bottom(18);
    root.set_margin_start(18);
    root.set_margin_end(18);

    const topbar = new Gtk.Box({
        spacing: 12,
        valign: Gtk.Align.CENTER,
    });
    topbar.add_css_class("overos-topbar");

    const brand = label("◈  OVEROS", "overos-title");
    topbar.append(brand);
    const spacer = new Gtk.Box();
    spacer.set_hexpand(true);
    topbar.append(spacer);

    const clock = label("", "overos-clock");
    const updateClock = () => {
        clock.set_label(GLib.DateTime.new_now_local().format("%H:%M  ·  %a, %d %b"));
        return GLib.SOURCE_CONTINUE;
    };
    updateClock();
    GLib.timeout_add_seconds(GLib.PRIORITY_DEFAULT, 30, updateClock);
    topbar.append(clock);
    root.append(topbar);

    const welcome = new Gtk.Box({
        orientation: Gtk.Orientation.VERTICAL,
        spacing: 5,
    });
    welcome.append(label("Seu espaço. Seu sistema.", "overos-title"));
    welcome.append(label("Uma experiência Linux feita para o OverOS.", "overos-muted"));
    root.append(welcome);

    const content = new Gtk.Box({
        orientation: Gtk.Orientation.HORIZONTAL,
        spacing: 16,
        vexpand: true,
    });
    content.append(buildLauncher());

    const side = new Gtk.Box({
        orientation: Gtk.Orientation.VERTICAL,
        spacing: 14,
    });
    side.set_size_request(250, -1);
    side.append(buildControlCenter());
    const about = new Gtk.Box({
        orientation: Gtk.Orientation.VERTICAL,
        spacing: 8,
    });
    about.add_css_class("overos-card");
    about.append(label("OverOS Shell", "overos-title"));
    about.append(label("Wayland-ready UI • Astal / GTK4", "overos-muted"));
    about.append(label("Perfil visual experimental", "overos-chip"));
    side.append(about);
    content.append(side);
    root.append(content);

    const footer = label("USB-first • Windows preservado • modo experimental", "overos-muted");
    root.append(footer);
    window.set_child(root);
    window.present();
    return window;
}

App.start({
    css: "./overos-shell.css",
    main() {
        const monitors = App.get_monitors();
        if (monitors.length) buildWindow(monitors[0]);
        else buildWindow(null);
    },
});
