process runJoinStats {

    tag "$runID"

    publishDir "${params.outdir}/${runID}/", mode: 'copy', overwrite: true

    input:
        val(runID)

        tuple path(stats),
            path(len_freq)

    output:
        path("${runID}_read-stats.tsv")
        path("${runID}_read_lengths.tsv")

    script:
        """
        cat *.stats.tsv > ${runID}_read-stats.tsv
        cat *.length-freq.tsv > ${runID}_read_lengths.tsv
        """

}