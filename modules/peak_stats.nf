process peak_stats {

	publishDir "../results/${meta.test}/${meta.name}/${meta.id}/qc/", mode: "copy"

	input:
	tuple val(meta), path(peaks)

	output:
	path("${meta.id}.peak_stats.tsv")

	script:
	"""
	awk '
	BEGIN{OFS="\\t"}
	{
        width = \$3 - \$2
        sum_width += width
        sum_signal += \$7
        n++
	}
	END{
        print "sample","peak_count","mean_width","mean_signal"
        print "${meta.id}",n,sum_width/n,sum_signal/n
	}' ${peaks} > ${meta.id}.peak_stats.tsv
	"""
}
