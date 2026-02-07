# Nextflow Bulk Sequencing

## Description:

* This is a Nextflow-based bulk sequencing pipeline.
* It supports multiple assays, multiple samples, and a shared reference genome.
* Supported assays: RNA-seq, ATAC-seq, ChIP-seq
* All tools are executed using Docker containers to ensure reproducibility.

## Analysis workflow

The pipeline takes raw reads and performs the following steps:

* Quality control (FastQC)
* Alignment (STAR or Bowtie2)
* Blacklist handling
* Duplicate handling
* Read filtering
* Assay-specific analysis
* QC metric calculation
* MultiQC report generation

## Dependencies

* NextFlow >= 25.10.2
* Docker >= 29.1.3

## CSV file

A csv file will be used as list of sample for analysis, file must contain following columns with proper headers:

* Source: Source of the sample (sra for NCBI SRA, local for local files)
* ID: Sample ID, for sra, this must match the NCBI SRA accession
* Name: Run name of the experiment, for ChIP and ChIP_Input, samples must share the same name
* Test: Type of assay, supported values: RNA, ATAC, ChIP and ChIP_Input
* R1: Path to read 1 file (local only; leave empty for SRA)
* R2: Path to read 2 file (local only; leave empty for single-end or SRA)
* Strandedness: Required for RNA-seq feature counting, supported values: unstranded, forward and reverse (Can be left empty for ATAC-seq and ChIP-seq)

## Supported reference genomes

The pipeline provides built-in support for the following reference genomes:

* hg38 (human)
* hg19 (human)
* mm10 (mouse)
* mm39 (mouse)
* sacCer3 (yeast)
* ce11 (C. elegans)
* danRer11 (zebrafish)
* dm6 (Drosophila)
* tair10 (Arabidopsis)

When using a supported genome, only need to specify the genome name, for example:
* nextflow run main.nf --genome saccer3 --atac_blacklist false -profile local

## Support Parameters

Pipeline provide following parameters to give more flexibility for the analysis

* --csv_file: Path to sample CSV file (default: ../assets/samples.csv)
* -profile: Execution profile (local or hpc)
* --fa: Reference genome FASTA file 
* --gtf: Gene annotation in GTF format 
* --gff3: Gene annotation in GFF3 format
* --genome_size: Genome size (required for peak calling with custom genomes)
* --skip_qc_multiqc: Skip QC/MultiQC for specific assays or all assays
* --blacklist: Custom blacklist file (BED format), built-in blacklists are available for hg19, hg38, and mm10
* --rna_blacklist: Enable blacklist filtering for RNA-seq (default: false)
* --atac_blacklist: Enable blacklist filtering for ATAC-seq (default: true)
* --chip_blacklist: Enable blacklist filtering for ChIP-seq (default: true)
* --rna_rmdup: Remove duplicates for RNA-seq (default: false)
* --atac_rmdup: Remove duplicates for ATAC-seq (default: true)
* --chip_rmdup: Remove duplicates for ChIP-seq (default: true)
* --rna_mapq: MAPQ threshold for RNA-seq (default: 10)
* --atac_mapq: MAPQ threshold for ATAC-seq (default: 30)
* --chip_mapq: MAPQ threshold for ChIP-seq (default: 30)
* --bowtie2_sensitivity: Bowtie2 sensitivity preset (default: sensitive)
* --style: Peak calling style (narrow or broad, default: narrow)

## Input:

User need to specify the following as inputs

* For supported genomes:
  * -profile
  * --genome
* For unsupported genomes:
  * -profile
  * --genome
  * --fa (url or local path)
  * --gtf or --gff3 (url or local path)
  * --genome_size

## Output:

Output very depends on the type of test

* For RNA Sequencing, following directories are created for each sample:
  * alignment: contains all the bam files and bai
  * quant: contains feature count and feature count summary files
  * qc (if --skip_qc_multiqc is enabled): contains flagstat and stats files

* For ATAC Sequencing, following directories are created for each sample:
  * alignment: contains all the bam files and bai files
  * homer: contains tagdir folder from the process
  * peaks: contains peak files, bed file, and annotation folder
  * visualization: contains bigwig file
  * qc (if --skip_qc_multiqc is enabled): contains flagstat, alignment statistics, insert_size, frip and peak statistics files

* For ChIP Sequencing, following directories are created for each sample:
  * alignment: contains all the bam files and bai files
  * homer: contains tagdir folder from the process
  * visualization: contains bigwig file
  * qc (if --skip_qc_multiqc is enabled): contains flagstat, alignment statistics, insert_size, frip and peak statistics files

* For ChIP_Input Sequencing, following directories are created for each sample:
  * alignment: contains all the bam files and bai files
  * homer: contains tagdir folder from the process
  * peaks: contains peak files, bed file, and annotation folder
  * visualization: contains bigwig file
  * qc (if --skip_qc_multiqc is enabled): contains flagstat, alignment statistics, insert_size, frip and peak statistics files