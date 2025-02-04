# HUGTiP HIV-1 Drug Resistance and Lineage Profiling

Active development!

## Introduction

This Nextflow Pipeline was build following similarly to [QuasiFlow](https://github.com/AlfredUg/QuasiFlow), and utilises [Quasitools HYDRA](https://phac-nml.github.io/quasitools/) for the generation of consensus HIV-1 sequences, and futher analysis of drug resistanc profiles using the [Sierra-local](https://github.com/hivdb/sierra-client/blob/master/python/README.md) through the python package [SierraPy](https://github.com/hivdb/sierra-client/blob/master/python/README.md). Please cite the relevant tools when utilising this workflow.

## Instilation and Test

This pipeline was built and tested using Nextflow v24.10.1.5930, it has been largely tested using conda as the package manager, but is supported with Docker and Singularity container images built using [Seqera container webtool](https://seqera.io/containers/).

The first option is to install the pipeline using nextflow, it will be installed in the $HOME directory under the .nextflow sub-directory. Confirm that installation was successful by printing out the help message.

```{sh}
nextflow pull phesketh-igtp/HUGTiP-HIV-1.nf
nextflow run ~/.nextflow/assets/phesketh-igtp/HUGTiP-HIV-1.nf --help
```

Alternatively, the github repository can be cloned.

```{sh}
gh repo clone phesketh-igtp/HUGTiP-HIV-1.nf
nextflow run ./phesketh-igtp/HUGTiP-HIV-1.nf/main.nf --help
```

With the repository available locally, you can proceed with performing the test to ensure that everything works on your system.
```{sh}
nextflow run ./phesketh-igtp/HUGTiP-HIV-1.nf/main.nf --samplesheet test/samplesheet --outdir init-test -p conda_on #OR: docker_on, singularity_on, aptainer_on
```

You can compare the outputs from the test with the expected results in the rest directory (e.g. <code>test/sample-1.hiv1-dr.results.html</code>).

## Usage

To run the pipeline you require a csv file that contains 4 columns, consult the </code>example test/samplesheet.csv</code>: 
1. sampleID - name of the sample
2. forward - full path to forward reads
3. reverse - full path to reverse reads
4. type - either 'sample' or 'control'

| sampleID | forward | reverse | type |
| -------- | -------- | -------- | -------- |
| sample-1 | ../test/sample1_R1.fastq.gz | ../test/sample1_R2.fastq.gz | sample |
| sample-8 | ../test/sample8_R1.fastq.gz | ../test/sample8_R2.fastq.gz | control |


## Citations

