process SCBTC_METAPROGRAM {
    tag "Running meta-program analysis"
    label 'process_high'

    container "oandrefonseca/scrpackages:main"
    publishDir "${params.project_name}", mode: 'copyNoFollow'

    input:
        path(project_object)
        path(meta_script)
        val(input_meta_step)

    output:
        path("data/${params.project_name}_${input_meta_step}_meta_object.RDS"), emit: project_rds
        path("${params.project_name}_${input_meta_step}_meta_report.html")
        path("figures/meta")

    script:
        def n_memory = task.memory.toString().replaceAll(/[^0-9]/, '') as int
        def pipeline_directory = workflow.projectDir.toString().trim()
        """
        #!/usr/bin/env Rscript

        # Getting run work directory
        here <- getwd()

        # Rendering Rmarkdown script
        rmarkdown::render("${meta_script}",
            params = list(
                project_name = "${params.project_name}",
                project_object = "${project_object}",
                input_meta_programs = "${pipeline_directory}/${params.input_meta_programs_db}",
                input_cell_category = "${params.input_cell_category}",
                input_heatmap_annotation = "${params.input_heatmap_annotation}",
                input_meta_step = "${input_meta_step}",
                n_threads = ${task.cpus},
                n_memory = ${n_memory},
                workdir = here
            ), 
            output_dir = here,
            output_file = "${params.project_name}_${input_meta_step}_meta_report.html")
        """
    stub:
        """
        mkdir -p data figures/meta

        touch data/${params.project_name}_${input_meta_step}_meta_object.RDS
        touch ${params.project_name}_${input_meta_step}_meta_report.html

        touch figures/meta/EMPTY
        """
}
