process SCBTC_ANNOTATION {
    /* Description */

    tag "Cell annotation"
    label 'process_high'

    container "oandrefonseca/scpackages:1.0"

    input:
        path(project_object)
        path(annotation_script)

    output:
        path("${params.project_name}_annotation_object.RDS"), emit: project_rds
        path("${params.project_name}_annotation_report.html")
        path("figures/annotation/*")
        path("data")

    script:
        """
        #!/usr/bin/env Rscript

        # Getting run work directory
        here <- getwd()

        # Rendering Rmarkdown script
        rmarkdown::render("${annotation_script}",
            params = list(
                project_name = "${params.project_name}",
                project_object = "${project_object}",
                input_cell_markers_db = "${params.input_cell_markers_db}"
                input_annotation_level = "${params.input_annotation_level}"
                workdir = here
            ), 
            output_dir = here,
            output_file = "${params.project_name}_annotation_object_report.html"
            )           

        """
    stub:
        """
        touch ${params.project_name}_annotation_report.html
        touch ${params.project_name}_annotation_object.RDS

        mkdir -p data figures/annotation
        touch figures/annotation/EMPTY
        """
}
