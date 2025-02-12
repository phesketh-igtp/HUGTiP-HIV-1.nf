process runSierralocal {

    tag "$sampleID"

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

    publishDir "${params.outdir}/${runID}/sierra", mode: 'copy', overwrite: true

    input:
        val(runID)
        tuple val(sampleID), 
                path(cns_seq)

    output:
        tuple val(sampleID), 
                path("${sampleID}.*.csv"), emit: report_ch, optional: true

    script:

        """
        sierrapy --virus HIV1 fasta ${cns_seq} \\
                    -o ${sampleID}.sierrapy.hiv1.json
        
        python3 ${params.scriptDir}/py/json2csv.py \\
                    ${sampleID}.sierrapy.hiv1*json \\
                    ${sampleID}.sierrapy.hiv1.csv

        touch ${sampleID}.sierrapy.hiv1.csv
        """
}