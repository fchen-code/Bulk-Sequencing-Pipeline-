process star_alignment {

	container "quay.io/biocontainers/star:2.7.11b--h5ca1c30_8"
    
	publishDir "../results/${meta.test}/${meta.name}/${meta.id}/alignment/", mode: "copy"
    
	input:
	tuple val(meta), path(files), path(star)
	
	output:
	path "*"
	path ("*Log.final.out"), emit: log
	tuple val(meta), path ("*.bam"), emit: bam

	script:
	"""
	STAR --runThreadN ${task.cpus} \
	--runMode alignReads \
	--readFilesIn ${files.join(' ')} \
	--genomeDir ${star} \
	--outSAMtype BAM SortedByCoordinate \
	--outFileNamePrefix ${meta.id}. \
	--readFilesCommand zcat
	"""
}

