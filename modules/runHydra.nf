process runHydra{

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
    
    publishDir "${params.outdir}/${runID}/hydra/", mode: 'copy', overwrite: true

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
                path("${sampleID}.hydra.coverage.tsv"),
                path("${sampleID}.hydra.vcf"),          emit: report_ch

    script:
        """
        # Quasitools wont work on compressed files so must be uncompressed
            gunzip -c ${forward} > ${sampleID}_R1.fastq 
            gunzip -c ${reverse} > ${sampleID}_R2.fastq

        seqkit seq \\
                --min-len ${params.length_cutoff} \\
                --min-qual ${params.min_read_qual} \\
                ${sampleID}_R1.fastq > ${sampleID}_R1.1.fastq

        seqkit seq \\
                --min-len ${params.length_cutoff} \\
                --min-qual ${params.min_read_qual} \\
                ${sampleID}_R2.fastq > ${sampleID}_R2.2.fastq
        rm ${sampleID}_R1.fastq ${sampleID}_R2.fastq

        # Run quasitools
            quasitools hydra \\
                ${sampleID}_R1.1.fastq \\
                ${sampleID}_R2.1.fastq \\
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

        # rename to ensure results are unqiue
            mv consensus.fasta      ${sampleID}.consensus.fasta 
            mv dr_report.csv        ${sampleID}.dr_report.csv
            mv mutation_report.aavf ${sampleID}.mutation_report.aavf
            mv filtered.fastq       ${sampleID}.filtered.fastq
            mv coverage_file.csv    ${sampleID}.coverage_file.csv
            mv hydra.vcf            ${sampleID}.hydra.vcf
            rm ${sampleID}_R1.fastq ${sampleID}_R2.fastq

            samtools depth align.bam > ${sampleID}.hydra.coverage.tsv

        # replace hxb2_pol with sampleID in dr_report.csv
            sed -i 's/hxb2_pol/${sampleID}/g' ${sampleID}.dr_report.csv
        """
}