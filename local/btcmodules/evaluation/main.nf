process SCBTC_EVALUATION {
    /* Description */

    tag "Batch evaluation"
    label 'process_high'

    container "oandrefonseca/scrpackages:main"
    publishDir "${params.project_name}", mode: 'copyNoFollow'

    input:
        path(project_object)
        path(evaluation_script)
        val(input_batch_step)

    output:
        path("data/batch_method.selected.txt"), emit: best_method
        path("data/${params.project_name}_evaluation_table.RDS")
        path("${params.project_name}_evaluation_report.html")
        path("figures/evaluation")

    script:
        def n_memory = task.memory.toString().replaceAll(/[^0-9]/, '') as int
        """
        #!/usr/bin/env Rscript

        # Getting run work directory
        here <- getwd()

        # Rendering Rmarkdown script
        rmarkdown::render("${evaluation_script}",
            params = list(
                project_name = "${params.project_name}",
                project_object = "${project_object}",
                input_batch_step = "${input_batch_step}",
                input_target_variables = "${params.input_target_variables}",
                input_lisi_variables = "${params.input_lisi_variables}",
                input_auto_selection = "${params.input_auto_selection}",
                n_threads = ${task.cpus},
                n_memory = ${n_memory},
                workdir = here
            ), 
            output_dir = here,
            output_file = "${params.project_name}_evaluation_report.html")           

        """
    stub:
        """
        mkdir -p data figures/evaluation

        touch data/${params.project_name}_evaluation_table.RDS
        touch data/batch_method.selected.txt
        touch ${params.project_name}_evaluation_report.html

        touch figures/evaluation/EMPTY
        """
}
