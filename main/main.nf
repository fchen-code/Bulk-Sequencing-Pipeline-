#!/usr/bin/env nextflow
nextflow.enable.dsl=2

include {DATA_PREPROCESS} from "../workflows/data_preprocess.nf"
include {GENOME_OBTAIN} from "../workflows/genome_obtain.nf"
include {STAR_ALIGNMENT} from "../workflows/star_alignment.nf"
include {FEATURECALL} from "../workflows/feature_call.nf"
include {BOWTIE2_ALIGNMENT as BOWTIE2_ALIGNMENT_RNA} from "../workflows/bowtie2_alignment.nf"
include {BOWTIE2_ALIGNMENT as BOWTIE2_ALIGNMENT_ATAC} from "../workflows/bowtie2_alignment.nf"
include {BOWTIE2_ALIGNMENT as BOWTIE2_ALIGNMENT_CHIP} from "../workflows/bowtie2_alignment.nf"
include {BOWTIE2_ALIGNMENT as BOWTIE2_ALIGNMENT_CHIP_INPUT} from "../workflows/bowtie2_alignment.nf"
include {QUALITY_FILTER as QUALITY_FILTER_RNA} from "../workflows/quality_filter.nf"
include {QUALITY_FILTER as QUALITY_FILTER_ATAC} from "../workflows/quality_filter.nf"
include {QUALITY_FILTER as QUALITY_FILTER_CHIP} from "../workflows/quality_filter.nf"
include {QUALITY_FILTER as QUALITY_FILTER_CHIP_INPUT} from "../workflows/quality_filter.nf"
include {TAGDIR as TAGDIR_ATAC} from "../workflows/tagdir.nf"
include {TAGDIR as TAGDIR_CHIP} from "../workflows/tagdir.nf"
include {TAGDIR as TAGDIR_CHIP_INPUT} from "../workflows/tagdir.nf"
include {PEAK_ANNOTATION_ATAC} from "../workflows/peak_annotation_atac.nf"
include {PEAK_ANNOTATION_CHIP} from "../workflows/peak_annotation_chip.nf"
include {MAKE_BIGWIG as MAKE_BIGWIG_ATAC} from "../workflows/make_bigwig.nf"
include {MAKE_BIGWIG as MAKE_BIGWIG_CHIP} from "../workflows/make_bigwig.nf"
include {MAKE_BIGWIG as MAKE_BIGWIG_CHIP_INPUT} from "../workflows/make_bigwig.nf"
include {MULTIQC as MULTIQC_RNA} from "../workflows/multiqc.nf"
include {MULTIQC as MULTIQC_ATAC} from "../workflows/multiqc.nf"
include {MULTIQC as MULTIQC_CHIP} from "../workflows/multiqc.nf"
include {MULTIQC as MULTIQC_CHIP_INPUT} from "../workflows/multiqc.nf"
include {FASTQC as FASTQC_RNA} from "../workflows/fastqc.nf"
include {FASTQC as FASTQC_ATAC} from "../workflows/fastqc.nf"
include {FASTQC as FASTQC_CHIP} from "../workflows/fastqc.nf"
include {FASTQC as FASTQC_CHIP_INPUT} from "../workflows/fastqc.nf"
include {SAMTOOLS_STATS as SAMTOOLS_STATS_RNA} from "../workflows/samtools_stats.nf"
include {SAMTOOLS_STATS as SAMTOOLS_STATS_ATAC} from "../workflows/samtools_stats.nf"
include {SAMTOOLS_STATS as SAMTOOLS_STATS_CHIP} from "../workflows/samtools_stats.nf"
include {SAMTOOLS_STATS as SAMTOOLS_STATS_CHIP_INPUT} from "../workflows/samtools_stats.nf"
include {FRIP as FRIP_ATAC} from "../workflows/frip.nf"
include {FRIP as FRIP_CHIP} from "../workflows/frip.nf"
include {PEAK_STATS as PEAK_STATS_ATAC} from "../workflows/peak_stats.nf"
include {PEAK_STATS as PEAK_STATS_CHIP} from "../workflows/peak_stats.nf"

