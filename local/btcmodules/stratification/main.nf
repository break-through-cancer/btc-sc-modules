process SCBTC_STRATIFICATION {
    tag "Running Cell Stratification"
    label 'process_high'

    container "oandrefonseca/scpackages:1.0"

    input:
        path(project_object)
        path(stratification_script)
        val(input_cancer_type)

    output:
        path("${params.project_name}_*_stratification_object.RDS"), emit: project_rds
        path("${params.project_name}_stratification_report.html")
        path("figures/stratification/*")
        path("data")

    script:
        """
        #!/usr/bin/env Rscript

        # Getting run work directory
        here <- getwd()

        # Rendering Rmarkdown script
        rmarkdown::render("${stratification_script}",
            params = list(
                project_name = "${params.project_name}",
                input_step_name = "${input_step_name}",
                input_cancer_type = "${params.cancer_type}",
                input_stratification_method = "${params.input_stratification_method}",
                thr_proportion = "${params.thr_proportion}",
                thr_cluster_size: "${params.thr_cluster_size}",
                thr_consensus_score: "${params.thr_consensus_score}",
                thr_n_features = "${params.thr_n_features}",
                n_threads: "${task.cpu}",
                n_memory: "${task.memory}",
                workdir = here
            ), 
            output_dir = here,
            output_file = "${params.project_name}_${input_step_name}_stratification_report.html")
        """
    stub:
        """
        touch ${params.project_name}_${input_step_name}_stratification_report.html
        touch ${params.project_name}_stratification_object.RDS
        touch ${params.project_name}_Malignant_stratification_object.RDS
        touch ${params.project_name}_nonMalignant_stratification_object.RDS

        mkdir -p data figures/stratification
        touch figures/stratification/EMPTY
        """
}
