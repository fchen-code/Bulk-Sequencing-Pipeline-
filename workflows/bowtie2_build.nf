include {bowtie2_build} from "../modules/bowtie2_build.nf"

workflow BOWTIE2_BUILD{

        take:
        fa_ch

        main:
        bt2 = bowtie2_build(meta, fa_ch)

        emit:
        bt2_ch = bt2
}