workflow {
	if (!params.genome) {
                        error "Please provide the valid genome"
		}

        // Data download and fastp preprocessing
                DATA_PREPROCESS(params.csv_file, params.genome)

        // separate the raw rna, atac, chip files 
        raw_rna  = DATA_PREPROCESS.out.raw_ch.filter{meta, files -> meta.test == "rna"}
        raw_atac  = DATA_PREPROCESS.out.raw_ch.filter{meta, files -> meta.test == "atac"}
        raw_chip  = DATA_PREPROCESS.out.raw_ch.filter{meta, files -> meta.test == "chip"}
        raw_chip_input  = DATA_PREPROCESS.out.raw_ch.filter{meta, files -> meta.test == "chip_input"}

        // separate the trimmed rna, atac, chip files
        trimmed_rna  = DATA_PREPROCESS.out.trimmed_ch.filter{meta, files, html, json -> meta.test == "rna"}
        trimmed_atac = DATA_PREPROCESS.out.trimmed_ch.filter{meta, files, html, json -> meta.test == "atac"}
        trimmed_chip = DATA_PREPROCESS.out.trimmed_ch.filter{meta, files, html, json -> meta.test == "chip"}
        trimmed_chip_input = DATA_PREPROCESS.out.trimmed_ch.filter{meta, files, html, json -> meta.test == "chip_input"}

        // separate the html and json files from trimmed files
        json_rna = trimmed_rna.map{meta, files, html, json -> json}
        html_rna = trimmed_rna.map{meta, files, html, json -> html}
	
        json_atac = trimmed_atac.map{meta, files, html, json -> json}
        html_atac = trimmed_atac.map{meta, files, html, json -> html}

        json_chip = trimmed_chip.map{meta, files, html, json -> json}
        html_chip = trimmed_chip.map{meta, files, html, json -> html}

	json_chip_input = trimmed_chip_input.map{meta, files, html, json -> json}
        html_chip_input = trimmed_chip_input.map{meta, files, html, json -> html}

        // separate the tuple meta with files from trimmed files
        trimmed_rna_reads = trimmed_rna.map {meta, files, html, json -> tuple(meta, files)}
        trimmed_atac_reads = trimmed_atac.map {meta, files, html, json -> tuple(meta, files)}
        trimmed_chip_reads = trimmed_chip.map {meta, files, html, json -> tuple(meta, files)}
        trimmed_chip_input_reads = trimmed_chip_input.map {meta, files, html, json -> tuple(meta, files)}
        
        //separate the meta for each test
        meta_rna = trimmed_rna.map {meta, files, html, json -> meta}
        meta_atac = trimmed_atac.map {meta, files, html, json -> meta}
        meta_chip = trimmed_chip.map {meta, files, html, json -> meta}
        meta_chip_input = trimmed_chip_input.map {meta, files, html, json -> meta}

        // One-time genome processing
        meta = [genome: params.genome]
        GENOME_OBTAIN(meta, params.genome, params.genomes, params.fa, params.gff3, params.gtf, params.is_url)
        if (params.rna_aligner.toLowerCase() == "star" || (params.genome.toLowerCase() in ['ecoli','e_coli'])) {
            STAR_ALIGNMENT(meta_rna, GENOME_OBTAIN.out.genomes_ch, trimmed_rna_reads)
            QUALITY_FILTER_RNA(STAR_ALIGNMENT.out.bam_ch, params.genome, params.blacklist, params.rna_blacklist)
            FEATURECALL(meta_rna, GENOME_OBTAIN.out.gtf_ch, QUALITY_FILTER_RNA.out.final_bam_ch)
        } else {
            BOWTIE2_ALIGNMENT_RNA(GENOME_OBTAIN.out.fa_ch, trimmed_rna_reads)
            QUALITY_FILTER_RNA(BOWTIE2_ALIGNMENT_RNA.out.bam_ch, params.genome, params.blacklist, params.rna_blacklist)
            FEATURECALL(meta_rna, GENOME_OBTAIN.out.gtf_ch, QUALITY_FILTER_RNA.out.final_bam_ch)
        }

        // ATAC analysis pipeline
        BOWTIE2_ALIGNMENT_ATAC(GENOME_OBTAIN.out.fa_ch, trimmed_atac_reads)
        QUALITY_FILTER_ATAC(BOWTIE2_ALIGNMENT_ATAC.out.bam_ch, params.genome, params.blacklist, params.atac_blacklist)
        TAGDIR_ATAC(GENOME_OBTAIN.out.fa_ch, QUALITY_FILTER_ATAC.out.final_bam_ch)
        PEAK_ANNOTATION_ATAC(params.genome, QUALITY_FILTER_ATAC.out.final_bam_ch, GENOME_OBTAIN.out.gtf_ch, TAGDIR_ATAC.out.tag_dir_ch, GENOME_OBTAIN.out.fa_ch, params.genome_size)
        MAKE_BIGWIG_ATAC(meta, TAGDIR_ATAC.out.tag_dir_ch, GENOME_OBTAIN.out.fa_ch, params.genomes, params.genome)
        
        // ChIP analysis pipeline
        BOWTIE2_ALIGNMENT_CHIP(GENOME_OBTAIN.out.fa_ch, trimmed_chip_reads)
        QUALITY_FILTER_CHIP(BOWTIE2_ALIGNMENT_CHIP.out.bam_ch, params.genome, params.blacklist, params.chip_blacklist)
        TAGDIR_CHIP(GENOME_OBTAIN.out.fa_ch, QUALITY_FILTER_CHIP.out.final_bam_ch)
        MAKE_BIGWIG_CHIP(meta, TAGDIR_CHIP.out.tag_dir_ch, GENOME_OBTAIN.out.fa_ch, params.genomes, params.genome)

        // ChIP Input analysis pipeline
        BOWTIE2_ALIGNMENT_CHIP_INPUT(GENOME_OBTAIN.out.fa_ch, trimmed_chip_input_reads)
        QUALITY_FILTER_CHIP_INPUT(BOWTIE2_ALIGNMENT_CHIP_INPUT.out.bam_ch, params.genome, params.blacklist, params.chip_blacklist)
        TAGDIR_CHIP_INPUT(GENOME_OBTAIN.out.fa_ch, QUALITY_FILTER_CHIP_INPUT.out.final_bam_ch)
        MAKE_BIGWIG_CHIP_INPUT(meta, TAGDIR_CHIP_INPUT.out.tag_dir_ch, GENOME_OBTAIN.out.fa_ch, params.genomes, params.genome)

        // ChIP and ChIP Input peak annotation
        bam_name_chip = QUALITY_FILTER_CHIP.out.final_bam_ch.map{meta, files -> tuple(meta.name, meta, files)}
        bam_name_chip_input = QUALITY_FILTER_CHIP_INPUT.out.final_bam_ch.map{meta, files -> tuple(meta.name, meta, files)}
        tagdir_name_chip = TAGDIR_CHIP.out.tag_dir_ch.map{meta, dir -> tuple(meta.name, dir)}
        chip_chip_input = bam_name_chip
                  .join(bam_name_chip_input)
                  .join(tagdir_name_chip)
                  .map{name, meta_chip, files_chip, meta_chip_input, files_chip_input, dir -> tuple(meta_chip_input, files_chip, files_chip_input, dir)}
        PEAK_ANNOTATION_CHIP(params.style, params.genome, GENOME_OBTAIN.out.gtf_ch, chip_chip_input, GENOME_OBTAIN.out.fa_ch, params.genome_size)
        

	def skip = (params.skip_qc_multiqc ?: "")
		?.toLowerCase()
                ?.tokenize(',')

        // Multiqc RNA pipeline
	if (!(skip.contains('rna') || skip.contains('all'))) {
		FASTQC_RNA(raw_rna, trimmed_rna_reads)
		SAMTOOLS_STATS_RNA(QUALITY_FILTER_RNA.out.final_bam_ch)
		if (params.rna_aligner.toLowerCase() == "star") {
			multiqc_input_alignment_rna = STAR_ALIGNMENT.out.log_ch
                        .mix(SAMTOOLS_STATS_RNA.out.stats_ch)
                        .mix(QUALITY_FILTER_RNA.out.dup_removed_txt)
                        .collect()
		} else {
			 multiqc_input_alignment_rna = BOWTIE2_ALIGNMENT_RNA.out.log_ch
			.mix(SAMTOOLS_STATS_RNA.out.stats_ch)
			.mix(QUALITY_FILTER_RNA.out.dup_removed_txt)
			.collect()
		}
		
		multiqc_input_read_rna = json_rna
					.mix(html_rna)
					.mix(FASTQC_RNA.out.raw_ch)
					.mix(FASTQC_RNA.out.trimmed_ch)
					.collect()
            
		MULTIQC_RNA("rna", multiqc_input_read_rna, multiqc_input_alignment_rna)
	}
        
        // Multiqc ATAC pipeline
        if (!(skip.contains('atac') || skip.contains('all'))) {
		FASTQC_ATAC(raw_atac, trimmed_atac_reads)
		SAMTOOLS_STATS_ATAC(QUALITY_FILTER_ATAC.out.final_bam_ch)
		
		frip_atac_input = QUALITY_FILTER_ATAC.out.final_bam_ch
					.combine(PEAK_ANNOTATION_ATAC.out.peak_ch)
					.map{meta1, bam, meta2, peak -> tuple(meta2, bam, peak)}
                FRIP_ATAC(frip_atac_input)
		PEAK_STATS_ATAC(PEAK_ANNOTATION_ATAC.out.peak_ch)
            
		multiqc_input_read_atac = json_atac
					.mix(html_atac)
					.mix(FASTQC_ATAC.out.raw_ch)
					.mix(FASTQC_ATAC.out.trimmed_ch)
					.collect()
            
		multiqc_input_alignment_atac = BOWTIE2_ALIGNMENT_ATAC.out.log_ch
						.mix(SAMTOOLS_STATS_ATAC.out.stats_ch)
						.mix(QUALITY_FILTER_ATAC.out.dup_removed_txt)
						.mix(FRIP_ATAC.out.frip_ch)
						.mix(PEAK_STATS_ATAC.out.stats_ch)
						.collect()
		MULTIQC_ATAC(
			"atac",
			multiqc_input_read_atac,
			multiqc_input_alignment_atac
			)
	}
	
	// Multiqc CHIP pipeline
	if (!(skip.contains('chip') || skip.contains('all'))) {
		FASTQC_CHIP(raw_chip, trimmed_chip_reads)
		SAMTOOLS_STATS_CHIP(QUALITY_FILTER_CHIP.out.final_bam_ch)
		FASTQC_CHIP_INPUT(raw_chip_input, trimmed_chip_input_reads)
                SAMTOOLS_STATS_CHIP_INPUT(QUALITY_FILTER_CHIP_INPUT.out.final_bam_ch)
		
		frip_chip_input = QUALITY_FILTER_CHIP.out.final_bam_ch
						.combine(PEAK_ANNOTATION_CHIP.out.peak_ch)
						.map{meta1, bam, meta2, peak -> tuple(meta2, bam, peak)}
                FRIP_CHIP(frip_chip_input)
                PEAK_STATS_CHIP(PEAK_ANNOTATION_CHIP.out.peak_ch)

		multiqc_input_read_chip = json_chip
					.mix(html_chip)
					.mix(FASTQC_CHIP.out.raw_ch)
					.mix(FASTQC_CHIP.out.trimmed_ch)
					.mix(json_chip_input)
					.mix(html_chip_input)
					.mix(FASTQC_CHIP_INPUT.out.raw_ch)
					.mix(FASTQC_CHIP_INPUT.out.trimmed_ch)
					.collect()

		multiqc_input_alignment_chip = BOWTIE2_ALIGNMENT_CHIP.out.log_ch
						.mix(SAMTOOLS_STATS_CHIP.out.stats_ch)
						.mix(QUALITY_FILTER_CHIP.out.dup_removed_txt)
						.mix(BOWTIE2_ALIGNMENT_CHIP_INPUT.out.log_ch)
						.mix(SAMTOOLS_STATS_CHIP_INPUT.out.stats_ch)
						.mix(QUALITY_FILTER_CHIP_INPUT.out.dup_removed_txt)
						.mix(FRIP_CHIP.out.frip_ch)
						.mix(PEAK_STATS_CHIP.out.stats_ch)
						.collect()
		MULTIQC_CHIP(
			"chip",
			multiqc_input_read_chip,
			multiqc_input_alignment_chip
			)
	}
}

