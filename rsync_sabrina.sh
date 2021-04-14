#!/bin/sh
rsync -avh --exclude="**/@Recycle/**" admin@sabrina:/share/DropZone/* /srv/hd/sabrina/DropZone/
rsync -avh --exclude="**/@Recycle/**" admin@sabrina:/share/Multimedia/* /srv/hd/sabrina/Multimedia/
rsync -avh --exclude="**/@Recycle/**"  --exclude="**/.syncing_db/**" admin@sabrina:/share/homes/* /srv/hd/sabrina/homes/
rsync -avh --exclude="**/@Recycle/**" admin@sabrina:/share/Download/* /srv/hd/sabrina/Download/
 date