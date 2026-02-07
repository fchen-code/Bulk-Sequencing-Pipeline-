include {tag_dir} from "../modules/tag_dir.nf"

workflow TAGDIR{

	take:
        fa_ch
        final_bam_ch
    
	main:
        tagdir = tag_dir(fa_ch, final_bam_ch)
    
	emit:
        tag_dir_ch = tagdir
}
