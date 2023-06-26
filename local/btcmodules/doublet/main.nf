process SCBTC_DOUBLET {
    tag "Running doublet detection"
    label 'process_high'

    container "oandrefonseca/scpackages:1.0"
    publishDir "${params.project_name}", mode: 'copyNoFollow'

    input:
        path(project_object)
        path(doublet_script)
        val(input_step_name)

    output:
        path("data/${params.project_name}_${input_step_name}_doublet_table.RDS"), emit: project_rds
        path("${params.project_name}_${input_step_name}_doublet_report.html")
        path("figures/doublet")

    script:
        def n_memory = task.memory.toString().replaceAll(/[^0-9]/, '') as int
        """
        #!/usr/bin/env Rscript

        # Getting run work directory
        here <- getwd()

        # Rendering Rmarkdown script
        rmarkdown::render("${doublet_script}",
            params = list(
                project_name = "${params.project_name}",
                input_step_name = "${input_step_name}",
                n_threads = "${task.cpu}",
                n_memory = "${n_memory}",
                workdir = here
            ), 
            output_dir = here,
            output_file = "${params.project_name}_${input_step_name}_doublet_report.html")
        """
    stub:
        """
        mkdir -p data figures/doublet
        
        touch data/${params.project_name}_${input_step_name}_doublet_table.RDS
        touch ${params.project_name}_${input_step_name}_doublet_report.html

        touch figures/doublet/EMPTY
        """
}
