#include <gtk/gtk.h>

static gboolean has_error = FALSE;

static void
on_parsing_error(GtkCssProvider *provider,
                 GtkCssSection *section,
                 const GError *error,
                 gpointer user_data)
{
    (void) provider;
    (void) section;
    (void) user_data;
    g_printerr("GTK CSS: %s\n", error->message);
    has_error = TRUE;
}

int
main(int argc, char **argv)
{
    if (argc != 2) {
        g_printerr("Usage: %s stylesheet.css\n", argv[0]);
        return 2;
    }

    GtkCssProvider *provider = gtk_css_provider_new();
    g_signal_connect(provider, "parsing-error",
                     G_CALLBACK(on_parsing_error), NULL);
    gtk_css_provider_load_from_path(provider, argv[1]);
    g_object_unref(provider);

    return has_error ? 1 : 0;
}
