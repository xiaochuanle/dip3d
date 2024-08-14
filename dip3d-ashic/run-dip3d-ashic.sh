#!/bin/bash

### 1) absolute path of reference
REF=/data1/chenying/dip3d-1/GCA_000001405.15_GRCh38_no_alt_plus_hs38d1_analysis_set.major.fna

### 2) resolution of contact matrices
I_ASHIC_RES=25000

### 3) minimum mapping quality of fragment mappings
I_ASHIC_mapQ=5

### 4) the ASHIC model used
I_ASHIC_MODEL="ASHIC-ZIPM"
#I_ASHIC_MODEL="ASHIC-PM"

### 5) chromosome and its coordinates
chr=chrX
START=110500000
END=136500000

### 6) the fragment file path output by dip3d
FRAG=/data1/chenying/dip3d-1/test/dip3d-output/4-bam-haplotag/chrX/imputed-frag-hap-list

### 7) output directory
WRK=imputed-ashic-${I_ASHIC_RES}

### 8) absolute path to dip3d-ashic
I_dip3d_ashic=/data1/chenying/dip3d-1/dip3d/dip3d-ashic/ASHIC

#####################################

CMD="dip3d extract-ashic-chr-size ${REF} ${WRK}/chrom.sizes"
echo "Running command"
echo "  ${CMD}"
${CMD}
if [ $? -ne 0 ]; then
    exit 1
fi

CMD="dip3d frag-to-ashic-read-pair ${FRAG} ${chr} ${I_ASHIC_mapQ} ${WRK}/ashic-read-pair"
echo "Running command"
echo "  ${CMD}"
${CMD}
if [ $? -ne 0 ]; then
    exit 1
fi

CMD="python ${I_dip3d_ashic}/ashic/cli/ashic_data.py split2chrs --chr1 1 --allele1 3 --chr2 4 --allele2 6 ${WRK}/ashic-read-pair ${WRK}"
echo "Running command"
echo "  ${CMD}"
${CMD}
if [ $? -ne 0 ]; then
    exit 1
fi

CMD="python ${I_dip3d_ashic}/ashic/cli/ashic_data.py binning --start ${START} --end ${END} --c1=1 --p1=2 --a1=3 --c2=4 --p2=5 --a2=6 --res=${I_ASHIC_RES} --chrom=${chr} --genome ${WRK}/chrom.sizes ${WRK}/ashic-read-pair ${WRK}"
echo "Running command"
echo "  ${CMD}"
${CMD}
if [ $? -ne 0 ]; then
    exit 1
fi

CMD="python ${I_dip3d_ashic}/ashic/cli/ashic_data.py pack ${WRK} ${WRK}"
echo "Running command"
echo "  ${CMD}"
${CMD}
if [ $? -ne 0 ]; then
    exit 1
fi

CMD="python ${I_dip3d_ashic}/ashic/__main__.py --max-iter 100 -i ${WRK}/ashic-read-pair_*.pickle -o ${WRK}/${I_ASHIC_MODEL} --model ${I_ASHIC_MODEL}"
echo "Running command"
echo "  ${CMD}"
${CMD}
if [ $? -ne 0 ]; then
    exit 1
fi
