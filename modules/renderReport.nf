process renderReport{

    tag "$sampleID"

    conda params.conda_R_envs

    publishDir "${params.outDir}", mode: 'move'
    
    input:
        tuple val(sampleID), 
                path(lengths_res),
                path(stats_res),
                path(hydra_res),
                path(coverage_res),
                path(hydra_vcf),
                path(runs_params)
                path(sierrapy_res)

    output:
        tuple val(sampleID), 
                path('hivdr_*.html'), 
                path('hivdr_*.pdf'),    emit: final_report_ch

    script:

        // path rmd from params.rmd
        // path rmd_static from params.rmd_static 

        """
        sed -i '1d' ${coverage_res} # remove the header for the coverage file
        cut -f2 ${lengths_res} > read_lenths.tsv
            
        quarto render --to html,pdf \
                "${params.scriptDir}/Quarto/final-report.qmd" \\
                --execute-params sampleID="${sampleID}" \\
                                lengths="read_lenths.tsv" \\
                                stats="${stats_res}" \\
                                sierrapy="${sierrapy_res}" \\
                                hydra="${hydra_res}" \\
                                hydra_vcf="${hydra_vcf}" \\
                                coverage="${coverage_res}"
                                run_params="${runs_params}"
        """
}