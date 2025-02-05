process getVersions {

    conda params.conda_main_envs

    input:
        val(runID)

    output:
        path("run_params.csv"), emit: versions

    script:

        """
        # Create the analysis parameters file
            echo "reporting_threshold,1" > run_params
            echo "consensus_pct,20" >> run_params
            echo "length_cutoff,50" >> run_params
            echo "score_cutoff,30" >> run_params
            echo "min_variant_qual,30" >> run_params
            echo "min_dp,100" >> run_params
            echo "min_ac,5" >> run_params
            echo "min_freq,0.2" >> run_params
            echo "min_read_qual,30" >> run_params

        # Version controls
            quasitools --version | sed 's/ version /v/g' >> run_params
            trim_galore -v | grep 'version' | sed 's/ //g; s/version/TrimGalore,v/g' >> run_params
            seqkit -h | grep 'Version' | sed 's/Version: /seqkit,v/g' >> run_params
            sierrapy --version | sed -e 's/; /\n/g' >> run_params
            sed 's/SierraPy /SierraPy,v/g' run_params | sed 's/Sierra /Sierra,v/g' | sed 's/HIVdb /HIVdb,/g' >> run_params

            mv run_params run_params.csv
        """

    }