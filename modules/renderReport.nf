process renderReport{

    tag "${sampleID}"

    conda params.conda_R_envs

    publishDir "${params.outdir}/${runID}/final-report", mode: 'copy'
    
    input:
        val(runID)
        path(versions, stageAs: "run_params.csv")

        tuple val(sampleID), 
                path(lengths_res,   stageAs: "length-freq.tsv"),
                path(stats_res,     stageAs: "stats.tsv"),
                path(hydra_res,     stageAs: "hydra_report.csv"),
                path(coverage_res,  stageAs: "coverage_file.csv"),
                path(hydra_vcf,     stageAs: "hydra.vcf"),
                path(sierrapy_res,  stageAs: "sierrapy.hiv1.csv")

    output:
        tuple val(sampleID), 
                path('*.html'), 
                path('*.pdf'),    emit: final_report_ch

    script:

        """
        cat run_params.csv
        sed -i '1d' ${coverage_res} # remove the header for the coverage file
        cut -f2 ${lengths_res} > read_lenths.tsv

        cp "${params.scriptDir}/Quarto/final-report.qmd" final-report.qmd

            sed -i "s/insert_sampleID/${sampleID}" final-report.qmd

        quarto render final-report.qmd --to html,pdf --execute-params

        """
}

/*
sampleID="${sampleID}" \\
                                lengths="read_lenths.tsv" \\
                                stats="${stats_res}" \\
                                sierrapy="${sierrapy_res}" \\
                                hydra="${hydra_res}" \\
                                hydra_vcf="${hydra_vcf}" \\
                                coverage="${coverage_res}"
                                run_params="${runs_params}"
                                */