process runSierralocal {

    tag "$sampleID"

    conda params.conda_main_envs

    publishDir "${params.outdir}/${runID}/sierra", mode: 'copy', overwrite: true

    input:
        val(runID)
        tuple val(sampleID), 
                path(cns_seq)

    output:
        tuple val(sampleID), 
                path("${sampleID}.*.csv"), emit: report_ch

    script:

        """
        sierrapy --virus HIV1 fasta ${cns_seq} \\
                    -o ${sampleID}.sierrapy.hiv1.json
        
        python3 ${params.scriptDir}/py/json2csv.py \\
                    ${sampleID}.sierrapy.hiv1*json \\
                    ${sampleID}.sierrapy.hiv1.csv
        """
}