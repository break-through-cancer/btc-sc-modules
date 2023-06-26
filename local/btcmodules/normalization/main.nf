process SCBTC_NORMALIZATION {
    tag "Running normalization"
    label 'process_high'

    container "oandrefonseca/scpackages:1.0"
    publishDir "${params.project_name}", mode: 'copyNoFollow'

    input:
        path(project_object)
        path(normalization_script)
        val(input_step_name)

    output:
        path("data/${params.project_name}_${input_step_name}_normalize_object.RDS"), emit: project_rds
        path("${params.project_name}_${input_step_name}_normalize_report.html")
        path("figures/reduction")

    script:
        def n_memory = task.memory.toString().replaceAll(/[^0-9]/, '') as int
        """
        #!/usr/bin/env Rscript

        # Getting run work directory
        here <- getwd()

        # Rendering Rmarkdown script
        rmarkdown::render("${normalization_script}",
            params = list(
                project_name = "${params.project_name}",
                input_step_name = "${input_step_name}",
                thr_n_features = "${params.thr_n_features}",
                n_threads: "${task.cpu}",
                n_memory: "${n_memory}",
                workdir = here
            ), 
            output_dir = here,
            output_file = "${params.project_name}_${input_step_name}_normalize_report.html")
        """
    stub:
        """
        mkdir -p data figures/reduction

        touch data/${params.project_name}_${input_step_name}_normalize_object.RDS
        touch ${params.project_name}_${input_step_name}_normalize_report.html

        touch figures/reduction/EMPTY
        """
}
