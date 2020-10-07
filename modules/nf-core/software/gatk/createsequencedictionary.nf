include { initOptions; saveFiles; getSoftwareName } from './../functions'

process GATK_CREATESEQUENCEDICTIONARY {
    tag "${fasta}"

    publishDir params.outdir, mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:options, publish_dir:getSoftwareName(task.process), publish_id:'') }

    container "quay.io/biocontainers/gatk4-spark:4.1.8.1--0"

    conda (params.conda ? "bioconda::gatk4-spark=4.1.8.1" : null)

    input:
        path fasta
        val options

    output:
        path "${fasta.baseName}.dict"

    script:
    def software = getSoftwareName(task.process)
    def ioptions = initOptions(options)
    """
    gatk --java-options "-Xmx${task.memory.toGiga()}g" \
        CreateSequenceDictionary \
        --REFERENCE ${fasta} \
        --OUTPUT ${fasta.baseName}.dict

    echo \$(gatk CreateSequenceDictionary --version 2>&1) | sed 's/^.*The Genome Analysis Toolkit (GATK) v//; s/ HTSJDK.*\$//' > ${software}.version.txt
    """
}