process SCBTC_FILTERING {
    /* Description */

    tag "Applying QC on cells"
    label 'process_single'

    container 'oandrefonseca/scrpackages:1.0'
    publishDir "${params.project_name}/data/sample/${sample_id}", mode: 'copyNoFollow'

    input:
        tuple val(sample_id), path(matrices), path(csv_metrics), path(meta_data)
        path(scqc_script)

    output:
        tuple val(sample_id), path("objects/*"), path("log/*.txt"), emit: status
        path("${sample_id}_metrics_upgrade.csv"), emit: metrics
        path("${sample_id}_report.html")
        path("figures")

    script:
        def n_memory = task.memory.toString().replaceAll(/[^0-9]/, '') as int
        """
        #!/usr/bin/env Rscript

        # Getting run work directory
        here <- getwd()

        # Rendering Rmarkdown script
        rmarkdown::render("${scqc_script}",
            params = list(
                project_name = "${params.project_name}",
                sample_name = "${sample_id}",
                meta_data = "${meta_data}",
                matrices = "${matrices}",
                csv_metrics = "${csv_metrics}",
                thr_estimate_n_cells = ${params.thr_estimate_n_cells},
                thr_mean_reads_per_cells = ${params.thr_mean_reads_per_cells},
                thr_median_genes_per_cell = ${params.thr_median_genes_per_cell},
                thr_median_umi_per_cell = ${params.thr_median_umi_per_cell},
                thr_n_feature_rna_min = ${params.thr_n_feature_rna_min},
                thr_n_feature_rna_max = ${params.thr_n_feature_rna_max},
                thr_percent_mito = ${params.thr_percent_mito},
                thr_n_observed_cells = ${params.thr_n_observed_cells},
                n_threads = ${task.cpus},
                n_memory = ${n_memory},
                workdir = here
            ), 
            output_dir = here,
            output_file = "${sample_id}_report.html")
        """
    stub:
        """
        touch ${sample_id}_report.html
        touch ${sample_id}_metrics_upgrade.csv

        mkdir -p objects log figures
        touch log/SUCCESS.txt 
        touch objects/${sample_id}.RDS
        """
}
