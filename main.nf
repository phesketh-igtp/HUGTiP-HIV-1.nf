#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

    /*
    ========================================================================================
                            Q U A S I F L O W  P I P E L I N E
    ========================================================================================
                
                A Nextflow pipeline for analysis of NGS-based HIV Drug resitance data

    ----------------------------------------------------------------------------------------
    */

    /*
        IMPORT MODULES
    */
    include { runTrimGalore }   from './modules/runTrimGalore.nf'
    include { runfastQC }       from './modules/runfastQC.nf'
    include { getReadStats }    from './modules/getReadStats.nf'
    include { runMultiQC }      from './modules/runMultiQC.nf'
    include { runHydra }        from './modules/runHydra.nf'
    include { runSierralocal }  from './modules/runSierralocal.nf'
    //include { renderReport }    from './modules/renderReport.nf'

    /*
    ······································································································
        REQUIRED ARGUMENTS
    ······································································································
    */

    def helpMessage() {
        log.info"""
        ============================================================
        AlfredUg/QuasiFlow  ~  version ${params.version}
        ============================================================
        Usage:
        The typical command for running the pipeline is as follows:
        nextflow run AlfredUg/QuasiFlow --reads <path to fastq files> --outdir <path to output directory>
        
        Mandatory arguments:
            --name                          Name of the run.
            --samplesheet                   Path to input data samplesheet (must be a csv with 4 columns: sampleID,alias,forward_path,reverse_path)

        HyDRA arguments (optional):
            --mutation_db		            Path to mutational database.
            --reporting_threshold	        Minimum mutation frequency percent to report.
            --consensus_pct		            Minimum percentage a base needs to be incorporated into the consensus sequence.
            --min_read_qual	                Minimum quality for a position in a read to be masked.	     
            --length_cutoff	                Reads which fall short of the specified length will be filtered out.
            --score_cutoff		            Reads that have a median or mean quality score (depending on the score type specified) less than the score cutoff value will be filtered out.
            --min_variant_qual              Minimum quality for variant to be considered later on in the pipeline.
            --min_dp                        Minimum required read depth for variant to be considered later on in the pipeline.
            --min_ac                        The minimum required allele count for variant to be considered later on in the pipeline
            --min_freq                      The minimum required frequency for mutation to be considered in drug resistance report.

        Sierralocal arguments (optional):
            --xml                           Path to HIVdb ASI2 XML.
            --apobec-tsv                    Path to tab-delimited (tsv) HIVdb APOBEC DRM file.
            --comments-tsv                  Path to tab-delimited (tsv) HIVdb comments file.
        


        """.stripIndent()
    }

    /*
    ······································································································
        WORKFLOW: main
    ······································································································
    */

    workflow {

        // Create channel from sample sheet
            if (params.samplesheet == null) {
                error "Please provide a samplesheet CSV file with --samplesheet (csv)"
            }

        // Create channel from sample sheet
            if (params.runID == null) {
                error "Please provide a runID file with --runID (chr)"
            }

            if (params.outdir == null) {
                error "Please provide a runID file with --name (chr)"
            }

                if (params.workDir == null) {
                error "Please provide a runID file with --name (chr)"
            }

        

    /*
    ······································································································
        CREATION OF CHANNELS
            The section creates the samples_ch and the controls_ch from the samplesheet. First the 
                sample sheet is imported and split by the 'type' column into sample or control, and these
                two sets of samples are directed into seperate workflows.
    ······································································································
    */

    Channel.fromPath(params.samplesheet)
                    .splitCsv(header: true, sep: ',')
                    .map { row ->
                        def requiredColumns = ['sampleID', 'forward', 'reverse', 'type']
                        def missingColumns = requiredColumns.findAll { !row.containsKey(it) }
                        if (missingColumns) {
                            error "Missing required column(s) in samplesheet: ${missingColumns.join(', ')}"
                        }
                        tuple(row.sampleID.trim(), 
                            file(row.forward.trim(), checkIfExists: true), 
                            file(row.reverse.trim(), checkIfExists: true), 
                            row.type.trim()
                        )
                    }
                    .branch {
                        sample: it[3] == 'sample'
                        control: it[3] == 'control'
                    }
                    .set { branched_samples_by_type }

        samples_ch   = branched_samples_by_type.sample
        controls_ch  = branched_samples_by_type.control

    /*
    ······································································································
        MAIN WORKFLOW
    ······································································································
    */

        // Run TimGalore on the reads
            runTrimGalore( params.runID, samples_ch )

        // Run FastQC
            runfastQC( params.runID, runTrimGalore.out.trimmed_reads_ch )

                // Collect all the samples for running MultiQC
                    multiqc_zips = runfastQC.out.fastqc_zips.collect()
                    multiqc_htmls = runfastQC.out.fastqc_htmls.collect()

            getReadStats( params.runID,runTrimGalore.out.trimmed_reads_ch )

        // Run MultiQC
            runMultiQC( params.runID, multiqc_zips, multiqc_htmls )

        // Run Hydra on the reads
        runHydra( params.runID, runTrimGalore.out.trimmed_reads_ch )

        // Run SierraLocal on the reads
        runSierralocal( params.runID, runHydra.out.cns_sequence )
        
        // Render the HTML output
        //renderReport( params.runID, runSierralocal.out.cns_json_ch )

    }