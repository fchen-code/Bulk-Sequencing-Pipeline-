include {star_alignment} from "../modules/star_alignment.nf"
include {bam_index} from "../modules/bam_index.nf"
include {star_index} from "../modules/star_index.nf"

workflow STAR_ALIGNMENT {

	take:
        meta
        genomes
        trimmed

	main:
        trimmed.view()
        index = star_index(genomes)
        star_alignment_input = trimmed.combine(index).map{meta, files, star -> tuple(meta, files, star)}
	star_alignment_result = star_alignment(star_alignment_input)
        bam = star_alignment_result.bam
        star_log_ch = star_alignment_result.log
	bai = bam_index(bam).bai
    
	emit:
        bam_ch = bam
        bai_ch = bai
	log_ch = star_log_ch
}
