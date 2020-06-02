#!/bin/bash
for i in`seq 1 999`; do touch $i.txt; done
sleep 10
ls
