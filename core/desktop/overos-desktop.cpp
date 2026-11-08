#include <gtk/gtk.h>

#include <cstdio>
#include <cstdlib>
#include <string>

namespace {
GtkWidget *window = nullptr;
GtkWidget *status_label = nullptr;
GtkCssProvider *css_provider = nullptr;
std::string accent = "#70D6D0";
double scale = 1.0;
bool high_contrast = false;
bool reduced_motion = true;

const char *config_path() {
    static std::string path;
    if (path.empty()) {
        const char *base = g_get_user_config_dir();
        path = std::string(base ? base : ".") + "/overos/ui.ini";
    }
    return path.c_str();
}

void apply_style() {
    if (!css_provider) return;
    gchar *css = g_strdup_printf(
        "window { background: #0b1018; color: #edf5ff; }"
        ".overos-card { background: %s; border: 1px solid %s; border-radius: 18px; padding: 18px; }"
        ".overos-title { color: #edf5ff; font-size: 25px; font-weight: 700; }"
        ".overos-muted { color: %s; }"
        "button.overos-action { min-height: 54px; padding: 10px 18px; border-radius: 13px; "
        "background: %s; color: #07131b; font-weight: 700; }"
        "button.overos-secondary { min-height: 52px; padding: 10px 16px; border-radius: 13px; "
        "background: #1b2a3b; color: #edf5ff; }"
        "button.overos-action:focus, button.overos-secondary:focus { outline: 3px solid %s; }"
        "scale { min-height: 42px; }",
        high_contrast ? "#101d2b" : "#121b27",
        high_contrast ? accent.c_str() : "#26384b",
        high_contrast ? "#c5d8ea" : "#91a4b9",
        accent.c_str(), accent.c_str());
    gtk_css_provider_load_from_data(css_provider, css, -1);
    g_free(css);
}

void load_settings() {
    GKeyFile *file = g_key_file_new();
    GError *error = nullptr;
    if (g_key_file_load_from_file(file, config_path(), G_KEY_FILE_NONE, &error)) {
        gchar *saved = g_key_file_get_string(file, "interface", "accent", nullptr);
        if (saved) { accent = saved; g_free(saved); }
        scale = g_key_file_get_double(file, "interface", "scale", nullptr);
        high_contrast = g_key_file_get_boolean(file, "interface", "high-contrast", nullptr);
        reduced_motion = g_key_file_get_boolean(file, "interface", "reduced-motion", nullptr);
        if (scale < 0.8 || scale > 1.5) scale = 1.0;
    }
    if (error) g_error_free(error);
    g_key_file_unref(file);
}

void save_settings() {
    GKeyFile *file = g_key_file_new();
    g_key_file_set_string(file, "interface", "accent", accent.c_str());
    g_key_file_set_double(file, "interface", "scale", scale);
    g_key_file_set_boolean(file, "interface", "high-contrast", high_contrast);
    g_key_file_set_boolean(file, "interface", "reduced-motion", reduced_motion);
    gsize length = 0;
    GError *error = nullptr;
    gchar *data = g_key_file_to_data(file, &length, nullptr);
    gchar *directory = g_path_get_dirname(config_path());
    g_mkdir_with_parents(directory, 0700);
    if (!g_file_set_contents(config_path(), data, static_cast<gssize>(length), &error)) {
        if (status_label) gtk_label_set_text(GTK_LABEL(status_label), error->message);
        g_clear_error(&error);
    } else if (status_label) {
        gtk_label_set_text(GTK_LABEL(status_label), "Preferências salvas neste usuário.");
    }
    g_free(directory);
    g_free(data);
    g_key_file_unref(file);
}

GtkWidget *make_label(const char *text, const char *css_class) {
    GtkWidget *label = gtk_label_new(text);
    gtk_label_set_xalign(GTK_LABEL(label), 0.0F);
    if (css_class) gtk_widget_add_css_class(label, css_class);
    return label;
}

void on_accent_changed(GObject *object, GParamSpec *, gpointer) {
    auto *drop = GTK_DROP_DOWN(object);
    const guint selected = gtk_drop_down_get_selected(drop);
    const char *colors[] = {"#70D6D0", "#8AB4F8", "#C4A7E7", "#F2B880"};
    if (selected < G_N_ELEMENTS(colors)) accent = colors[selected];
    apply_style();
}

void on_scale_changed(GtkRange *range, gpointer) {
    scale = gtk_range_get_value(range);
    if (window) gtk_widget_set_size_request(window, static_cast<int>(680 * scale), -1);
}

void on_contrast_toggled(GtkCheckButton *button, gpointer) {
    high_contrast = gtk_check_button_get_active(button);
    apply_style();
}

void on_motion_toggled(GtkCheckButton *button, gpointer) {
    reduced_motion = gtk_check_button_get_active(button);
}

void open_editor(GtkButton *, gpointer) {
    GtkWidget *editor = gtk_window_new();
    gtk_window_set_title(GTK_WINDOW(editor), "Editor de interface • OverOS");
    gtk_window_set_transient_for(GTK_WINDOW(editor), GTK_WINDOW(window));
    gtk_window_set_modal(GTK_WINDOW(editor), TRUE);
    gtk_window_set_default_size(GTK_WINDOW(editor), 520, 520);

    GtkWidget *box = gtk_box_new(GTK_ORIENTATION_VERTICAL, 16);
    gtk_widget_set_margin_top(box, 22);
    gtk_widget_set_margin_bottom(box, 22);
    gtk_widget_set_margin_start(box, 22);
    gtk_widget_set_margin_end(box, 22);
    gtk_window_set_child(GTK_WINDOW(editor), box);

    gtk_box_append(GTK_BOX(box), make_label("Personalizar o OverOS", "overos-title"));
    gtk_box_append(GTK_BOX(box), make_label("Ajuste a aparência para tela touch ou computador.", "overos-muted"));

    gtk_box_append(GTK_BOX(box), make_label("Cor de destaque", nullptr));
    const char *names[] = {"Turquesa", "Azul", "Lilás", "Âmbar", nullptr};
    GtkStringList *colors = gtk_string_list_new(names);
    GtkWidget *drop = gtk_drop_down_new(G_LIST_MODEL(colors), nullptr);
    const char *color_values[] = {"#70D6D0", "#8AB4F8", "#C4A7E7", "#F2B880"};
    guint active = 0;
    for (guint i = 0; i < 4; ++i) if (accent == color_values[i]) active = i;
    gtk_drop_down_set_selected(GTK_DROP_DOWN(drop), active);
    g_signal_connect(drop, "notify::selected", G_CALLBACK(on_accent_changed), nullptr);
    gtk_box_append(GTK_BOX(box), drop);

    gtk_box_append(GTK_BOX(box), make_label("Escala dos elementos", nullptr));
    GtkWidget *slider = gtk_scale_new_with_range(GTK_ORIENTATION_HORIZONTAL, 0.8, 1.5, 0.05);
    gtk_range_set_value(GTK_RANGE(slider), scale);
    gtk_scale_set_draw_value(GTK_SCALE(slider), TRUE);
    g_signal_connect(slider, "value-changed", G_CALLBACK(on_scale_changed), nullptr);
    gtk_box_append(GTK_BOX(box), slider);

    GtkWidget *contrast = gtk_check_button_new_with_label("Alto contraste");
    gtk_check_button_set_active(GTK_CHECK_BUTTON(contrast), high_contrast);
    g_signal_connect(contrast, "toggled", G_CALLBACK(on_contrast_toggled), nullptr);
    gtk_box_append(GTK_BOX(box), contrast);

    GtkWidget *motion = gtk_check_button_new_with_label("Reduzir animações (recomendado para aparelhos lentos)");
    gtk_check_button_set_active(GTK_CHECK_BUTTON(motion), reduced_motion);
    g_signal_connect(motion, "toggled", G_CALLBACK(on_motion_toggled), nullptr);
    gtk_box_append(GTK_BOX(box), motion);

    GtkWidget *buttons = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 10);
    gtk_widget_set_halign(buttons, GTK_ALIGN_END);
    GtkWidget *cancel = gtk_button_new_with_label("Fechar");
    GtkWidget *save = gtk_button_new_with_label("Salvar preferências");
    gtk_widget_add_css_class(save, "overos-action");
    g_signal_connect_swapped(cancel, "clicked", G_CALLBACK(gtk_window_destroy), editor);
    g_signal_connect_swapped(save, "clicked", G_CALLBACK(save_settings), nullptr);
    g_signal_connect_swapped(save, "clicked", G_CALLBACK(gtk_window_destroy), editor);
    gtk_box_append(GTK_BOX(buttons), cancel);
    gtk_box_append(GTK_BOX(buttons), save);
    gtk_box_append(GTK_BOX(box), buttons);
    gtk_window_present(GTK_WINDOW(editor));
}

