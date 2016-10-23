#!/bin/sh
ls -ARl | egrep "^[-|d]" | sort -rn -k 5,5 | awk 'BEGIN{total_size=0; total_dir=0; total_regfile=0; line=1}  {total_size+=$5}  /^-/ && line < 6 {print ++total_regfile ,":", $5, $9; line++; } /^-/ && line == 6 {++total_regfile}  /^d/{total_dir+=1} END{print  "Dir num:", total_dir, "\nFile num:", total_regfile,"\nTotal:", total_size }'

