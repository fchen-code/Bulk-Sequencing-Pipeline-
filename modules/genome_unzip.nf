process unzip_gtf {
    
	publishDir "../references/${meta.genome}/gtf", mode: "copy"

	input:
	tuple val(meta), path (zip_file)

	output:
	tuple val(meta), path ("unzipped.gtf")

	script:
	"""
	if [[ "${zip_file}" == *.gz ]]; then
	gunzip -c "${zip_file}" > unzipped.gtf
	else
	cp "${zip_file}" unzipped.gtf
	fi
	"""
}


process unzip_fa {
        
	publishDir "../references/${meta.genome}/fasta", mode: "copy"

        input:
        tuple val(meta), path (zip_file)

        output:
        tuple val(meta), path("unzipped.fa")

        script:
        """
        if [[ "${zip_file}" == *.gz ]]; then
        gunzip -c "${zip_file}" > unzipped.fa
        else
        cp "${zip_file}" unzipped.fa
        fi
        """
}


process unzip_gff3 {

        publishDir "../references/${meta.genome}/gff3", mode: "copy"

        input:
        tuple val(meta), path (zip_file)

        output:
        tuple val(meta), path ("*.gff3")

        script:
        """
        if [[ "${zip_file}" == *.gz ]]; then
        gunzip -c "${zip_file}"
        else
        cp "${zip_file}" unzipped.gff3
        fi
        """
}
