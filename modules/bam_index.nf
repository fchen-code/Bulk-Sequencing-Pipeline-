process bam_index {
    
	container "quay.io/biocontainers/samtools:1.23--h96c455f_0"
    
	publishDir "../results/${meta.test}/${meta.name}/${meta.id}/alignment/", mode: "copy"
    
	input:
	tuple val(meta), path(file)

	output:
	tuple val(meta), path("*.bai"), emit: bai
	tuple val(meta), path(file), path("*.bai"), emit:bam_bai

	script:
	"""
	samtools index ${file}
	"""
}
