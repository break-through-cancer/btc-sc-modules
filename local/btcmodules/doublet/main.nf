process SCBTC_DOUBLET {
    tag "Running ${input_doublet_name} doublet detection"
    label 'process_high'

    container "oandrefonseca/scrpackages:main"
    publishDir "${params.project_name}", mode: 'copyNoFollow'

    input:
        path(project_object)
        path(doublet_script)
        val(input_doublet_name)

    output:
        path("data/${params.project_name}_${input_doublet_name}_doublet_table.RDS"), emit: project_rds
        path("${params.project_name}_${input_doublet_name}_doublet_report.html")
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
                project_object = "${project_object}",
                input_doublet_name = "${input_doublet_name}",
                n_threads = ${task.cpus},
                n_memory = ${n_memory},
                workdir = here
            ), 
            output_dir = here,
            output_file = "${params.project_name}_${input_doublet_name}_doublet_report.html")
        """
    stub:
        """
        mkdir -p data figures/doublet
        
        touch data/${params.project_name}_${input_doublet_name}_doublet_table.RDS
        touch ${params.project_name}_${input_doublet_name}_doublet_report.html

        touch figures/doublet/EMPTY
        """
}
