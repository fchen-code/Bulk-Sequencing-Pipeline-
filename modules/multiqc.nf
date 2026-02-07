process multiqc_read {
	container "quay.io/biocontainers/multiqc:1.33--pyhdfd78af_0"

	publishDir "../results/${test}/multiqc/read/", mode: "copy"
    
	input:
	val(test)
	path(files)
    
	output:
	path "*"
    
	script:
	"""
	multiqc ${files}
	"""
}



process multiqc_alignment {
	container "quay.io/biocontainers/multiqc:1.33--pyhdfd78af_0"
    
	publishDir "../results/${test}/multiqc/alignment/", mode: "copy"
    
        input:
        val(test)
        path(files)

        output:
        path "*"

        script:
        """
        multiqc ${files}
        """
}
