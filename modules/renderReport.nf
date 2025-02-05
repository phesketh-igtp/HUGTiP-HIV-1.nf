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
        path("${sampleID}.report.html")

    script:

        """
        sed -i '1d' ${coverage_res} # remove the header for the coverage file
        cut -f2 ${lengths_res} > read_lenths.tsv

        cp ${params.scriptDir}/Quarto/final-report.qmd .
            sed -i "s/insert_sampleID/${sampleID}/" final-report.qmd
        
        #cp ${params.scriptDir}/Quarto/final-report-pdf.qmd .
        #    sed -i "s/insert_sampleID/${sampleID}/g" final-report-pdf.qmd

        cp ${params.dbDir}/quasitools_assets/quasitools-mutation_db.tsv .
        cp ${params.dbDir}/HIVDB/drug.groups.csv .

        quarto render final-report.qmd --to html --execute-params
        #quarto render final-report-pdf.qmd --to pdf --execute-params

        mv final-report.html ${sampleID}.report.html
        #mv final-report-pdf.pdf ${sampleID}.report.pdf
        """
}