#!/bin/bash
mkdir Music
cd Desktop/music
for file in *; do cp -r $file /home/suzen/Music; done;
cd /home/suzen
sleep 10
ls
