process getReadStats {

        tag "${sampleID}"

        conda params.conda_main_envs

        publishDir "${params.outdir}/${runID}/fastQC/", mode: "copy"

        input:
                val(runID)
                tuple val(sampleID), 
                        path(forward), 
                        path(reverse)

        output:
        path("${sampleID}.length-freq.tsv"),    emit: length_freq
        path("${sampleID}.stats.tsv"),          emit: stats_seq

        script:
                """
            seqkit stats -bT ${forward} ${reverse}  > ${sampleID}.stats.tsv
            seqkit watch -y ${forward} ${reverse}   > ${sampleID}.length-freq.tsv
            """
}