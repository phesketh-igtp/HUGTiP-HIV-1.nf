process getVersions {

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

    input:
        val(runID)

    output:
        path("run_params.csv"), emit: versions

    script:

        """
        # Create the analysis parameters file
            rm -f run_params
            echo "reporting_threshold,${params.reporting_threshold}" > run_params
            echo "consensus_pct,${params.consensus_pct}" >> run_params
            echo "length_cutoff,${params.length_cutoff}" >> run_params
            echo "score_cutoff,${params.score_cutoff}" >> run_params
            echo "min_variant_qual,${params.min_variant_qual}" >> run_params
            echo "min_dp,${params.min_dp}" >> run_params
            echo "min_ac,${params.min_ac}" >> run_params
            echo "min_freq,${params.min_freq}" >> run_params
            echo "min_read_qual,${params.min_read_qual}" >> run_params

        # Version controls
            rm -f versions
            quasitools --version | sed 's/ version /v/g' >> versions
            fastp -v | sed 's/fastp /fastp v/g' >> versions
            trim_galore -v | grep 'version' | sed 's/ //g; s/version/TrimGalore,v/g' >> versions
            seqkit -h | grep 'Version' | sed 's/Version: /seqkit,v/g' >> versions
            sierrapy --version | sed -e 's/;/ |/g' >> versions
            sed -i 's/SierraPy /HIVDB,SierraPy v/; s/Sierra /Sierra v/; s/HIVDB_/v/' versions

        # Rename as a csv file
            cat versions run_params > run_params.csv
        """

    }