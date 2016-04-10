#! /usr/bin/env bash

gunzip hg19.chr1.fa.gz # unzips file
bowtie2-build hg19.chr1.fa hg19.chr1 # builds index

bowtie2 -x hg19.chr1 -U factorx.chr1.fq.gz | samtools sort -o factorx.sort.bam
# aligns factorx chip data to chr1 then sorts file 

bedtools genomecov -ibam factorx.sort.bam -g hg19.chrom.sizes -bg > factorx.bg
bedGraphToBigWig factorx.hg hg19.chrom.sizes factorx.bw

# pushed factorx.bw file to github
# git add factorx.bw
# git commit -m 'add bw file'
# git branch gh-pages
# git push origin gh-pages

# the following was pasted into uscs browser custum track to visualize factor x chip data 
# track type=bigWig bigDataUrl="http://menzelj.github.io/problem-set-4/data/factorx.bw"
# color=255,0,0 visibility=full name="chip data" description="chip description"

# https://genome.ucsc.edu/cgi-bin/hgTracks?db=hg19&lastVirtModeType=default&lastVirtModeExtraState=&virtModeType=default&virtMode=0&nonVirtPosition=&position=chr1%3A184647060-195643409&hgsid=489151571_9hc0VEUJD2rHZraCdJOzoAlhlHKX

macs2 callpeak -t factorx.sort.bam -f BAM -n factorxpeaks
# this finds peaks of alignments

bedtools slop -i factorxpeaks_summits.bed -g ../../../chip-seq-analysis/data-sets/genome/hg19.genome -b 25 > 25summits.bed
# widens the interval around peak to 25 bp on either side

bedtools getfasta -fi hg19.chr1.fa -bed 25summits.bed -fo out.fa
# gets the fasta sequence of those above intervals

head -n 1000 out.fa > top1000.fa # only takes the top 1000 intervals to reduce processing time of meme

meme top1000.fa -nmotifs 1 -maxw 20 -minw 8 -dna

meme-get-motif -id 1 < meme.txt

# tomtom matched motif to CTCF 
