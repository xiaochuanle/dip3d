# Introduction

`dip3d-ashic` is a customized version of [`ASHIC`](https://github.com/wmalab/ASHIC). If you have used this pipeline in your research, please cite the [`ASHIC` paper](https://academic.oup.com/nar/article/48/21/e123/5930395?login=false).

# Installation

```shell
$ tar xzvf ASHIC.tar.gz
$ cd ASHIC
$ conda env create -f environment.yml
$ cd ..
```
The above command will create an conda environment name `dip3d-ashic`.

# Usage

`dip3d-ashic` works on the frag list output by `dip3d` such as
```shell
/data1/chenying/dip3d-1/test/dip3d-output/4-bam-haplotag/chrX/imputed-frag-hap-list
```
All the commands are integrated in the shell script file `run-dip3d-ashic.sh`. We first edit this script and fill in the corresponding information:
```shell
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
```

We can then run the script directly:
``` shell
$ conda activate dip3d-ashic
$ ./run-dip3d-ashic.sh
```