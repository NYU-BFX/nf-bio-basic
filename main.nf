params.reads = "$baseDir/data/ggal/gut_{1,2}.fq"
params.multiqc = "$baseDir/multiqc"
params.outdir = "output"

println """\
         ===================================
         reads        : ${params.reads}
         outdir       : ${params.outdir}
         """
         .stripIndent()


Channel.fromFilePairs( params.reads )
        .ifEmpty { error "Cannot find any reads matching: ${params.reads}"  }
        .into { read_pairs_ch; read_pairs2_ch }


process fastqc {
    tag "${sample_id}"

    input:
    set sample_id, file(reads) from read_pairs2_ch

    output:
    file("fastqc_${sample_id}_logs") into fastqc_ch


    script:
    """
    which conda
    which fastqc
    mkdir fastqc_${sample_id}_logs
    fastqc -o fastqc_${sample_id}_logs -f fastq -q ${reads}
    """
}


process multiqc {
    publishDir params.outdir, mode:'copy'

    input:
    file('*') from fastqc_ch.collect()

    output:
    file('multiqc_report.html')

    script:
    """
    multiqc .
    """
}


workflow.onComplete {
	println ( workflow.success ? "\nDone! Open the following report in your browser --> $params.outdir/multiqc_report.html\n" : "Oops .. something went wrong" )
}
