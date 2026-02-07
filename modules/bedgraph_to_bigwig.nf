process bedgraph_to_bigwig {
    
	container "quay.io/biocontainers/mulled-v2-0706fce4651afdd140e6493139959dc8d83d2674:379771e663a512eeb057976c09bef0978a8c85cc-2"

	publishDir "../results/${meta.test}/${meta.name}/${meta.id}/visualization/", mode: "copy"

	input:
	tuple val(meta), path(chromsizes_file)
	tuple val(meta), path(bedgraph)

	output:
	tuple val(meta), path("${meta.id}.bw")

	script:
	"""
	gunzip -c ${bedgraph} > ${meta.id}.bedGraph
	bedGraphToBigWig ${meta.id}.bedGraph ${chromsizes_file} ${meta.id}.bw
	"""
}
