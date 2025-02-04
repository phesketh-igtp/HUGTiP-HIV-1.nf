# HUGTiP HIV-1 Drug Resistance and Lineage Profiling

Active development!

## Introduction

This Nextflow Pipeline was build following similarly to [QuasiFlow](https://github.com/AlfredUg/QuasiFlow), and utilises [Quasitools HYDRA](https://phac-nml.github.io/quasitools/) for the generation of consensus HIV-1 sequences, and futher analysis of drug resistanc profiles using the [Sierra-local](https://github.com/hivdb/sierra-client/blob/master/python/README.md) through the python package [SierraPy](https://github.com/hivdb/sierra-client/blob/master/python/README.md). Please cite the relevant tools when utilising this workflow.

## Utilisation

This pipeline was built and tested using Nextflow v24.10.1.5930, it has been largely tested using conda as the package manager, but is supported with Docker and Singularity container images built using [Seqera contaier tool](https://seqera.io/containers/).

The first option is to install the pipeline using nextflow, it will be installed in the $HOME directory under the .nextflow sub-directory. Confirm that installation was successful by printing out the help message.
```{sh}
nextflow pull phesketh-igtp/HUGTiP-HIV-1.nf
nextflow run ~/.nextflow/assets/phesketh-igtp/HUGTiP-HIV-1.nf --help
```

## Citations



