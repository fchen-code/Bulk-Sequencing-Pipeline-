process samtools_stats {
	container "quay.io/biocontainers/samtools:1.23--h96c455f_0"
    
	publishDir "../results/${meta.test}/${meta.name}/${meta.id}/qc/", mode: "copy"

	input:
	tuple val(meta), path(bam)

	output:
	tuple path("*.flagstat"), path("*.stats")

	script:
	"""
	samtools flagstat ${bam} > ${meta.id}.flagstat
	samtools stats ${bam} > ${meta.id}.stats
	"""    
}
