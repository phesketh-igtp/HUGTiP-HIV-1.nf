process runfastQC {

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

        input:
                val(runID)
                tuple val(sampleID), 
                        path(forward), 
                        path(reverse)

        output:
                path("*.zip"),          emit: fastqc_zips
                path("*.html"),         emit: fastqc_htmls

        script:
                """
                mkdir ${sampleID}_fastqc

                fastqc --outdir ${sampleID}_fastqc \\
                        ${forward} ${reverse}
                
                mv ${sampleID}_fastqc/* .
                """
}