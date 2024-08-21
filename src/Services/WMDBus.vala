[DBus (name = "org.pantheon.gala")]
public interface Wingpanel.Services.WMDBus : GLib.Object {
    private static WMDBus? instance = null;
    public static async void switch_workspace (bool backwards) {
        if (instance == null) {
            try {
                instance = yield Bus.get_proxy (BusType.SESSION, "org.pantheon.gala", "/org/pantheon/gala");
            } catch (Error e) {
                warning ("Failed to get gala dbus: %s", e.message);
                return;
            }
        }

        var action = backwards ? ActionType.SWITCH_TO_WORKSPACE_PREVIOUS : ActionType.SWITCH_TO_WORKSPACE_NEXT;
        try {
            yield instance.perform_action (action);
        } catch (Error e) {
            warning ("Failed to perform gala action: %s", e.message);
        }
    }

    public enum ActionType {
        NONE = 0,
        SHOW_WORKSPACE_VIEW,
        MAXIMIZE_CURRENT,
        HIDE_CURRENT,
        OPEN_LAUNCHER,
        CUSTOM_COMMAND,
        WINDOW_OVERVIEW,
        WINDOW_OVERVIEW_ALL,
        SWITCH_TO_WORKSPACE_PREVIOUS,
        SWITCH_TO_WORKSPACE_NEXT,
        SWITCH_TO_WORKSPACE_LAST,
        START_MOVE_CURRENT,
        START_RESIZE_CURRENT,
        TOGGLE_ALWAYS_ON_TOP_CURRENT,
        TOGGLE_ALWAYS_ON_VISIBLE_WORKSPACE_CURRENT,
        MOVE_CURRENT_WORKSPACE_LEFT,
        MOVE_CURRENT_WORKSPACE_RIGHT,
        CLOSE_CURRENT,
        SCREENSHOT_CURRENT
    }

    public abstract async void perform_action (ActionType type) throws DBusError, IOError;
}
