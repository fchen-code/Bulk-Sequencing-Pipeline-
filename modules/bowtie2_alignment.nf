process bowtie2_pe {
    
	container "quay.io/biocontainers/mulled-v2-229691629e0b12c862d76101f90a597d5c1c81d4:484c804e1d5952c9023891b6f9a19f7f15815145-0"
    
	publishDir "../results/${meta.test}/${meta.name}/${meta.id}/alignment/", mode: "copy"

	input:
	path(index)
	tuple val(meta), path(R1), path(R2)

	output:
        tuple val(meta), path ("sorted.bam"), emit: bam
	path("${meta.id}.bowtie2.log"), emit: log

	script:
        """
	idxfile=\$(ls ${index}/*.1.bt2* | head -n 1)
        bowtie2 -p ${task.cpus} -q -x "\${idxfile%.1.bt2*}" \
	-1 ${R1} -2 ${R2} \
        --${params.bowtie2_sensitivity} \
        --no-mixed \
        --no-discordant \
        --no-unal \
        --rg-id ${meta.id} \
	--rg SM:${meta.id} \
	--rg PL:ILLUMINA \
	--rg LB:lib1 \
	--rg PU:${meta.id} \
	${params.bowtie2_args ?: ''} \
	2> ${meta.id}.bowtie2.log \
	| samtools sort -@ ${task.cpus} -o sorted.bam -
        """
}


process bowtie2_se {
    
	container "quay.io/biocontainers/mulled-v2-229691629e0b12c862d76101f90a597d5c1c81d4:484c804e1d5952c9023891b6f9a19f7f15815145-0"    

	publishDir "../results/${meta.test}/${meta.name}/${meta.id}/alignment/", mode: "copy"

	input:
	path(index)
        tuple val(meta), path(file)

	output:
        tuple val(meta), path ("sorted.bam"), emit: bam
	path("${meta.id}.bowtie2.log"), emit: log

	script:
	"""
	bowtie2 -p ${task.cpus} -q -x ${meta.genome} \
	-U ${file} \
	--${params.bowtie2_sensitivity} \
	--no-unal \
	--rg-id ${meta.id} \
	--rg SM:${meta.id} \
	--rg PL:ILLUMINA \
	--rg LB:lib1 \
        --rg PU:${meta.id} \
	${params.bowtie2_args ?: ''} \
	2> ${meta.id}.bowtie2.log \
	| samtools sort -@ ${task.cpus} -o sorted.bam -
	"""
}
