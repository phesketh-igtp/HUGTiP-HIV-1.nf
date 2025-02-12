#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

    /*
    ========================================================================================
                            H U G T i P - H I V - 1 . n f
    ========================================================================================
                
                A Nextflow pipeline for analysis of NGS-based HIV Drug resitance data
                based on the QuasiFlow workflow

    ----------------------------------------------------------------------------------------
    */

    /*
        IMPORT MODULES
    */
    include { runTrimGalore  }  from './modules/runTrimGalore.nf'
    include { runfastQC      }  from './modules/runfastQC.nf'
    include { getReadStats   }  from './modules/getReadStats.nf'
    include { runMultiQC     }  from './modules/runMultiQC.nf'
    include { runHydra       }  from './modules/runHydra.nf'
    include { runSierralocal }  from './modules/runSierralocal.nf'
    include { renderReport   }  from './modules/renderReport.nf'
    include { getVersions    }  from './modules/getVersions.nf'

    /*
    ······································································································
        REQUIRED ARGUMENTS
    ······································································································
    */

    def helpMessage() {
        log.info"""
        ============================================================
        HUGTiP-HIV-1.nf  ~  version ${params.version}
        ============================================================
        Usage:

        The typical command for running the pipeline is as follows:

            nextflow run HUGTiP-HIV-1.nf/main.nf --samplesheet <samplesheet> --runID <name of run>
        
        Mandatory arguments:
            --name                  [chr]   Name of the run.
            --samplesheet           [chr]   Path to input data samplesheet (must be a csv with 4 columns: sampleID,forward,reverse,type)
                                                sampleID        - name of sample
                                                forward/reverse - complete paths to the read files
                                                type            - sample or control.

        HyDRA arguments (optional):
            --mutation_db		    [chr]   Path to mutational database.
            --reporting_threshold	[num]   Minimum mutation frequency percent to report (default: 1).
            --consensus_pct		    [num]   Minimum percentage a base needs to be incorporated into the consensus sequence (default: 20).
            --min_read_qual	        [num]   Minimum quality for a position in a read to be masked (default: 30).
            --length_cutoff	        [num]   Reads which fall short of the specified length will be filtered out (default: 50).
            --score_cutoff		    [num]   Reads that have a median or mean quality score (depending on the score type specified) less than the score cutoff value will be filtered out (default: 30).
            --min_variant_qual      [num]   Minimum quality for variant to be considered later on in the pipeline (default: 30).
            --min_dp                [num]   Minimum required read depth for variant to be considered later on in the pipeline (default: 100).
            --min_ac                [num]   The minimum required allele count for variant to be considered later on in the pipeline (default: 5).
            --min_freq              [num]   The minimum required frequency for mutation to be considered in drug resistance report (default: 0.2).

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

        def color_purple = '\u001B[35m'
        def color_green  = '\u001B[32m'
        def color_red    = '\u001B[31m'
        def color_reset  = '\u001B[0m'
        def color_cyan   = '\u001B[36m'

    

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
        // Produce version control files
            getVersions( params.runID )

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
        
        // Merge the channels for the final_report_ch
        //runHydra.out.report_ch.view()
        //runSierralocal.out.report_ch.view()
            merged_reports_ch = getReadStats.out.report_ch
                                    .join(runHydra.out.report_ch)
                                    .join(runSierralocal.out.report_ch)

        // Render the HTML output
            renderReport( params.runID, 
                            getVersions.out.versions,
                            merged_reports_ch )

    }
