#/bin/bash +x

for filename in TH*
do

lines=`cat $filename | wc -l`
linemod=$((lines % 10)) 
if [ $linemod -ne 0 ]
then
echo $filename
fi

done
