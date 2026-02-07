process sort {

	container "quay.io/biocontainers/sambamba:1.0.1--he614052_4"

	publishDir "../results/${meta.test}/${meta.name}/${meta.id}/alignment/", mode: "copy"

	input:
	tuple val(meta), path(file)

	output:
	tuple val(meta), path("${meta.id}_final_sorted.bam")
    
	script:
	"""
	sambamba sort -t ${task.cpus} \
	-t ${task.cpus} \
	-o ${meta.id}_final_sorted.bam \
	${file}
	"""
}
