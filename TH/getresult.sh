#!/bin/sh -x

######################################################################
#                   Benchmark Nek5000 and nekbone                    #
#                                                                    #
######################################################################


########################## Nek5000 ###################################

####################### Helper functions ###########################
function extract {
  rm log*
  
  grep 'nelt =\|Solve Time =' $1 > log1 
  grep -Eo '[ ][+-]?[0-9]+([.][0-9]+[E][+-][0-9]+)?' log1 > log2
  cat log2 | awk '{getline b; getline c; getline d; getline e;printf("%s %s %s %s %s\n",$0,b,c,d,e)}' > log3
  result=`head -n 1 log3`
  nelt=`echo $result | cut -f 1 -d ' '` 
  np=`echo $result | cut -f 2 -d ' '`
  printf -v name "TH%02dP%05d" $nelt $np
  cat log3  >> ../"${name}${2}"

  rm $1

}
###################################################################


for nx1 in `seq 3 1 3`
do

cd 'rlx'$nx1

for filename in *.o
do

nresults=`grep 'Solve Time =' $filename | wc -l`

if [ $nresults -gt 0 ]
then
  grep 'nelt =\|Solve Time =' $filename | head -n 20 > tmp 
  extract tmp  CGGOV
fi

if [ $nresults -gt 10 ]
then
  mycount=`grep 'nelt =\|Solve Time =' $filename | head -n 40 | wc -l`
  mycount=$(( mycount - 20 ))
  grep 'nelt =\|Solve Time =' $filename | head -n 40 | tail -n $mycount > tmp 
  extract tmp  CGGOV
fi

if [ $nresults -gt 20 ]
then
  mycount=`grep 'nelt =\|Solve Time =' $filename | head -n 60 | wc -l`
  mycount=$(( mycount - 40 ))
  grep 'nelt =\|Solve Time =' $filename | head -n 60 | tail -n $mycount > tmp 
  extract tmp  CGGOV
fi

if [ $nresults -ge 30 ]
then
  mycount=`grep 'nelt =\|Solve Time =' $filename | head -n 80 | wc -l`
  mycount=$(( mycount - 60 ))
  grep 'nelt =\|Solve Time =' $filename | head -n 80 | tail -n $mycount > tmp 
  extract tmp  CGGOV
fi

if [ $nresults -ge 40 ]
then
  mycount=`grep 'nelt =\|Solve Time =' $filename | head -n 100 | wc -l`
  mycount=$(( mycount - 80 ))
  grep 'nelt =\|Solve Time =' $filename | head -n 100 | tail -n $mycount > tmp 
  extract tmp  CGGOV
fi

if [ $nresults -ge 50 ]
then
  mycount=`grep 'nelt =\|Solve Time =' $filename | head -n 120 | wc -l`
  mycount=$(( mycount - 100 ))
  grep 'nelt =\|Solve Time =' $filename | head -n 120 | tail -n $mycount > tmp 
  extract tmp  CGGOV
fi

if [ $nresults -ge 60 ]
then
  mycount=`grep 'nelt =\|Solve Time =' $filename | head -n 140 | wc -l`
  mycount=$(( mycount - 120 ))
  grep 'nelt =\|Solve Time =' $filename | head -n 140 | tail -n $mycount > tmp 
  extract tmp  CGGOV
fi

done

cd ..

done
