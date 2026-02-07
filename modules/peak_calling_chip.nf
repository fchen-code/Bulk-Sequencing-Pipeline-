process peak_calling_chip {

        container "quay.io/biocontainers/macs3:3.0.3--py312h4711d71_0"

        publishDir "../results/${meta.test}/${meta.name}/${meta.id}/peaks/", mode: "copy"

        input:
	val(peak_style)
        val(macs2g)
        tuple val(meta), path(chip_bam), path(input_bam)

        output:
        tuple val(meta), path("${meta.id}_peaks.*Peak"), emit: peak
        tuple val(meta), path("*")

        script:
	def arg = (meta.layout == "SE") ? "BAM" : "BAMPE"
        if (task.attempt == 1) {
        """
        macs3 callpeak \
	-t ${chip_bam} \
	-c ${input_bam} \
	-f ${arg} \
	-g ${macs2g} \
	-n ${meta.id} \
	--outdir . \
	-q 0.01 \
	--${peak_style}
        """
        } else {
        """
        macs3 callpeak \
	-t ${chip_bam} \
	-c ${input_bam} \
	-f ${arg} \
	-g ${macs2g} \
	-n ${meta.id} \
	--outdir . \
	-q 0.01 \
	--${peak_style} \
	--nomodel \
	--extsize ${params.extsize}
        """
	}
}
