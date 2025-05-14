#!/usr/bin/bash
# Run all huitr examples

for ex in $(ls examples/*.huitr); do
    echo -n "File : "
    basename $ex
    ./main.py -d $ex
done
