process bowtie2_build {
    
	container "quay.io/biocontainers/bowtie2:2.5.4--he96a11b_7"
    
	publishDir "../references/${meta.genome}/indexes/bowtie2/", mode: "copy"
    
	input:
	tuple val(meta), path(fa)
    
	output:
	path("${meta.genome}.*.bt2*")
    
	script:
	"""
	bowtie2-build --threads ${task.cpus} ${fa} ${meta.genome} 
	"""    
}    
