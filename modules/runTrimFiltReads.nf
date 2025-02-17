process runTrimFiltReads {

        tag "${sampleID}"

        conda params.conda_main_envs

        container { 
                if (workflow.containerEngine == 'docker') {
                        params.docker_main_img
                } else if (workflow.containerEngine == 'singularity' || workflow.containerEngine == 'apptainer') {
                        params.singularity_main_img
                } else { 
                        null 
                } 
                }

        publishDir "${params.outdir}/${runID}/", mode: "copy", overwrite: true,
                                        pattern: '.{out,csv,txt,tsv}'

        input:
                val(runID)
                tuple val(sampleID), 
                        path(forward), 
                        path(reverse),
                        val(type)

        output:
                tuple val(sampleID), 
                        path("${sampleID}.fastp.R1.fastq.gz"), 
                        path("${sampleID}.fastp.R2.fastq.gz"), emit: trimmed_reads_ch

        script:
                """
                fastp --detect_adapter_for_pe \\
                        -l ${params.length_cutoff} \\
                        -e ${params.min_read_qual} \\
                        -i ${forward} \\
                        -I ${reverse} \\
                        -o ${sampleID}.fastp.R1.fastq.gz \\
                        -O ${sampleID}.fastp.R2.fastq.gz
                """
}