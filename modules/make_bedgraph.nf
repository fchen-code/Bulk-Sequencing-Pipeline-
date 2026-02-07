process make_bedgraph {
	container "quay.io/biocontainers/homer:5.1--pl5262h9948957_0"
 
	publishDir "../results/${meta.test}/${meta.name}/${meta.id}/visualization/", mode: "copy"
	input:
	tuple val(meta), path(tagdir)


	output:
	tuple val(meta), path ("tagdir/*.bedGraph.gz")

	script:
	"""
	makeUCSCfile ${tagdir} -o auto -style dnase
	"""
    
}
