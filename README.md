# <a name="S-table-of-contents"></a> Table of Contents

* [Introduction](S-introduction)
* [Installation](S-installation)
* [Usage](S-usage)
* [Workflow of `dip3d`](S-workflow)
* [A running example](S-a-running-example)

# <a name="S-introduction"></a> Introduction

`dip3d` is a fast and effective high-order diploid human 3D genome construction method for Pore-C reads.
The high data utilization and high-order chromosome fragment interactions captured by Pore-C reads enable us to explore diploid second-order and high-order 3D constructs of human genomes systematically with high resolution.

`dip3d` has many advantages:
* High speed. `dip3d` is capable of processing 574 Gbp Pore-C reads successfully in only one day.
* High SNP calling accuracy. SNPS called with 90X Pore-C reads achieve over 99% of recall, precision and F1-score.
* High SNP phasing accuracy. Using 90X Pore-C reads, the whole genome sequences are in phase. SNPS phased with Pore-C fragments achieve over 99% phasing resolutions. Switch errors are 0.05%~1.18%. Hamming distance are 0.03%~1.37%.
* High data utilization. Using contact rescue, over 63.3% Pore-C fragments are successfully phased and over 78% pairwise contacts are successfully phased.

# <a name="S-installation"></a> Installation

## <a name="SS-prerequisites"></a> prerequisites

`dip3d` depends on the following tools (parentheses are the versions that we used):

