process star_index {

	container "quay.io/biocontainers/star:2.7.11b--h5ca1c30_8"
    
	publishDir "../references/${meta.genome}/indexes/", mode: 'copy'
    
	input:
	tuple val(meta), path(gtf), path(fa)
    
	output:
	path ("STAR"), type: 'dir'
    
	script:
	"""
	STAR --runThreadN ${task.cpus} \
	--runMode genomeGenerate \
	--genomeDir STAR \
	--genomeSAindexNbases 10 \
	--sjdbGTFfile ${gtf} \
	--sjdbOverhang ${params.sjdbOverhang} \
	--genomeFastaFiles ${fa}
	"""
}
