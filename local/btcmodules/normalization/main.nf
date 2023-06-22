process SEURAT_NORMALIZATION {
    tag "Running normalization"
    label 'process_high'

    container "oandrefonseca/scpackages:1.0"

    input:
        path(project_object)
        path(normalization_script)
        val(input_step_name)

    output:
        path("${params.project_name}_${input_step_name}_normalize_object.RDS"), emit: project_rds
        path("${params.project_name}_${input_step_name}_normalize_report.html")
        path("data")
        path("figures/*")

    script:
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
                workdir = here
            ), 
            output_dir = here,
            output_file = "${params.project_name}_${input_step_name}_normalize_report.html")
        """
    stub:
        """
        touch ${params.project_name}_${input_step_name}_normalize_report.html
        touch ${params.project_name}_${input_step_name}_normalize_object.RDS

        mkdir -p data figures/reduction
        touch figures/reduction/EMPTY
        """
}