void on_application_activate(GtkApplication *app, gpointer) {
    load_settings();
    window = gtk_application_window_new(app);
    gtk_window_set_title(GTK_WINDOW(window), "OverOS");
    gtk_window_set_default_size(GTK_WINDOW(window), 900, 640);

    css_provider = gtk_css_provider_new();
    GdkDisplay *display = gdk_display_get_default();
    gtk_style_context_add_provider_for_display(display, GTK_STYLE_PROVIDER(css_provider),
                                                GTK_STYLE_PROVIDER_PRIORITY_APPLICATION);
    apply_style();

    GtkWidget *root = gtk_box_new(GTK_ORIENTATION_VERTICAL, 18);
    gtk_widget_set_margin_top(root, 24);
    gtk_widget_set_margin_bottom(root, 24);
    gtk_widget_set_margin_start(root, 26);
    gtk_widget_set_margin_end(root, 26);
    gtk_window_set_child(GTK_WINDOW(window), root);

    GtkWidget *top = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 12);
    gtk_box_append(GTK_BOX(top), make_label("OVEROS", "overos-title"));
    GtkWidget *spacer = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 0);
    gtk_widget_set_hexpand(spacer, TRUE);
    gtk_box_append(GTK_BOX(top), spacer);
    gtk_box_append(GTK_BOX(top), make_label("Sistema • modo de desenvolvimento", "overos-muted"));
    gtk_box_append(GTK_BOX(root), top);

    gtk_box_append(GTK_BOX(root), make_label("Tudo pronto para começar?", "overos-title"));
    gtk_box_append(GTK_BOX(root), make_label("Seu espaço. Seu sistema. Uma interface que você pode personalizar.",
                                              "overos-muted"));

    GtkWidget *grid = gtk_grid_new();
    gtk_grid_set_row_spacing(GTK_GRID(grid), 14);
    gtk_grid_set_column_spacing(GTK_GRID(grid), 14);
    gtk_widget_set_hexpand(grid, TRUE);
    gtk_widget_set_vexpand(grid, TRUE);

    GtkWidget *system_card = gtk_box_new(GTK_ORIENTATION_VERTICAL, 12);
    gtk_widget_add_css_class(system_card, "overos-card");
    gtk_box_append(GTK_BOX(system_card), make_label("Meu dispositivo", "overos-title"));
    gtk_box_append(GTK_BOX(system_card), make_label("Veja informações de hardware e estado do sistema.", "overos-muted"));
    GtkWidget *system_button = gtk_button_new_with_label("Abrir informações");
    gtk_widget_add_css_class(system_button, "overos-secondary");
    gtk_box_append(GTK_BOX(system_card), system_button);

    GtkWidget *editor_card = gtk_box_new(GTK_ORIENTATION_VERTICAL, 12);
    gtk_widget_add_css_class(editor_card, "overos-card");
    gtk_box_append(GTK_BOX(editor_card), make_label("Editor de interface", "overos-title"));
    gtk_box_append(GTK_BOX(editor_card), make_label("Mude cores, tamanho dos controles e acessibilidade para toque.", "overos-muted"));
    GtkWidget *editor_button = gtk_button_new_with_label("✦  Personalizar interface");
    gtk_widget_add_css_class(editor_button, "overos-action");
    g_signal_connect(editor_button, "clicked", G_CALLBACK(open_editor), nullptr);
    gtk_box_append(GTK_BOX(editor_card), editor_button);

    GtkWidget *terminal_card = gtk_box_new(GTK_ORIENTATION_VERTICAL, 12);
    gtk_widget_add_css_class(terminal_card, "overos-card");
    gtk_box_append(GTK_BOX(terminal_card), make_label("Ferramentas", "overos-title"));
    gtk_box_append(GTK_BOX(terminal_card), make_label("Acesso ao terminal e utilitários do OverOS.", "overos-muted"));
    GtkWidget *terminal_button = gtk_button_new_with_label("Terminal (em integração)");
    gtk_widget_add_css_class(terminal_button, "overos-secondary");
    gtk_widget_set_sensitive(terminal_button, FALSE);
    gtk_box_append(GTK_BOX(terminal_card), terminal_button);

    gtk_grid_attach(GTK_GRID(grid), system_card, 0, 0, 1, 1);
    gtk_grid_attach(GTK_GRID(grid), editor_card, 1, 0, 1, 1);
    gtk_grid_attach(GTK_GRID(grid), terminal_card, 0, 1, 2, 1);
    gtk_box_append(GTK_BOX(root), grid);

    status_label = make_label("Perfil touch: controles ampliados • efeitos reduzidos", "overos-muted");
    gtk_box_append(GTK_BOX(root), status_label);
    gtk_window_present(GTK_WINDOW(window));
}
}

int main(int argc, char **argv) {
    if (argc > 1 && std::string(argv[1]) == "--version") {
        std::puts("OverOS Desktop 0.1.0 (GTK4 prototype)");
        return 0;
    }
    GtkApplication *app = gtk_application_new("org.overos.desktop", G_APPLICATION_DEFAULT_FLAGS);
    g_signal_connect(app, "activate", G_CALLBACK(on_application_activate), nullptr);
    const int status = g_application_run(G_APPLICATION(app), argc, argv);
    g_object_unref(app);
    return status;
}
