process SCBTC_CLUSTERING {
    tag "Clustering cells"
    label 'process_high'

    container "oandrefonseca/scpackages:1.0"

    input:
        path(project_object)
        path(cluster_script)
        val(input_cluster_step)

    output:
        path("${params.project_name}_cluster_object_*.RDS"), emit: project_rds
        path("${params.project_name}_cluster_report.html")
        path("figures/clustering/*")
        path("data/*")

    script:
        """
        #!/usr/bin/env Rscript

        # Getting run work directory
        here <- getwd()

        # Rendering Rmarkdown script
        rmarkdown::render("${cluster_script}",
            params = list(
                project_name = "${params.project_name}",
                project_object = "${project_object}",
                input_integration_method = "${input_integration_method}",
                input_cluster_step = "${input_cluster_step}",
                thr_resolution = ${params.thr_resolution},
                thr_proportion = ${params.thr_proportion},
                workdir = here
            ), 
            output_dir = here,
            output_file = "${params.project_name}_${input_cluster_step}_cluster_report.html"
            )           

        """
    stub:
        """
        touch ${params.project_name}_${input_cluster_step}_cluster_report.html
        touch ${params.project_name}_${input_cluster_step}_cluster_object.RDS

        mkdir -p figures/clustering
        touch figures/clustering/EMPTY
        """
}
