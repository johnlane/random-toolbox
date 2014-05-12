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

window = gtk.Window()

# the screen contains all monitors
screen = window.get_screen()
print "screen size: %d x %d" % (gtk.gdk.screen_width(),gtk.gdk.screen_height())

# collect data about each monitor
monitors = []
nmons = screen.get_n_monitors()
print "there are %d monitors" % nmons
for m in range(nmons):
  mg = screen.get_monitor_geometry(m)
  print "monitor %d: %d x %d" % (m,mg.width,mg.height)
  monitors.append(mg)

# current monitor
curmon = screen.get_monitor_at_window(screen.get_active_window())
x, y, width, height = monitors[curmon]
print "monitor %d: %d x %d (current)" % (curmon,width,height)
