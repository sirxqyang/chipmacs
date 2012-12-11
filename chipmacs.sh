#!/bin/bash
## 12-11-2012 Xiaoqin Yang
## this script is developed to perform the peakcalling 
## with macs2 and get all files for further analysis.
## 1st, we call the peak with macs2,
## 2nd, change "pileup.bdg" into ".bdg",
## 3rd, intersectBed
## 4th, get the treat.bw file with bedGraphToBigWig,
## 5th, get the Wig file with bigWigToWig.
## finally, send me the comfirming email.

for i in $@
do

	## set the working directory 
	##---------------------------
	
	cd $i


	## 1st part: peakcalling with macs2 
	##------------------------------------

	dcid=$i
	g="hs"
	pvalue="0.00001"
	keepdup="1"
	shiftsize="73"
	ftype="BED"
	foldchange="2"
	tname="${dcid}_rep1_treat.bed"
	nname="${dcid}_rep1"
	macs2 callpeak -g $g -B -p $pvalue --keep-dup $keepdup --nomodel --shiftsize=$shiftsize -f $ftype -F $foldchange -t $tname -n $nname
	step1="macs2 callpeak -g $g -B -p $pvalue --keep-dup $keepdup --nomodel --shiftsize=$shiftsize -f $ftype -F $foldchange -t $tname -n $nname"
	echo $step1 > command.txt

	## 2nd part: rename the pileup.bdg file
	##---------------------------------------------

	oldfile="${dcid}_rep1_treat_pileup.bdg"
	newfile="${dcid}_rep1_treat.bdg" 
	mv $oldfile $newfile
	step2="mv $oldfile $newfile"
	echo $step2 >> command.txt


	## 3rd part: intersectBed
	##-------------------------------

	afile="${dcid}_rep1_treat.bdg"
	bfile='/mnt/Storage/home/yangxq/doc/chr_limit_hg19.bed'
	overlap='1.00'
	tmpfile="${dcid}_rep1_treat.bdg.tmp"
	intersectBed -a $afile -b $bfile -wa -f $overlap > $tmpfile
	step3="intersectBed -a $afile -b $bfile -wa -f $overlap > $tmpfile"
	echo $step3 >> command.txt


	## 4th part: get the bw file
	##----------------------------------

	chromInfo='/mnt/Storage/home/yangxq/doc/chromInfo_hg19.txt'
	bwfile=${dcid}_rep1_treat.bw
	bedGraphToBigWig $tmpfile $chromInfo $bwfile
	step4="bedGraphToBigWig $tmpfile $chromInfo $bwfile"
	echo $step4 >> command.txt


	## 5th part: get the wig file
	##----------------------------------

	wigfile=${dcid}_rep1_treat.wig
	bigWigToWig $bwfile $wigfile
	step5="bigWigToWig $bwfile $wigfile"
	echo $step5 >> command.txt


	## back to the former directory
	##-----------------------------------

	cd ..

done


## finally, send the confirming email to myself
##----------------------------------------------
/usr/sbin/sendmail -t <<EOF
From: Mail testing <xiaoqinyang@yeah.net>                                                                                      
To: sirxqyang@gmail.com
Subject: MACS done!                                                  
----------------------------------
Sweet heart,

Misson accomplished.

me
---------------------------------
EOF
man sendmail
