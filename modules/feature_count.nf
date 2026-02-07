process feature_count {
    
	container "quay.io/biocontainers/subread:2.1.1--h577a1d6_0"

	publishDir "../results/${meta2.test}/${meta2.name}/${meta2.id}/quant/", mode: "copy"
    
	input:
	tuple val(meta1), path (gtf)
	tuple val(meta2), path(bam)
    
	output:
	path "*"
	tuple path("${meta2.id}_featurecounts.txt"), path("${meta2.id}_featurecounts.txt.summary"), emit: result
    
	script:
	def pb = (meta2.layout == "PE") ? "-p -B" : ""
	def data = (meta2.strandedness ?: "0")
		.toString()
		.toLowerCase()
	def strandedness =
	(data in ["0","unstranded",""]) ? 0 :
	(data in ["1","forward"]) ? 1 :
	(data in ["2","reverse"]) ? 2 :
	error("Invalid strandedness for sample ${meta2.id}")

	"""
	featureCounts -T ${task.cpus} \
	${pb} \
	-s ${strandedness} \
	-t exon \
	-g gene_id \
	-a ${gtf} \
	-o ${meta2.id}_featurecounts.txt \
	${bam}
	"""
}
