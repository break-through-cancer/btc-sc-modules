process SCBTC_RECLUSTERING {
    /* Description */

    tag "Clustering ${input_cluster_step} cells"
    label 'process_high'

    container "oandrefonseca/scrpackages:main"
    publishDir "${params.project_name}", mode: 'copy'

    input:
        path(project_object)
        path(best_scored)
        path(cluster_script)
        val(input_cluster_step)

    output:
        path("data/${params.project_name}_${input_cluster_step}_cluster_object.RDS"), emit: project_rds
        path("${params.project_name}_${input_cluster_step}_cluster_report.html")
        path("figures/clustering")

    script:
        def n_memory = task.memory.toString().replaceAll(/[^0-9]/, '') as int
        """
        #!/usr/bin/env Rscript

        # Getting run work directory
        here <- getwd()

        # Rendering Rmarkdown script
        rmarkdown::render("${cluster_script}",
            params = list(
                project_name = "${params.project_name}",
                project_object = "${project_object}",
                input_integration_dimension = "${params.input_integration_dimension}",
                input_cluster_step = "${input_cluster_step}",
                thr_resolution = ${params.thr_resolution},
                thr_proportion = ${params.thr_proportion},
                n_threads = ${task.cpus},
                n_memory = ${n_memory},
                workdir = here
            ), 
            output_dir = here,
            output_file = "${params.project_name}_${input_cluster_step}_cluster_report.html"
            )           

        """
    stub:
        """
        mkdir -p data figures/clustering

        touch data/${params.project_name}_${input_cluster_step}_cluster_object.RDS
        touch ${params.project_name}_${input_cluster_step}_cluster_report.html
        
        touch figures/clustering/EMPTY
        """
}