include {multiqc_read} from "../modules/multiqc.nf"
include {multiqc_alignment} from "../modules/multiqc.nf"

workflow MULTIQC {

	take:
	test
        multiqc_input_read
        multiqc_input_alignment

        main:
        multiqc_read(test, multiqc_input_read)
        multiqc_alignment(test, multiqc_input_alignment)
}
