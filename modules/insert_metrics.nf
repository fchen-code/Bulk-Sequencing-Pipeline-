process insert_metrics {
	container "quay.io/biocontainers/picard:3.4.0--hdfd78af_0"

	publishDir "../results/${meta.test}/${meta.name}/${meta.id}/qc"
    
	input:
	tuple val(meta), path(bam)

	output:
	path("${meta.id}.insert_size_metrics.txt"), emit: txt
	path("${meta.id}.insert_size_histogram.pdf"), emit: pdf

	script:
	"""
	picard CollectInsertSizeMetrics \
	I=${bam} \
	O=${meta.id}.insert_size_metrics.txt \
	H=${meta.id}.insert_size_histogram.pdf \
	M=0.5
	"""
}
