process fastp_sra {
    
	container "quay.io/biocontainers/fastp:1.0.1--heae3180_0"
    
	publishDir "../data/fastp/${srr}/", mode: "copy"
    
	input:
	tuple val(srr), path(files)

	output:
	tuple val(srr), path("${srr}_trimmed*.fastq.gz"), path ("*.html"), path ("*.json")

	script:
	if (files.size() == 2) {
	"""
        fastp -w ${task.cpus} \
        -q 20 \
        -l 20 \
        ${params.fastp_args ?: ''} \
        -i ${files[0]} \
        -o ${srr}_trimmed_R1.fastq.gz \
        -I ${files[1]} \
        -O ${srr}_trimmed_R2.fastq.gz \
        -h ${srr}_fastp.html \
        -j ${srr}_fastp.json
	"""
	} else {
	"""
        fastp -w ${task.cpus} \
        -q 20 \
        -l 20 \
        ${params.fastp_args ?: ''} \
        -i ${files[0]} \
        -o ${srr}_trimmed.fastq.gz \
        -h ${srr}_fastp.html \
        -j ${srr}_fastp.json
	"""
	}
}

process fastp_local {

        container "quay.io/biocontainers/fastp:1.0.1--heae3180_0"

        publishDir "../data/fastp/${meta.id}/", mode: "copy"

        input:
        tuple val(meta), path(files)

        output:
        tuple val("${meta.id}"), path ("${meta.id}_trimmed_*"), path ("*.html"), path ("*.json")

        script:
        if (files.size() == 2) {
        """
        fastp -w ${task.cpus} \
        -q 20 \
        -l 20 \
        ${params.fastp_args ?: ''} \
        -i ${files[0]} \
        -o ${meta.id}_trimmed_R1.fastq.gz \
        -I ${files[1]} \
        -O ${meta.id}_trimmed_R2.fastq.gz \
        -h ${meta.id}_fastp.html \
        -j ${meta.id}_fastp.json
        """
        } else {
        """
        fastp -w ${task.cpus} \
        -q 20 \
        -l 20 \
        ${params.fastp_args ?: ''} \
        -i ${files[0]} \
        -o ${meta.id}_trimmed.fastq.gz \
        -h ${meta.id}_fastp.html \
        -j ${meta.id}_fastp.json
        """
        }
}
