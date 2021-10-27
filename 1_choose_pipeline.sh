#!/bin/bash

input=("$1")
echo "$input"

# Send sketch of input
bbmap/sendsketch.sh $input >$input".sketch"

# Extract 4th line, last column, only genus
genus=$(awk 'NR == 4{print;exit}' $input.sketch | cut -f 12 | cut -d" " -f 1)
echo $genus

# Get full taxonomy description for input
bbmap/taxonomy.sh tree=taxonomy_bbtools/tree.taxtree.gz $genus >$input.taxaID

# Conditional statement to redirect pipeline
if [[ $(grep "superkingdom" $input".taxaID" | cut -f 3) = 'Bacteria' ]]  
then
	 echo "==> use pipeline for bacteria"

elif [[ $(grep -w "kingdom" $input".taxaID" |cut -f 3) = 'Fungi' ]]
then
        echo "==> use pipeline for fungi"

elif [[ $(grep "phylum" $input".taxaID" | cut -f 3) = 'Oomycota' ]]
then
	echo "==> use pipeline for oomycetes"

elif [[ $(grep "Could not find node" $input".taxaID")  ]]
then

	echo "==> can not process taxonomy, trying again"

	genus2=$(awk 'NR == 4{print;exit}' $input.sketch | cut -f 12 | tr " " "_")
	
	echo $genus2

	bbmap/taxonomy.sh tree=taxonomy_bbtools/tree.taxtree.gz $genus2 >$input.taxaID

elif [[ $(grep "superkingdom" $input".taxaID" | cut -f 3) = 'Viruses' ]]
then
	echo "==> use pipeline for viruses"

else
	echo "==> dataset can not be analyzed"
fi


