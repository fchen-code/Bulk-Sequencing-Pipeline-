include {fastqc_raw} from "../modules/fastqc.nf"
include {fastqc_trimmed} from "../modules/fastqc.nf"

workflow FASTQC {

	take:
	raw
	trimmed

	main:
	fastqc_raw = fastqc_raw(raw)
	fastqc_trimmed = fastqc_trimmed(trimmed)

	emit:
	raw_ch = fastqc_raw
	trimmed_ch = fastqc_trimmed


}
