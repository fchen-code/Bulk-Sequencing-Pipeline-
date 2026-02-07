include {dup_removal} from "../modules/dup_removal.nf"
include {filter} from "../modules/filter.nf"
include {blacklist_removal_auto} from "../modules/blacklist_removal.nf"
include {blacklist_removal_manually} from "../modules/blacklist_removal.nf"
include {sort} from "../modules/sort.nf"
include {bam_index} from "../modules/bam_index.nf"


workflow QUALITY_FILTER {
	
	take:
        bam_ch
        genome
        blacklist_path
	blacklist

	main:
        dup_removed = dup_removal(bam_ch)
        dup_removed_bam = dup_removed.bam
        filtered_bam = filter(dup_removed_bam)
	if (blacklist){
		if (blacklist_path) {
			blacklist_bam = blacklist_removal_manually(blacklist_path, filtered_bam)
                        final_bam = blacklist_bam
                } else if (genome == "hg38" || genome == "hg19" || genome == "mm10") {
                        blacklist_bam = blacklist_removal_auto(filtered_bam)
                        final_bam = blacklist_bam
                } else {
                        error "No blacklist found, please use --blacklist to provide file"
                }
        } else {
		final_bam = filtered_bam
	}
	
        final_sorted_bam = sort(final_bam)
        final_bai = bam_index(final_sorted_bam)
        
	emit:
	final_bam_ch = final_sorted_bam
        final_bam_bai_ch = final_bai.bam_bai
        dup_removed_txt = dup_removed.txt
}

