process runHydra{

    tag "${sampleID}"

    conda params.conda_main_envs
    
    publishDir "${params.outdir}/${runID}/hydra/", mode: 'copy'

    input:
        val(runID)
        tuple val(sampleID), 
                path(forward), 
                path(reverse)
    
    output:
        tuple val(sampleID), 
                path("${sampleID}.consensus.fasta"),  emit: cns_sequence
        path("${sampleID}.dr_report.csv"),            emit: drug_res
        path("${sampleID}.mutation_report.aavf.gz")

    script:
        """
        gunzip -c ${forward} > ${sampleID}_R1.fastq 
        gunzip -c ${reverse} > ${sampleID}_R2.fastq 

        # Run quasitools
            quasitools hydra \\
                ${sampleID}_R1.fastq \\
                ${sampleID}_R2.fastq \\
                -o . \\
                --generate_consensus \\
                --reporting_threshold ${params.reporting_threshold} \\
                --consensus_pct ${params.consensus_pct} \\
                --length_cutoff ${params.length_cutoff} \\
                --score_cutoff ${params.score_cutoff} \\
                --min_variant_qual ${params.min_variant_qual} \\
                --min_dp ${params.min_dp} \\
                --min_ac ${params.min_ac} \\
                --min_freq ${params.min_freq}
        
        # rename to ensure results are unqiue
            mv consensus.fasta ${sampleID}.consensus.fasta 
            mv dr_report.csv ${sampleID}.dr_report.csv
            mv mutation_report.aavf ${sampleID}.mutation_report.aavf
            mv filtered.fastq ${sampleID}.filtered.fastq
            gzip --best ${sampleID}.filtered.fastq
            gzip --best ${sampleID}.mutation_report.aavf
            rm ${sampleID}_R1.fastq ${sampleID}_R2.fastq 

        """
}