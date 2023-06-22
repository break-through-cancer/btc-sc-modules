process SCBTAC_INTEGRATION {
    tag "Batch correction"
    label 'process_high'

    container "oandrefonseca/scpackages:1.0"

    input:
        path(project_object)
        path(batch_script)
        val(input_target_variables)
        val(input_step_name)

    output:
        path("${params.project_name}_batch_object.RDS"), emit: project_rds
        path("${params.project_name}_batch_report.html")
        path("figures/correction/*")
        path("data")

    script:
        // I NEED A DEF HERE
        """
        #!/usr/bin/env Rscript

        # Getting run work directory
        here <- getwd()

        # Rendering Rmarkdown script
        rmarkdown::render("${batch_script}",
            params = list(
                project_name = "${params.project_name}",
                project_object = "${project_object}",
                input_target_variables = "${params.input_target_variables}",
                input_integration_method = "${params.input_integration_method}",
                input_step_name = ${input_step_name},
                n_threads = "${task.cpu}",
                n_memory = "${task.memory}",
                workdir = here,
            ), 
            output_dir = here,
            output_file = "${params.project_name}_${input_step_name}_batch_report.html")           

        """
    stub:
        """
        touch ${params.project_name}_${input_step_name}_batch_report.html
        touch ${params.project_name}_${input_step_name}_batch_object.RDS

        mkdir -p data figures/correction
        touch figures/correction/EMPTY
        """
}
