process renderReport{

    tag "${sampleID}"

    conda params.conda_R_envs

    publishDir "${params.outdir}/${runID}/final-report", mode: 'copy', overwrite: true
    
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
        # Modify the results for rendering
            sed -i '1d' ${coverage_res} # remove the header for the coverage file
            cut -f2 ${lengths_res} > read_lenths.tsv

        # Copy over and edit the Rmd file
            cp ${params.scriptDir}/Rmd/final-report.Rmd .
                sed -i "s/insert_sampleID/${sampleID}/" final-report.Rmd
        
        # Copy over the ref data
            cp ${params.dbDir}/quasitools_assets/quasitools-mutation_db.tsv .
            cp ${params.dbDir}/HIVDB/drug.groups.csv .

        # Render report
            Rscript -e "rmarkdown::render('final-report.Rmd', output_format = 'html_document')"
            #Rscript -e "rmarkdown::render('final-report.Rmd', output_format = 'pdf_document')"

        # Rename the outputs
            mv final-report.html ${sampleID}.report.html
            #mv final-report.pdf ${sampleID}.report.pdf

        # Remove temporary files
            rm final-report.Rmd quasitools-mutation_db.tsv drug.groups.csv
            
        """
}