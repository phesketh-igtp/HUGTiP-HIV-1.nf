process runMultiQC{

        publishDir "${params.outdir}/${runID}/multiQC/", mode: "copy", overwrite: true

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
                path(multiqc_zips)
                path(multiqc_htmls)

        output:
                path('raw_reads_multiqc_report.html')

        script:
        """
        multiqc .
        mv multiqc_report.html raw_reads_multiqc_report.html
        """
}
