#include "gdk/gdk.h"
#include "gdk/gdkwayland.h"

int is_wayland () {
	if (GDK_IS_WAYLAND_DISPLAY (gdk_display_get_default ())) {
		return 1;
	} else {
		return 0;
	}
}

