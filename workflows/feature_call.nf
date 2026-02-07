include {feature_count} from "../modules/feature_count.nf"

workflow FEATURECALL {

	take:
        meta
        gtf_ch
        bam_ch
    
	main:
        txt = feature_count(gtf_ch, bam_ch)
        merge = txt.result.map{count, summary -> count}.flatten().collect()        
        summary = txt.result
    
	emit:
        txt_ch = summary        
}
