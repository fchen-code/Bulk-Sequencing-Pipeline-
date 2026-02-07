process peak_annotate {
    
	container "ghcr.io/fchen-code/homer-genomes:5.1"

	publishDir "../results/${meta1.test}/${meta1.name}/${meta1.id}/peaks/annotation/", mode: "copy"
    
	input:
	tuple val(meta1), path(dir)
	tuple val(meta2), path(peak_file)
	tuple val(meta3), path(gtf_file)
	tuple val(meta4), path(fa)

	output:
	tuple val(meta1), path("${meta1.id}.annotated.txt")
	path("GO"), optional: true
	path("GenomeOntology"), optional: true
    
	script:
	if (meta1.genome.toLowerCase() in ["tair10", "mm10", "mm39", "hg19", "hg38", "ce11", "danrer11", "saccer3", "dm6"]) {
	"""
	annotatePeaks.pl \
	${peak_file} \
	${meta1.genome} \
	-d ${dir} \
	-go GO \
	-genomeOntology GenomeOntology \
	> ${meta1.id}.annotated.txt
	"""
	} else {
	"""
	annotatePeaks.pl \
        ${peak_file} \
        ${fa} \
        -gtf ${gtf_file} \
        -d ${dir} \
        > ${meta1.id}.annotated.txt
	"""
	}
}
