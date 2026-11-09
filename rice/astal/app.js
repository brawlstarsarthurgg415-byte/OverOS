import { App, Gtk } from "astal/gtk4";
import Gio from "gi://Gio";
import GLib from "gi://GLib";

function label(text, css = "") {
    const widget = new Gtk.Label({ label: text, xalign: 0 });
    if (css) widget.add_css_class(css);
    return widget;
}

function makeButton(text, callback, { primary = false, sensitive = true } = {}) {
    const button = new Gtk.Button({ label: text, sensitive });
    button.add_css_class("overos-button");
    button.add_css_class(primary ? "primary" : "secondary");
    button.set_hexpand(true);
    if (callback) button.connect("clicked", callback);
    return button;
}

function makeAppTile(info) {
    const button = new Gtk.Button();
    button.add_css_class("overos-app-tile");
    button._overosSearchName = info.get_display_name().toLocaleLowerCase();

    const content = new Gtk.Box({
        orientation: Gtk.Orientation.VERTICAL,
        spacing: 8,
        halign: Gtk.Align.CENTER,
        valign: Gtk.Align.CENTER,
    });

    const appIcon = info.get_icon();
    const icon = appIcon
        ? new Gtk.Image({ gicon: appIcon, pixel_size: 30 })
        : new Gtk.Image({ icon_name: "application-x-executable-symbolic", pixel_size: 30 });
    const title = new Gtk.Label({
        label: info.get_display_name(),
        ellipsize: 3,
        max_width_chars: 14,
        wrap: true,
        justify: Gtk.Justification.CENTER,
    });

    content.append(icon);
    content.append(title);
    button.set_child(content);
    button.set_tooltip_text(info.get_display_name());
    button.connect("clicked", () => {
        try {
            info.launch([], null);
        } catch (error) {
            printerr("OverOS launcher: " + error);
        }
    });
    return button;
}

function buildLauncher() {
    const launcher = new Gtk.Box({
        orientation: Gtk.Orientation.VERTICAL,
        spacing: 14,
        hexpand: true,
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

    const tiles = apps.map(info => makeAppTile(info));
    for (const tile of tiles) flow.append(tile);

    const empty = label(
        apps.length ? "Nenhum aplicativo corresponde à pesquisa." : "Nenhum aplicativo gráfico foi encontrado.",
        "overos-muted",
    );
    empty.set_wrap(true);
    empty.set_justify(Gtk.Justification.CENTER);
    empty.set_margin_top(18);
    empty.set_visible(apps.length === 0);
    launcher.append(empty);

    search.connect("search-changed", () => {
        const query = search.get_text().trim().toLocaleLowerCase();
        let visibleCount = 0;
        for (const tile of tiles) {
            const matches = !query || tile._overosSearchName.includes(query);
            tile.set_visible(matches);
            if (matches) visibleCount += 1;
        }
        empty.set_visible(visibleCount === 0);
        empty.set_label(
            apps.length ? "Nenhum aplicativo corresponde à pesquisa." : "Nenhum aplicativo gráfico foi encontrado.",
        );
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
    panel.append(label(
        "Os controles são habilitados conforme os serviços disponíveis no sistema.",
        "overos-muted",
    ));

    const settings = Gio.DesktopAppInfo.new("overos-settings.desktop");
    panel.append(makeButton(
        "Configurações",
        () => settings?.launch([], null),
        { sensitive: Boolean(settings) },
    ));

    const loginctl = GLib.find_program_in_path("loginctl");
    panel.append(makeButton(
        "Bloquear sessão",
        () => {
            try {
                GLib.spawn_async(
                    null,
                    [loginctl, "lock-session"],
                    null,
                    GLib.SpawnFlags.SEARCH_PATH,
                    null,
                );
            } catch (error) {
                printerr("OverOS session lock: " + error);
            }
        },
        { sensitive: Boolean(loginctl) },
    ));
    return panel;
}

function buildWindow() {
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
    topbar.append(label("◈  OVEROS", "overos-title"));

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

    root.append(label(
        "USB-first • Windows preservado • modo experimental",
        "overos-muted",
    ));
    window.set_child(root);
    window.present();
}

const modulePath = GLib.filename_from_uri(import.meta.url)[0];
const moduleDirectory = GLib.path_get_dirname(modulePath);
const stylesheet = GLib.build_filenamev([moduleDirectory, "overos-shell.css"]);

App.start({
    css: stylesheet,
    main() {
        buildWindow();
    },
});
