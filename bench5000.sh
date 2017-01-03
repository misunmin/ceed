#!/bin/bash

######################################################################
#                   Benchmark Nek5000 and nekbone                    #
#                                                                    #
######################################################################


########################## Nek5000 ###################################

# Helper function
function log2 {
    local x=0
    for (( y=$1-1 ; $y > 0; y >>= 1 )) ; do
        let x=$x+1
    done
    echo $x
}

# Move to box folder where the nek5000 benchmark is
cd ~/box

# Set session name
printf "b\n." > SESSION.NAME

# Create new files to store the results (redundant, remove?)
for nelt in 1 2 4 8 16
do
for rank in 1 2 4 8 16 32 64
do
 printf -v name "DQ%02dP%05d" $nelt $rank
 echo "nelt np nx1 elements time" > "$name"
done
done

# Init parameters in SIZE file
sed -i "s/lx1=[0-9]*/lx1=3/" SIZE
sed -i "s/lxd=[0-9]*/lxd=5/" SIZE

for nx1 in `seq 3 1 20`                                    # Main loop
do

sh ./clean.sh
makenek b

# Run through all the MPI ranks 1, 2, 4 .. 32
# Five samples are taken for each rank.
for rank in 1 2 4 8 16 32 64                                         # Rank 
do

for nelt in 1 2 4 8 16                                           # nelt
do

# Select the file to write output
printf -v name "DQ%02dP%05d" $nelt $rank

# Set the number of elements in box file.
prod=$((rank*nelt))
prod=$(log2 $prod)

if [ $((prod%3)) -eq 0 ]
then
  nez=$((prod/3)) 
  ney=$((prod/3)) 
  nex=$((prod/3)) 
elif [ $((prod%3)) -eq 1 ] 
then 
  nez=$((prod/3 +1)) 
  ney=$((prod/3)) 
  nex=$((prod/3)) 
elif [ $((prod%3)) -eq 2 ] 
then
  nez=$((prod/3 +1)) 
  ney=$((prod/3 +1)) 
  nex=$((prod/3)) 
fi

nex=$((2**nex))
ney=$((2**ney))
nez=$((2**nez))

sed -i "5s/.*/-$nex -$ney -$nez/" b.box

# Generate the box, create the executable.
genbb b

# Run the executable
nekmpi b $rank > log

# Extract Data
grep 'nelt =\|Solve Time =' log | tail -n 10 > log1
grep -Eo '[ ][+-]?[0-9]+([.][0-9]+[E][+-][0-9]+)?' log1 > log2
cat log2 | xargs -n5 -d'\n' >> "$name" 

done                                                            # nelt

done                                                            # Rank

newnx1=$((nx1+1))
if [ $((nx1%2)) -eq 0 ]
then
  oldnxd=$((nx1*3/2))
  newnxd=$((newnx1*3/2 +1))
else
  oldnxd=$((nx1*3/2 +1))
  newnxd=$((newnx1*3/2))
fi

sed -i "s/lx1=$nx1/lx1=$newnx1/" SIZE
sed -i "s/lxd=$oldnxd/lxd=$newnxd/" SIZE

done                                                        #Main loop

rm log*
