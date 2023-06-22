process SCBTC_DIFFERENTIAL {
    tag "Running DEG Analysis"
    label 'process_high'

    container "oandrefonseca/scpackages:1.0"

    input:
        path(project_object)
        path(differential_script)
        val(input_step_name)

    output:
        path("${params.project_name}_${input_step_name}_deg_table.RDS"), emit: project_rds
        path("${params.project_name}_${input_step_name}_deg_report.html")
        path("figures/deg/*")
        data("data")

    script:
        """
        #!/usr/bin/env Rscript

        # Getting run work directory
        here <- getwd()

        # Rendering Rmarkdown script
        rmarkdown::render("${differential_script}",
            params = list(
                project_name = "${params.project_name}",
                input_deg_method = "${params.input_deg_method}",
                input_top_deg = "${params.input_top_deg}",
                input_step_name = "${input_step_name}",
                thr_n_features = "${params.thr_n_features}",
                thr_fold_change = "${params.thr_fold_change}",
                thr_min_percentage = "${params.thr_min_percentage}",
                opt_hgv_filter = "${params.opt_hgv_filter}",
                workdir = here
            ), 
            output_dir = here,
            output_file = "${params.project_name}_${input_step_name}_deg_report.html")
        """
    stub:
        """
        touch ${params.project_name}_${input_step_name}_deg_report.html
        touch ${params.project_name}_${input_step_name}_deg_table.RDS

        mkdir -p data figures/deg
        touch figures/deg/EMPTY
        """
}
