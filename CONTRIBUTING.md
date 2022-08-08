## Preventing Wingpanel from Restarting

When developing the panel or panel-related packages like the Applications Menu and indicators, you'll want to start the panel from Terminal to view logs. Wingpanel is automatically started and restarted by `gnome-session`, but if Wingpanel is stopped twice within a minute, it will stop automatically restarting, and you can gather logs:
1. In Terminal run `killall io.elementary.wingpanel` twice to stop the current Wingpanel
2. Start Wingpanel with debug logging by running `G_MESSAGES_DEBUG=all io.elementary.wingpanel`

To restore normal behavior logout or reboot to restart your session.
