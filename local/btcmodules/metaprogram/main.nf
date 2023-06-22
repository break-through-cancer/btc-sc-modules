process SEURAT_META_PROGRAM {
    tag "Running normalization"
    label 'process_high'

    container "oandrefonseca/scpackages:1.0"

    input:
        path(project_object)
        path(normalization_script)
        val(input_step_name)

    output:
        path("${params.project_name}_${input_step_name}_meta_object.RDS"), emit: project_rds
        path("${params.project_name}_${input_step_name}_meta_report.html")
        path("figures/meta/*")
        path("data")

    script:
        """
        #!/usr/bin/env Rscript

        # Getting run work directory
        here <- getwd()

        # Rendering Rmarkdown script
        rmarkdown::render("${normalization_script}",
            params = list(
                project_name = "${params.project_name}",
                input_meta_programs = "${params.input_meta_programs}",
                input_cell_category = "${params.input_cell_category}",
                input_heatmap_annotation = "${params.input_heatmap_annotation}",
                input_step_name = "${input_step_name}",
                n_threads = "${task.cpu}",
                n_memory = "${task.memory}",
                workdir = here
            ), 
            output_dir = here,
            output_file = "${params.project_name}_${input_step_name}_meta_report.html")
        """
    stub:
        """
        touch ${params.project_name}_${input_step_name}_meta_report.html
        touch ${params.project_name}_${input_step_name}_meta_object.RDS

        mkdir -p data figures/meta
        touch figures/meta/EMPTY
        """
}
