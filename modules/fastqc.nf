process fastqc_raw {

	container "quay.io/biocontainers/fastqc:0.12.1--hdfd78af_0"
	
	input:
	tuple val(meta), path(files)

	output:
	path("*.zip")

	script:
	"""
	fastqc -t ${task.cpus} ${files}
	"""
}

process fastqc_trimmed {
    
	container "quay.io/biocontainers/fastqc:0.12.1--hdfd78af_0"
    
        input:
        tuple val(meta), path(files)

        output:
        path("*.zip")

        script:
        """
        fastqc -t ${task.cpus} ${files}
        """
}
