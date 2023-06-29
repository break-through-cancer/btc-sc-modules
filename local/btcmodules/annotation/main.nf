process SCBTC_ANNOTATION {
    /* Description */

    tag "Cell annotation"
    label 'process_high'

    container "oandrefonseca/scpackages:1.0"
    publishDir "${params.project_name}", mode: 'copyNoFollow'

    input:
        path(project_object)
        path(annotation_script)

    output:
        path("data/${params.project_name}_annotation_object.RDS"), emit: project_rds
        path("${params.project_name}_annotation_report.html")
        path("figures/annotation")

    script:
        def n_memory = task.memory.toString().replaceAll(/[^0-9]/, '') as int
        """
        #!/usr/bin/env Rscript

        # Getting run work directory
        here <- getwd()

        # Rendering Rmarkdown script
        rmarkdown::render("${annotation_script}",
            params = list(
                project_name = "${params.project_name}",
                project_object = "${project_object}",
                input_cell_markers_db = "${params.input_cell_markers_db}",
                input_annotation_level = "${params.input_annotation_level}",
                n_threads = ${task.cpus},
                n_memory = ${n_memory},
                workdir = here
            ), 
            output_dir = here,
            output_file = "${params.project_name}_annotation_report.html"
            )           

        """
    stub:
        """
        mkdir -p data figures/annotation
        
        touch data/${params.project_name}_annotation_object.RDS
        touch ${params.project_name}_annotation_report.html

        touch figures/annotation/EMPTY
        """
}
