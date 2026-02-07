process gff3_convert {

	container "quay.io/biocontainers/gffread:0.12.7--h077b44d_6"

	publishDir { "../references/${meta.genome}/gtf" }, mode: "copy"
    
	input:
	tuple val(meta), path (fa), path(gff3)
	output:
	tuple val(meta), path ("*.gtf.gz")

	script:
	"""
	gffread ${gff3} -T -g ${fa} -o ${meta.genome}.gtf
	gzip -c ${meta.genome}.gtf > ${meta.genome}.gtf.gz
	"""
}
