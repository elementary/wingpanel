prefix=@PREFIX@
exec_prefix=@DOLLAR@{prefix}
libdir=@DOLLAR@{prefix}/lib
includedir=@DOLLAR@{prefix}/include/
 
Name: Wingpanel
Description: Wingpanel headers  
Version: 2.0  
Libs: -lwingpanel-2.0
Cflags: -I@DOLLAR@{includedir}/wingpanel-2.0
Requires: glib-2.0 gee-0.8 gmodule-2.0 gtk+-3.0

