#!/usr/bin/env python2
#
# dockbar.py
#
# Example program places a coloured bar across the top of the
# current monitor
#
# demonstrates
#
# (a) creating the bar as an undecorated "dock" window   
# (b) setting its colour
# (c) getting the number of monitors and their sizes
#
#                                                         JL 20140512

import gtk

# Colour style for (b)
colour_rc= """
style "bar-colour" {
    bg[NORMAL] = "Dark Red"
} widget "*bar" style "bar-colour"
"""

#  the size of the bar (its height), in pixels
bar_size = 10

def main ():

    # (a) Create an undecorated dock
    window = gtk.Window()
    window.set_name("bar")
    window.set_type_hint(gtk.gdk.WINDOW_TYPE_HINT_DOCK)
    window.set_decorated(False)
    window.connect("destroy", gtk.main_quit)

    # (b) Style it
    gtk.rc_parse_string(colour_rc)

    # the screen contains all monitors
    screen = window.get_screen()
    width = gtk.gdk.screen_width()
    print "width: %d" % width

    # (c) collect data about each monitor
    monitors = []
    nmons = screen.get_n_monitors()
    print "there are %d monitors" % nmons
    for m in range(nmons):
      mg = screen.get_monitor_geometry(m)
      width = mg.width
      print "monitor %d: %d x %d" % (m,mg.width,mg.height)
      monitors.append(mg)

    # current monitor
    curmon = screen.get_monitor_at_window(screen.get_active_window())
    x, y, width, height = monitors[curmon]
    print "monitor %d: %d x %d (current)" % (curmon,width,height)

    # display bar along the top of the current monitor
    window.move(x,y)
    window.resize(width,bar_size)

    # it must be shown before changing properties 
    window.show_all()

    # (d) reserve space (a "strut") for the bar so it does not become obscured
    #     when other windows are maximized, etc
    topw = window.get_toplevel().window
    topw.property_change("_NET_WM_STRUT","CARDINAL",32,gtk.gdk.PROP_MODE_REPLACE,
            [0, 0, bar_size, 0])
    topw.property_change("_NET_WM_STRUT_PARTIAL","CARDINAL",32,gtk.gdk.PROP_MODE_REPLACE,
            [0, 0, bar_size, 0, 0, 0, 0, 0, x, x+width, 0, 0])


    # we set _NET_WM_STRUT, the older mechanism as well as _NET_WM_STRUT_PARTIAL
    # but window managers ignore the former if they support the latter.
    #
    # the numbers in the array are as follows:
    #
    # 0, 0, bar_size, 0 are the number of pixels to reserve along each edge of the
    # screen given in the order left, right, top, bottom. Here the size of the bar
    # is reserved at the top of the screen and the other edges are left alone.
    #
    # _NET_WM_STRUT_PARTIAL also supplies a further four pairs, each being a
    # start and end position for the strut (they don't need to occupy the entire
    # edge).
    #
    # In the example, we set the top start to the current monitor's x co-ordinate
    # and the top-end to the same value plus that monitor's width. The net result
    # is that space is reserved only on the current monitor.
    #
    # co-ordinates are specified relative to the screen (i.e. all monitors together).
    #


    # main event loop
    gtk.main()

if __name__ == "__main__":
    main ()
