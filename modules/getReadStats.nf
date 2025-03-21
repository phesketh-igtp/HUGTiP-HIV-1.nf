process getReadStats {

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

        
        publishDir "${params.outdir}/${runID}/readStats/", mode: "copy", overwrite: true

        input:
                val(runID)
                tuple val(sampleID), 
                        path(forward), 
                        path(reverse)

        output:
                tuple val(sampleID),
                        path("${sampleID}.length-freq.tsv"),
                        path("${sampleID}.stats.tsv"),          emit: report_ch

        script:
                """
                seqkit stats -bT ${forward} ${reverse}  > ${sampleID}.stats.tsv
                seqkit fx2tab -nl ${forward} ${reverse} > ${sampleID}.length-freq.tsv
                """
}