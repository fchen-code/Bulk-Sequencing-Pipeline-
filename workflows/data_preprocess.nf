include {download_data} from "../modules/download_data.nf"
include {fastp_sra} from "../modules/fastp.nf"
include {fastp_local} from "../modules/fastp.nf"

workflow DATA_PREPROCESS {

        take:
        csv_file
	genomes
        
	main:
	data_channel = Channel.fromPath(csv_file)
			.splitCsv(header: true)
			.map{sample ->
				def meta = [id: sample?.ID, test: sample?.Test?.toLowerCase(), name: sample?.Name, strandedness: sample?.Strandedness?.toLowerCase()]
                                def pointer = [source: sample?.Source?.toLowerCase(), R1: sample?.R1, R2: sample?.R2]
                                tuple(meta, pointer)}
	branches = data_channel.branch{meta, pointer ->
			local: pointer.source == "local"
                        sra: pointer.source == "sra"}
                
	local_branch = branches.local
	sra_branch = branches.sra
	local = local_branch.map{meta, pointer ->
				def files = []
				if (pointer.R1) files << file(pointer.R1)
				if (pointer.R2) files << file(pointer.R2)
				tuple(meta, files)}
    
	srr_list = sra_branch.map{meta, pointer -> meta.id}.unique()

        sra_files = download_data(srr_list)
        
        sra_fastp = fastp_sra(sra_files)
        
        local_fastp = fastp_local(local)
        
        fastp_files = sra_fastp.mix(local_fastp)
        
        rows_by_srr = sra_branch
			.map { meta, pointer -> tuple(meta.id, meta) } 
			.groupTuple()
        
        final_fastp = rows_by_srr
			.join(fastp_files)
			.flatMap{srr, meta, files, html, json ->
			meta.collect{metas -> tuple(metas, files, html, json)}
			}
        

        reads = final_fastp.map { meta, files, html, json ->
			def layout = (files.size() == 2) ? 'PE' : 'SE'
			tuple(meta + [layout: layout, genome: genomes.toLowerCase()], files, html, json)
			}
        
        
        final_raw = rows_by_srr
			.join(sra_files)
			.flatMap{srr, meta, files ->
			meta.collect{metas -> tuple(metas, files)}
			}
        
        emit:
		trimmed_ch = reads
		raw_ch = final_raw
}
