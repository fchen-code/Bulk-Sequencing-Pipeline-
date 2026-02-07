process filter{

	container "quay.io/biocontainers/sambamba:1.0.1--he614052_4"

	publishDir "../results/${meta.test}/${meta.name}/${meta.id}/alignment/", mode: "copy"

	input:
	tuple val(meta), path(bam)

	output:
	tuple val(meta), path("filtered.bam")

	script:

	def chr = (meta.test == 'atac') ? " and ref_name != 'chrM' and ref_name != 'MT'": ''

	def filter =
	meta.test == 'rna'  ? params.rna_mapq + chr:
	meta.test == 'chip' ? params.chip_mapq + chr:
	meta.test == 'chip_input' ? params.chip_mapq + chr :
	/* atac */        params.atac_mapq + chr
	"""
	sambamba view -h -f bam -t ${task.cpus} \
	-F "not unmapped and not secondary_alignment and not failed_quality_control and mapping_quality >= ${filter}" \
	-o filtered.bam \
	${bam}    
	"""
}
