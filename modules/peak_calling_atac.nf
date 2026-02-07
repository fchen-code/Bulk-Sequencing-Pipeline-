process peak_calling_atac {

	container "quay.io/biocontainers/macs3:3.0.3--py312h4711d71_0"

	publishDir "../results/${meta.test}/${meta.name}/${meta.id}/peaks/", mode: "copy"

	input:
	val(macs2g)
	tuple val(meta), path(bam_file)
    
	output:
	tuple val(meta), path("${meta.id}_peaks.narrowPeak"), emit: narrowpeak
	tuple val(meta), path("*")
    
	script:
	def keepdup = params.atac_rmdup ? "" : "--keep-dup all"
	if (meta.layout == "SE") {
	"""
	macs3 callpeak \
	-t ${bam_file} \
	-f BAM \
	-g ${macs2g} \
	-n ${meta.id} \
	--outdir . \
	-q 0.01 \
	--nomodel \
	--shift -100 \
	--extsize 200 \
	${keepdup} \
	--call-summits
	"""
	} else {
	"""
	macs3 callpeak \
        -t ${bam_file} \
        -f BAMPE \
        -g ${macs2g} \
        -n ${meta.id} \
        --outdir . \
        -q 0.01 \
        ${keepdup} \
        --call-summits
	"""
	}
}
