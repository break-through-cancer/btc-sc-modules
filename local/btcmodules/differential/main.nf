process SCBTC_DIFFERENTIAL {
    tag "Running ${input_deg_step} DEG Analysis"
    label 'process_high'

    container "oandrefonseca/scpackages:1.0"
    publishDir "${params.project_name}", mode: 'copyNoFollow'

    input:
        path(project_object)
        path(differential_script)
        val(input_deg_step)

    output:
        path("data/${params.project_name}_${input_deg_step}_deg_table.RDS"), emit: project_rds
        path("${params.project_name}_${input_deg_step}_deg_report.html")
        path("figures/deg")

    script:
       def n_memory = task.memory.toString().replaceAll(/[^0-9]/, '') as int
       """
        #!/usr/bin/env Rscript

        # Getting run work directory
        here <- getwd()

        # Rendering Rmarkdown script
        rmarkdown::render("${differential_script}",
            params = list(
                project_name = "${params.project_name}",
                project_object = "${project_object}",
                input_deg_method = "${params.input_deg_method}",
                input_top_deg = ${params.input_top_deg},
                input_deg_step = "${input_deg_step}",
                thr_fold_change = ${params.thr_fold_change},
                thr_min_percentage = ${params.thr_min_percentage},
                opt_hgv_filter = "${params.opt_hgv_filter}",
                n_threads = ${task.cpus},
                n_memory = ${n_memory},
                workdir = here
            ), 
            output_dir = here,
            output_file = "${params.project_name}_${input_deg_step}_deg_report.html"
            )
        """
    stub:
        """
        mkdir -p data figures/deg

        touch data/${params.project_name}_${input_deg_step}_deg_table.RDS
        touch ${params.project_name}_${input_deg_step}_deg_report.html

        touch figures/deg/EMPTY
        """
}
