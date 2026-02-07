include {bowtie2_se} from "../modules/bowtie2_alignment.nf"
include {bowtie2_pe} from "../modules/bowtie2_alignment.nf"
include {bam_index} from "../modules/bam_index.nf"
include {bowtie2_build} from "../modules/bowtie2_build.nf"

workflow BOWTIE2_ALIGNMENT {
	
	take:
	fa_ch
	trimmed_ch
	
	main:
	bt2 = bowtie2_build(fa_ch)

	branches = trimmed_ch.branch{meta, files ->
	single: meta.layout == "SE"
	paired: meta.layout == "PE"
	}

	// SE
	se_result = bowtie2_se(bt2, branches.single)
	se_bam_ch = se_result.bam
	se_log_ch = se_result.log

	// PE
	paired_end = branches.paired.map { meta, files ->
	def R1 = files.find { it.name.endsWith("trimmed_R1.fastq.gz") }
	def R2 = files.find { it.name.endsWith("trimmed_R2.fastq.gz") }
	tuple(meta, R1, R2)
	}

	pe_result = bowtie2_pe(bt2, paired_end)
	pe_bam_ch = pe_result.bam
	pe_log_ch = pe_result.log

	bam_ch = se_bam_ch.mix(pe_bam_ch)
	bowtie2_log_ch = se_log_ch.mix(pe_log_ch)

	emit:
	bam_ch = bam_ch
	log_ch = bowtie2_log_ch
}
