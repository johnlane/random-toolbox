Random ToolBox
==============

This is just another Random Toolbox: somewhere to dump miscellaneous 
utility scripts, ephemera and other paraphernalia relating to my
general hacking activities. A bit like that rusty old box at the
back of the garden shed.

Don't expect structure, wisdom or, well, pretty-much anything really
but anything you might find you are free to use and, hopefully, find
useful (subject, of couse, to the appropriate LICENSE).

CONTENTS
--------

telscript is a small Python tool to enable writing of scripts to 
execute on a remote host via telnet. Written specifically to help
with ADSL router configuration.

get_apod_wallpaper downloads wallpaper from NASA's [Astronomy Picture
of the Day](http://apod.nasa.gov/apod/astropix.htm)

get_video_stream returns a video stream URL suitable for use by ffmpeg's
imput parameter. It supports http://ustream.tv.

ghostbuster extracts blogs from a Ghost blog (http://www.ghost.org) to
a collection of files for static web serving or storing in a scm system

git-objectvis is a small tool to graphically visualise a git repository's
object store (http://evadeflow.com/2011/01/visualizing-git-object-graphs)

git-migrate copies files and their commit history from one repo into a
new branch on another.

seadate is a small script that will decode the manufacturing date code
used on Seagate hard drives.

jterm is a script to open a terminal window with a themed appearance and
to optionally execute a command within, plus provide user with command to
take a screenshot of it.

jshot is a script to take a screenshot. It adds a "border" to the window
by laying the window over a crop of the background image (wallpaper) that
is slightly larger then the window being captured.

make_mediatomb_icons is a Makefile that will download source SVG files
and generate icons suitable for use with MediaTomb (http://mediatomb.cc)

detach is a script wrapper for reptyr with tmux/screen/dtach to simplify
detaching processes from the current terminal.

adb-download can be used to download media from an Android device (it
requires ADB).

snippets - the files in this directory contain useful command snippets
for shells, databases and other applications.

ad-hoc - the scripts in this directory were written for specific ad-hoc
purposes and are preserved here in case they become useful again.

examples - the files in this directory were written as examples or as
learning aids. They may have uses as they are but they're included here
as a source of information for other work / problem solving.

LICENSE
-------

Copyright (c) 2013-2016 John Lane

MIT License

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

http://opensource.org/licenses/MIT


