#!/bin/bash

#valac --thread -g --target-glib=2.32 --pkg gtk+-3.0 --pkg gstreamer-pbutils-1.0 --pkg gee-0.8 --pkg tracker-sparql-1.0 --pkg libsoup-2.4 --pkg json-glib-1.0 music.vala musicmanager.vala mediaobject.vala streamplayer.vala interface.vala albumview.vala albumobject.vala albumsidebar.vala lastfm.vala queuemanager.vala queuesidebar.vala

# TO DISABLE THE WARNINGS
valac --thread --disable-warnings -g --target-glib=2.32 --pkg gtk+-3.0 --pkg gstreamer-pbutils-1.0 --pkg gee-0.8 --pkg tracker-sparql-1.0 --pkg libsoup-2.4 --pkg libxml-2.0 --pkg json-glib-1.0 music.vala musicmanager.vala mediaobject.vala streamplayer.vala interface.vala albumview.vala albumobject.vala albumsidebar.vala lastfm.vala queuemanager.vala queuesidebar.vala playerbar.vala signalhandler.vala utils.vala mediaartobject.vala
