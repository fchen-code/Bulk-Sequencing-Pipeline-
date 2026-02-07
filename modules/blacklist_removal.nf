process blacklist_removal_auto {

	container "quay.io/biocontainers/bedtools:2.31.1--h13024bc_3"    
    
	publishDir "../results/${meta.test}/${meta.name}/${meta.id}/alignment/", mode: "copy"

	input:
	tuple val(meta), path(bam)

	output:
	tuple val(meta), path("filtered_blacklist_removed.bam")
    
	script:
	"""
	bedtools intersect \
	-v \
	-abam ${bam} \
	-b ../assets/ENCODE_BlackList/${meta.genome}-blacklist.v2.bed
	> filtered_blacklist_removed.bam
	"""
}

process blacklist_removal_manually {

	container "quay.io/biocontainers/bedtools:2.31.1--h13024bc_3"
    
	publishDir "../results/${meta.test}/${meta.name}/${meta.id}/alignment/", mode: "copy"

        input:
        path(blacklist)
        tuple val(meta), path(bam)

        output:
        tuple val(meta), path("filtered_blacklist_removed.bam")

        script:
        """
        bedtools intersect \
        -v \
        -abam ${bam} \
        -b ${blacklist}
        > filtered_blacklist_removed.bam
        """
}
