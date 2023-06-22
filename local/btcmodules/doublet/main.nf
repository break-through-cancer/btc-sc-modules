process SCBTC_DOUBLET {
    tag "Running doublet detection"
    label 'process_high'

    container "oandrefonseca/scpackages:1.0"

    input:
        path(project_object)
        path(doublet_script)
        val(input_step_name)

    output:
        path("${params.project_name}_${input_step_name}_doublet_table.RDS"), emit: project_rds
        path("${params.project_name}_${input_step_name}_doublet_report.html")
        path("data")        
        path("figures/doublet/*")

    script:
        """
        #!/usr/bin/env Rscript

        # Getting run work directory
        here <- getwd()

        # Rendering Rmarkdown script
        rmarkdown::render("${doublet_script}",
            params = list(
                project_name = "${params.project_name}",
                input_step_name = "${input_step_name}",
                workdir = here
            ), 
            output_dir = here,
            output_file = "${params.project_name}_${input_step_name}_doublet_report.html")
        """
    stub:
        """
        touch ${params.project_name}_${input_step_name}_doublet_report.html
        touch ${params.project_name}_${input_step_name}_doublet_table.RDS

        mkdir -p data figures/double
        touch figures/doublet/EMPTY
        """
}
