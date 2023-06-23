process SCBTC_EVALUATION {
    tag "Batch evaluation"
    label 'process_high'

    container "oandrefonseca/scpackages:1.0"

    input:
        path(project_object)
        path(evaluation_script)
        val(input_batch_step)

    output:
        path("${params.project_name}_${input_batch_step}_evaluation_object.RDS"), emit: project_rds
        path("${params.project_name}_${input_batch_step}_evaluation_report.html")
        path("figures/evaluation/*")
        path("data")

    script:
        """
        #!/usr/bin/env Rscript

        # Getting run work directory
        here <- getwd()

        # Rendering Rmarkdown script
        rmarkdown::render("${evaluation_script}",
            params = list(
                project_name = "${params.project_name}",
                project_object = "${project_object}",
                input_batch_step = "${input_batch_step}"
                input_target_variables = "${params.input_target_variables}",
                input_lisi_variables = "${params.input_lisi_variables}",
                input_auto_selection = "${params.input_auto_selection}",
                n_threads = "${task.cpu}",
                n_memory = "${task.memory}",
                workdir = here
            ), 
            output_dir = here,
            output_file = "${params.project_name}_${input_batch_step}_evaluation_report.html")           

        """
    stub:
        """
        touch ${params.project_name}_${input_batch_step}_evaluation_report.html
        touch ${params.project_name}_${input_batch_step}_evaluation_object.RDS

        mkdir -p data figures/evaluation
        touch figures/evaluation/EMPTY
        """
}
