include {samtools_stats} from "../modules/samtools_stats.nf"
include {insert_metrics} from "../modules/insert_metrics.nf"

workflow SAMTOOLS_STATS {

	take:
	final_bam

	main:
	stats = samtools_stats(final_bam)
        pe_bam = final_bam.filter { meta, bam -> meta.layout == "PE" }
        metrics = insert_metrics(pe_bam).txt
	result = metrics.mix(stats)
	
	emit:
	stats_ch = result
}
