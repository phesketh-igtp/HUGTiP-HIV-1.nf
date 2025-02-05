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
                path("${sampleID}.consensus.fasta"),    emit: cns_sequence

        tuple val(sampleID),
                path("${sampleID}.dr_report.csv"),
                path("${sampleID}.coverage_file.csv"),
                path("${sampleID}.hydra.vcf")
                path("run_params"),                     emit: report_ch

    script:
        """
        # Quasitools wont work on compressed files so must be uncompressed
            gunzip -c ${forward} > ${sampleID}_R1.fastq 
            gunzip -c ${reverse} > ${sampleID}_R2.fastq 

        # Run quasitools
            quasitools hydra \\
                ${sampleID}_R1.fastq \\
                ${sampleID}_R2.fastq \\
                -o . \\
                --generate_consensus \\
                --reporting_threshold   ${params.reporting_threshold} \\
                --consensus_pct         ${params.consensus_pct} \\
                --length_cutoff         ${params.length_cutoff} \\
                --score_cutoff          ${params.score_cutoff} \\
                --min_variant_qual      ${params.min_variant_qual} \\
                --min_dp                ${params.min_dp} \\
                --min_ac                ${params.min_ac} \\
                --min_freq              ${params.min_freq} \\
                --min_read_qual         ${params.min_read_qual}

        # Create the analysis parameters file
            echo "reporting_threshold,${params.reporting_threshold}" > run_params
            echo "consensus_pct,${params.consensus_pct}" >> run_params
            echo "length_cutoff,${params.length_cutoff}" >> run_params
            echo "score_cutoff,${params.score_cutoff}" >> run_params
            echo "min_variant_qual,${params.min_variant_qual}" >> run_params
            echo "min_dp,${params.min_dp}" >> run_params
            echo "min_ac,${params.min_ac}" >> run_params
            echo "min_freq,${params.min_freq}" >> run_params
            echo "min_read_qual,${params.min_read_qual}" >> run_params
        
        # rename to ensure results are unqiue
            mv consensus.fasta      ${sampleID}.consensus.fasta 
            mv dr_report.csv        ${sampleID}.dr_report.csv
            mv mutation_report.aavf ${sampleID}.mutation_report.aavf
            mv filtered.fastq       ${sampleID}.filtered.fastq
            mv coverage_file.csv    ${sampleID}.coverage_file.csv
            mv hydra.vcf            ${sampleID}.hydra.vcf
            rm ${sampleID}_R1.fastq ${sampleID}_R2.fastq
        """
}