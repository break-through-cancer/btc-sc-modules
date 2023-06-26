process SCBTC_QCRENDER {
    /* Description */

    tag "Rendering QC Table"
    label 'process_single'

    container 'oandrefonseca/scpackages:1.0'
    publishDir "${params.project_name}", mode: 'copyNoFollow'

    input:
        path(project_metrics)
        path(qc_table_script)

    output:
        path("${params.project_name}_project_metric_report.html")
    
    script:
        def n_memory = task.memory.toString().replaceAll(/[^0-9]/, '') as int
        """
        #!/usr/bin/env Rscript

        # Getting run work directory
        here <- getwd()

        # Rendering Rmarkdown script
        rmarkdown::render("${qc_table_script}",
            params = list(
                project_name = "${params.project_name}",
                input_metrics_report = "${project_metrics.join(';')}",
                n_threads: "${task.cpu}",
                n_memory: "${n_memory}",
                workdir = here
            ), 
            output_dir = here,
            output_file = "${params.project_name}_project_metric_report.html")
        """
    stub:
        """
        touch ${params.project_name}_project_metric_report.html
        """

}