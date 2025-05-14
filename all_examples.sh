#!/usr/bin/bash
# Run all huitr examples

for ex in $(ls examples/*.8tr); do
    echo -n "File : "
    basename $ex
    ./main.py -d $ex
done
