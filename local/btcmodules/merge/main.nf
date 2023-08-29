process SCBTC_MERGE {
    tag "Merging post-qc samples"
    label 'process_high'

    container "oandrefonseca/scrpackages:main"
    publishDir "${params.outdir}/${params.project_name}", mode: 'copy'

    input:
        path(ch_qc_approved)
        path(merge_script)

    output:
        path("data/${params.project_name}_merged_object.RDS"), emit: project_rds
        path("${params.project_name}_merged_report.html")
        path("figures/merge/*")

    script:
        def n_memory = task.memory.toString().replaceAll(/[^0-9]/, '') as int

        """
        #!/usr/bin/env Rscript

        # Getting run work directory
        here <- getwd()

        # Rendering Rmarkdown script
        rmarkdown::render("${merge_script}",
            params = list(
                project_name = "${params.project_name}",
                input_qc_approved = "${ch_qc_approved.join(';')}",
                n_threads = ${task.cpus},
                n_memory = ${n_memory},
                workdir = here
            ), 
            output_dir = here,
            output_file = "${params.project_name}_merged_report.html")
        """
    stub:
        """
        mkdir -p data figures/merge

        touch data/${params.project_name}_merged_object.RDS
        touch ${params.project_name}_merged_report.html

        touch figures/merge/EMPTY.pdf

        """
}
