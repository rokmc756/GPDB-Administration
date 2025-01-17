#!/bin/bash

# groupadd gpadmin1
# useradd gpadmin1 -r -m -g gpadmin1
# echo "changeme" | passwd gpadmin1 --stdin
# usermod -aG wheel gpadmin1

LINENUM=$(grep -i -n -E ^%wheel ./test.txt | cut -d : -f 1)
sed -i "$LINENUM c\%wheel ALL=(ALL) NOPASSWD: ALL" test.txt
