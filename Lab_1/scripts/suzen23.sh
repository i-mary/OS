#!/bin/bash
cd destination
for file in *; do mv $file $file.back; done
cd /home/suzen/source
mv * /home/suzen/destination
cd ..
ls
