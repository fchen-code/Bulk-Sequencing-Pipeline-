include {download_genome_gtf} from "../modules/download_genome.nf"
include {download_genome_fa} from "../modules/download_genome.nf"
include {download_genome_gff3} from "../modules/download_genome.nf"
include {gff3_convert} from "../modules/gff3_convert.nf"
include {unzip_gtf} from "../modules/genome_unzip.nf"
include {unzip_fa} from "../modules/genome_unzip.nf"
include {unzip_gff3} from "../modules/genome_unzip.nf"

workflow GENOME_OBTAIN {

	take:
        meta
        genome
        genomes
        fa
        gff3
        gtf
        is_url
    
	main:
        def genome_id = genome.toLowerCase()
	def has_gff3 = false
        
	if (gtf && gff3) {
		error "Please only provide either gtf or gff3 file"
        } else if ((gtf && !fa) || (gff3 && !fa)) {
		error "Please provide a valid fasta file"
        } else if (fa && !(gtf || gff3)) {
		error "Please provde valid gtf or gff3 file"
	} else if (gtf && fa) {
		if (gtf.startsWith("http://") ||
		gtf.startsWith("https://") ||
		gtf.startsWith("ftp://") ||
		is_url) {
			gtfs = download_genome_gtf(meta, gtf)
		} else {
			gtfs  = Channel.value(tuple(meta, file(gtf)))
		}
		if (fa.startsWith("http://") ||
		fa.startsWith("https://") ||
		fa.startsWith("ftp://") ||
		is_url) {
			fas = download_genome_fa(meta, fa)
		} else {
			fas = Channel.value(tuple(meta, file(fa)))
		}
        } else if (gff3 && fa) {
		has_gff3 = true
		if (gff3.startsWith("http://") ||
		gff3.startsWith("https://") ||
		gff3.startsWith("ftp://") ||
		is_url) {
			gff3s = download_genome_gff3(meta, gff3)
		} else {
			gff3s = Channel.value(tuple(meta, file(gff3)))
		}
		if (fa.startsWith("http://") ||
		fa.startsWith("https://") ||
		fa.startsWith("ftp://") ||
		is_url) {
			fas = download_genome_fa(meta, fa)
		} else {
			fas = Channel.value(tuple(meta, file(fa)))
		}
        } else if (gtf || gff3 || fa) {
		error "Please provide both fa and gtf or gff3 files"
        } else if (genomes.containsKey(genome_id)) {
		fas = download_genome_fa(meta, genomes[genome_id].fa_url)
		def gtf_url  = genomes[genome_id].get('gtf_url',  null)
		def gff3_url = genomes[genome_id].get('gff3_url', null)

		if (gtf_url) {
			gtfs  = download_genome_gtf(meta, gtf_url)
			gff3s = Channel.empty()
		} else if (gff3_url) {
			has_gff3 = true
			gff3s = download_genome_gff3(meta, gff3_url)
			gtfs  = Channel.empty()
		} else {
			gtfs  = Channel.empty()
			gff3s = Channel.empty()
		}
	} else {
		error "Please provide a valid genome code or both gene annotation and reference files"
	}
        
	if (has_gff3) {
		unzipped_fa = unzip_fa(fas)
		unzipped_gff3 = unzip_gff3(gff3s)
		gff3_convert = unzipped_fa.combine(unzipped_gff3)
		.map{meta1, fa, meta2, gff3 -> tuple(meta1, fa, gff3)}
		gff3_convert.view()
		gtfs = gff3_convert(gff3_convert)  
		unzipped_gtf = unzip_gtf(gtfs)         
        } else {
		unzipped_gtf = unzip_gtf(gtfs)
		unzipped_fa  = unzip_fa(fas)
        }
                genome = unzipped_gtf.combine(unzipped_fa).map{meta1, gtf, meta2, fa -> tuple(meta1, gtf, fa)}
    
	emit:
	gtf_ch = unzipped_gtf
        fa_ch = unzipped_fa
        genomes_ch = genome
}
