process dup_removal {

	container "quay.io/biocontainers/picard:3.4.0--hdfd78af_0"

	publishDir "../results/${meta.test}/${meta.name}/${meta.id}/alignment/", mode: "copy"
    
	input:
	tuple val(meta), path(bam)
    
	output:
	tuple val(meta), path("sorted_dedup.bam"), emit: bam
	path("${meta.id}_sorted_dedup.txt"), emit: txt

	script:
	def test = meta.test	
	
	//define removal based on test type
	def removal =
	test == "rna"  ? params.rna_rmdup:
	test == "chip" ? params.chip_rmdup:
	test == "chip_input" ? params.chip_rmdup:
	test == "atac"	? params.atac_rmdup:
	false
	
	"""
	picard MarkDuplicates \
	I=${bam} \
	O=sorted_dedup.bam \
	M=${meta.id}_sorted_dedup.txt \
	REMOVE_DUPLICATES=${removal} \
	VALIDATION_STRINGENCY=LENIENT
	"""
}
