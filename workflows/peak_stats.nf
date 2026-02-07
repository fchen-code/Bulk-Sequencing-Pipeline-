include {peak_stats} from "../modules/peak_stats.nf"

workflow PEAK_STATS {

	take:
	peak

	main:
	stats = peak_stats(peak)

	emit:
	stats_ch = stats
}
