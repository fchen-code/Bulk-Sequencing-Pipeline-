include {make_bedgraph} from "../modules/make_bedgraph.nf"
include {bedgraph_to_bigwig} from "../modules/bedgraph_to_bigwig.nf"
include {chrom_sizes} from "../modules/chrom_sizes.nf"

workflow MAKE_BIGWIG {

	take:
        meta
        tagdir_ch
	unzipped_ref_ch
        genomes
        genome
    
	main:
        chromsizes_file = chrom_sizes(unzipped_ref_ch)
        bedgraph_file = make_bedgraph(tagdir_ch)
        bigwig = bedgraph_to_bigwig(chromsizes_file, bedgraph_file)
    
	emit:
        bigwig_ch = bigwig
}

