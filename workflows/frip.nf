include {frip} from "../modules/frip.nf"

workflow FRIP {

	take:
	frip_input

	main:
	frip_result = frip(frip_input)
	
	emit:
	frip_ch = frip_result	
}
