process download_data {

	container "quay.io/biocontainers/sra-tools:3.2.1--h4304569_1"

        publishDir "../data/raw/${files}/", mode: "copy"

        input:
        val(files)
        
	output:
        tuple val(files), path("*.fastq*", arity: '1..2')

	script:
        """
	fasterq-dump ${files} --split-files --threads ${task.cpus}
	gzip -f *.fastq
        """
}
