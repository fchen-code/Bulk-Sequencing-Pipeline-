process frip {

	conda 'bioconda::samtools=1.21 bioconda::bedtools=2.31.1'
	
	publishDir "../results/${meta.test}/${meta.name}/${meta.id}/qc/", mode: "copy"

	input:
	tuple val(meta), path(bam), path(peaks)

	output:
	path("${meta.id}.frip.tsv")

	script:
	"""
	total=\$(samtools view -c -F 260 ${bam})

	in_peaks=\$(bedtools intersect \
        -abam ${bam} \
        -b ${peaks} \
        -u \
        | samtools view -c -)

	frip=\$(awk -v a=\$in_peaks -v b=\$total "BEGIN{print (b>0)?a/b:0}")

	echo -e "sample\\tFRiP" > ${meta.id}.frip.tsv
	echo -e "${meta.id}\\t\$frip" >> ${meta.id}.frip.tsv
	"""
}
