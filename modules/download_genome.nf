process download_genome_gtf {
	publishDir "../references/${meta.genome}/gtf/", mode: "copy"
    
	input:
	val(meta)
	val(url)
    
	output:
	tuple val(meta), path ("*.gtf.gz")
    
	script:
	"""
	wget -c --tries=3 --waitretry=3 ${url} 
	"""
}

process download_genome_fa {
	publishDir "../references/${meta.genome}/fasta/", mode: "copy"

        input:
	val(meta)
        val(url)

        output:
        tuple val(meta), path ("*.fa.gz")

        script:
        """
        wget -c --tries=3 --waitretry=3 ${url}
        """
}

process download_genome_gff3 {
        publishDir "../references/${meta.genome}/gff3/", mode: "copy"

        input:
    val(meta)
        val(url)

        output:
        tuple val(meta), path ("*.gff3.gz")

        script:
        """
        wget -c --tries=3 --waitretry=3 ${url}
        """
}