* [`falign`](https://github.com/xiaochuanle/Falign) (2.0.0)
* [`bgzip`](https://sourceforge.net/projects/samtools/files/samtools/1.15/) (1.15)
* [`tabix`](https://sourceforge.net/projects/samtools/files/samtools/1.15/) (1.15)
* [`bcftools`](https://sourceforge.net/projects/samtools/files/samtools/1.15/) (1.15)
* [`samtools`](https://sourceforge.net/projects/samtools/files/samtools/1.15/) (1.15)
* [`Clair3`](https://github.com/HKU-BAL/Clair) (v0.1-r10, via docker, ***using this version is mandatory***)
* [`HapCUT2`](https://github.com/vibansal/HapCUT2)
* [`whatshap`](https://github.com/whatshap/whatshap)(1.6)

We download `dip3d` in the `/home/zyserver/chenying/tools` directory:
```shell
$ pwd
/home/zyserver/chenying/tools
```

```shell
$ git clone https://github.com/xiaochuanle/dip3d.git
$ cd dip3d
$ cd models
$ tar xzvf clair3_v0.1-r10_guppy4_model.tar.gz 
$ cd ..
```

# <a name="S-usage"></a> Usage

Remember that we download `dip3d` in directory `/home/zyserver/chenying/tools`.

We run `dip3d` in another directory `/data1/chenying/hg001-3d-genome`:

```shell
$pwd
/data1/chenying/hg001-3d-genome
```
First, we copy `dip3d.sh` in working directory:
```sell
$cp /data3/HG001-pore-c/dip3d/dip3d.sh .
```
We next edit `dip3d.sh` and fill in the following items:
```shell
### 1) Output directory of Dip3D
I_output=hg001-dip3d-output

### 2) Absolute path of reference genome
I_reference=/data1/chenying/dip3d-1/GCA_000001405.15_GRCh38_no_alt_plus_hs38d1_analysis_set.major.fna

### 3) Chromosome list
I_CHR_LIST=(chr1 chr2 chr3 chr4 chr5 chr6 chr7 chr8 chr9 chr10 chr11 chr12 chr13 chr14 chr15 chr16 chr17 chr18 chr19 chr20 chr21 chr22 chrX chrY)

### 4) Number of CPU threads used by Dip3D
I_threads=96

### 5) Directory storing Clair Pore-C model
###    The model is released together with Dip3D
I_clair3_model_directory=/data3/HG001-pore-c/dip3d/models/clair3_v0.1-r10_guppy4_model

### 6) Options for calling SNP by Clair3
###   1. Coverage of Pore-C data
I_snp_frag_coverage=90
###   2. Minimum Pore-C fragment length
I_snp_frag_length=100
###   3. Minimum alignment identities
I_snp_frag_identity=90.0
###   4. Minimum mapping qualities
I_snp_frag_mapQ=5

### 7) Options for select BAM for HapCUT2
I_hapcut_frag_coverage=30
I_hapcut_frag_length=100
I_hapcut_frag_identity=90.0
I_hapcut_frag_mapQ=5

### 7) Options for haplo-tagging Pore-C fragments with SNP
###   1. Number of flanking match residues in overlapped SNP sites
I_snp_tag_match_bases=3
###   2. Only haplo-tagging Pore-C fragments with at least this mapping qualities
I_snp_tag_mapQ=5
###   3. Only haplo-tagging Pore-C fragments with at least this aligment identites
I_snp_tag_identity=85.0

### 8) Options for haplotype imputation
### 1. Maximum genomic distance between adjacent fragment pairs
I_imputation_adj_dist=29500000
### 2. Maximum genomic distacne between non-adjacent fragment pairs
I_imputation_non_adj_dist=16500000

### 9) Absolute path list of Pore-C list
###     Please don't concat concat FASTQ files genergeted with different enzymes into one
I_pore_c_reads=( \
/data1/chenying/dip3d/pore-c/NA12878_Rep1/pass.gt7.fastq.gz
/data1/chenying/dip3d/pore-c/NA12878_Rep2/pass.gt7.fastq.gz
/data1/chenying/dip3d/pore-c/NA12878_Rep3/pass.gt7.fastq.gz
/data1/chenying/dip3d/pore-c/NA12878_Rep4/pass.gt7.fastq.gz
/data1/chenying/dip3d/pore-c/NA12878_Rep5/pass.gt7.fastq.gz
/data1/chenying/dip3d/pore-c/NA12878_Rep8/pass.gt7.fastq.gz
/data1/chenying/dip3d/pore-c/NA12878_Rep9/pass.gt7.fastq.gz
/data1/chenying/dip3d/pore-c/NA12878_Rep10/pass.gt7.fastq.gz
)
```
Finally, we save and run `dip3d.sh`:
```shell
./dip3d.sh
```

# <a name="S-workflow"></a> Workflow of `dip3d`

`dip3d` runs in three steps.

## <a anme="step-one"></a> Step One: Mapping

In this first step, `dip3d` maps Pore-C reads (provided via `I_pore_c_reads`) to the reference genome (provided via `I_reference`) using [`falign`](https://github.com/xiaochuanle/Falign). The mapping results are in [`frag-bam`](https://github.com/xiaochuanle/Falign) format and saved in
```shell
/data1/chenying/hg001-3d-genome/dip3d-output/1-falign/frag-ref.bam
```
Note that this `BAM` file is ***not*** sorted.

## <a name="step-two"></a> Step Two: SNP calling and phasing

If you have previously created a phased SNP VCF file, you can skip this step by providing it to `dip3d`:
``` shell
I_vcf=/absolute-path-to-a-previous-dip3d-output/2-snp/phased_snp.vcf
```
In this case `dip3d` will skip the whole step two.

`dip3d` extracts sequentially 270G (provided by `I_snp_reads`) Pore-C fragments from `/data1/chenying/hg001-3d-genome/dip3d-output/1-falign/frag-ref.bam` and saves the extracted fragments in
``` shell
/data1/chenying/hg001-3d-genome/dip3d-output/2-snp/snp-frag-ref.bam
```
Note that this `snp-frag-ref.bam` is sorted.

[`Clair3`](https://github.com/HKU-BAL/Clair) is used for calling variants with `snp-frag-ref.bam` and the reference genome (provided via `I_reference`). The variants called by [`Clair3`](https://github.com/HKU-BAL/Clair) are saved in
```shell
/data1/chenying/hg001-3d-genome/dip3d-output/2-snp/clair3_output/merge_output.vcf.gz
```
SNPs are extracted from `merge_output.vcf.gz` and saved in
```shell
/data1/chenying/hg001-3d-genome/dip3d-output/2-snp/snp.vcf
/data1/chenying/hg001-3d-genome/dip3d-output/2-snp/snp.vcf.gz
/data1/chenying/hg001-3d-genome/dip3d-output/2-snp/snp.vcf.gz.tbi
```

`snp.vcf` is phased with `snp-frag-ref.bam` by [`HapCUT2`](https://github.com/vibansal/HapCUT2) and [`whatshap`](https://github.com/whatshap/whatshap). The largest phase blocks of each chromosome in the reference genome (provided via `I_reference`) are extracted from the phased SNPs and saved in
``` shell
/data1/chenying/hg001-3d-genome/dip3d-output/2-snp/phased_snp.vcf
/data1/chenying/hg001-3d-genome/dip3d-output/2-snp/phased_snp.vcf.gz
/data1/chenying/hg001-3d-genome/dip3d-output/2-snp/phased_snp.vcf.gz.tbi
```

### <a name="step-three"></a> Step Three: fragment haplotyping

The `frag-bam` file output by Step One
```shell
/data1/chenying/hg001-3d-genome/dip3d-output/1-falign/frag-ref.bam
```
is sorted and saved in
```shell
/data1/chenying/hg001-3d-genome/dip3d-output/3-frag-hap/sorted-frag-ref.bam
```
This sorted `frag-bam` is then phased by `Dip3d` with `phased_snp.vcf`. The phased results are saved in
```shell
/data1/chenying/hg001-3d-genome/dip3d-output/3-frag-hap/chr1/snp-frag-hap.list
/data1/chenying/hg001-3d-genome/dip3d-output/3-frag-hap/chr2/snp-frag-hap.list
...
```
The untaged fragments are then imputed and saved in
```shell
/data1/chenying/hg001-3d-genome/dip3d-output/3-frag-hap/chr1/imputed-frag-hap.list
/data1/chenying/hg001-3d-genome/dip3d-output/3-frag-hap/chr2/imputed-frag-hap.list
...
```

The BAM file of each chromosome is also tagged and stored in
```shell
/data1/chenying/hg001-3d-genome/dip3d-output/3-frag-hap/chr1/tagged-chr1.bam
/data1/chenying/hg001-3d-genome/dip3d-output/3-frag-hap/chr2/tagged-chr2.bam
...
```
This is the final results output by `dip3d`. It is tagged in the same way as [`whatshap`](https://github.com/whatshap/whatshap). That is, `HP:i:1`, `HP:i:2` and untagged.

# <a name="S-a-running-example"></a> A running example

We run an example on the computer equipped with 96 1.5Ghz CPU threads and 256GB RAM.

## datasets

We produce 8 flowcells of NA12878 Pore-C reads in house:
```shell
    /data1/chenying/dip3d/pore-c/NA12878_Rep1/pass.gt7.fastq.gz \
    /data1/chenying/dip3d/pore-c/NA12878_Rep2/pass.gt7.fastq.gz \
    /data1/chenying/dip3d/pore-c/NA12878_Rep3/pass.gt7.fastq.gz \
    /data1/chenying/dip3d/pore-c/NA12878_Rep4/pass.gt7.fastq.gz \
    /data1/chenying/dip3d/pore-c/NA12878_Rep5/pass.gt7.fastq.gz \
    /data1/chenying/dip3d/pore-c/NA12878_Rep8/pass.gt7.fastq.gz \
    /data1/chenying/dip3d/pore-c/NA12878_Rep9/pass.gt7.fastq.gz \
    /data1/chenying/dip3d/pore-c/NA12878_Rep10/pass \
```
There are 123081636 Pore-C reads and 574 Gbp (191.3 X).

## wallclock time
`dip3d` took 25 hours to process the above Pore-C reads.

## SNP calling performance

recall: 99.01%, precision: 99.25, F1-score: 99.13

## SNP phasing performance

* resolutions (the proportion of heterozygous SNPs contained in the largest phased block): 97.6-99.6%
* switch error: 0.05-1.18%
* hamming distance: 0.03-1.37%

## fragment phasing performance

* Total fragments: 564.8m
* phased fragments by H-snp: 134.2m (23.76%)
* phased fragments after imputation: 357.3m (63.3%)

## contacts phasing performance

* Total contacts: 1325m

#### contacts phased by H-snp
* Total: 87.1m (6.6%)

#### phased contacts after imputation
* Total: 1033.5m (78%)
* H1: 513.2m
* H2: 512.9m





