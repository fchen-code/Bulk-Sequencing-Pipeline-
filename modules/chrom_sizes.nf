process chrom_sizes {

	container "quay.io/biocontainers/samtools:1.23--h96c455f_0"

	publishDir "../references/${meta.genome}/chromsizes/", mode: "copy"
        
	input:
	tuple val(meta), path(fa)
    
	output:
	tuple val(meta), path("${meta.genome}.chrom.sizes")

	script:
	"""
	samtools faidx ${fa}
	cut -f1,2 ${fa}.fai > ${meta.genome}.chrom.sizes
	"""
}
