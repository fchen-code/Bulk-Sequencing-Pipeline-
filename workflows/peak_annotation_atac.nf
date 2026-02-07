include {peak_calling_atac} from "../modules/peak_calling_atac.nf"
include {peak_annotate} from "../modules/peak_annotate.nf"

workflow PEAK_ANNOTATION_ATAC {
	
	take:
        genome
        final_bam_ch
        gtf_ch
        tagdir
        fa_ch
        genome_size
    
	main:
        def macs2g

	if (genome_size) {
		macs2g = genome_size
	} else if (genome.toLowerCase() in ["tair10", "mm10", "mm39", "hg19", "hg38", "ce11", "danRer11", "saccer3", "dm6"])  {
		switch (genome.toLowerCase()) {
			case "hg38":
			case "hg19":
			macs2g = "hs"
			break
			case "mm10":
			case "mm9":
			macs2g = "mm"
			break
			case "dm6":
			macs2g = "dm"
			break
			case "saccer3":
			macs2g = "1.21e7"
			break
			case "danrer11":
			macs2g = "zf"
			break
			case "tair10":
			macs2g = "1.2e8"
			break
			case "ce11":
			macs2g = "9e7"
			break
			}
	} else {
		error "Please provide a genome size"
	}

        peaks_narrowpeak = peak_calling_atac(macs2g, final_bam_ch).narrowpeak
        peak_annotate(tagdir, peaks_narrowpeak, gtf_ch, fa_ch)
	
	emit:
	peak_ch = peaks_narrowpeak
}
