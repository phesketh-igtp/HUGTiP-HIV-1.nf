process runTrimGalore {

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
                path("${sampleID}_val_1.fq.gz"), 
                path("${sampleID}_val_2.fq.gz"), emit: trimmed_reads_ch

    script:
        """
        trim_galore -q ${params.min_read_qual} \\
                    --basename ${sampleID} \\
                    --paired ${forward} ${reverse} \\
                    -o .

        """
}