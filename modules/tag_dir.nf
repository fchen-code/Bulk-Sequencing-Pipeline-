process tag_dir {

	stageInMode = 'copy'

        container "ghcr.io/fchen-code/homer-genomes:5.1"

        publishDir "../results/${meta.test}/${meta.name}/${meta.id}/homer/", mode: "copy"

        input:
	tuple val(meta), path(fa)
        tuple val(meta), path(bam)

        output:
        tuple val(meta), path("tagdir")

        script:
	def gc = (params.checkGC) ? "-checkGC" : ""
        
	if (meta.genome in ["tair10", "mm10", "mm39", "hg19", "hg38", "ce11", "danrer11", "sacCer3", "dm6"]) {
        """
        makeTagDirectory \
        tagdir \
        ${bam} \
        ${gc} \
        -genome ${meta.genome} \
        -tbp 1
        """
        } else {
        """
        makeTagDirectory \
        tagdir \
        ${bam} \
	${gc} \
        -genome ${fa} \
        -tbp 1
        """
        }
}
