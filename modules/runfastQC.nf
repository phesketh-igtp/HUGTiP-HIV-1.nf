process runfastQC {

        tag "${sampleID}"

        conda params.conda_main_envs

        publishDir "${params.outdir}/${runID}/fastQC/", mode: "copy"

        input:
                val(runID)
                tuple val(sampleID), 
                        path(forward), 
                        path(reverse)

        output:
        path("*.zip"),                          emit: fastqc_zips
        path("*.html"),                         emit: fastqc_htmls

        script:
                """
                mkdir ${sampleID}_fastqc

                fastqc --outdir ${sampleID}_fastqc \\
                        ${forward} ${reverse}
                
                mv ${sampleID}_fastqc/* .
        """
}