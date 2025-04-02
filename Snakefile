#load configuration
configfile: "config.yaml"

# Assign variables from config directories
INPUT_DIR = config["INPUT_DIR"]
OUTPUT_DIR = config["OUTPUT_DIR"]
TMP_DIR = config["TMP_DIR"]
TOOLS_DIR = config["TOOLS_DIR"]


# Collect all batch names from input files
batches = glob_wildcards(INPUT_DIR+"/{batch}.txt").batch

rule all:
    input:
        expand(OUTPUT_DIR+"/{batch}.tar.xz", batch = batches)

rule compute_tree:
    input:
        INPUT_DIR + "/{batch}.txt"
    output:
        TMP_DIR+"/trees/{batch}.nw"
    shell:
        "attotree -L {input} -o {output}"

rule get_tree_order:
    input:
        TMP_DIR+"/trees/{batch}.nw"
    output:
        TMP_DIR+"/tree_ordered_batches/{batch}.phylo.txt"
    shell:
        "grep -o '[^,:()]*:' {input} | sed 's/:$//' | grep -Ev '^$' > {output}"

rule prepend_batch_path:
    input:
        INPUT_DIR + "/{batch}.txt",
        TMP_DIR+"/tree_ordered_batches/{batch}.phylo.txt"
    output:
        TMP_DIR+"/processed_batches/{batch}.processed.txt"
    shell:
        """
        bash {TOOLS_DIR}/match_file_paths.sh {input[0]} {input[1]} {output}
        """

rule compress_batch:
    input:
        TMP_DIR+"/processed_batches/{batch}.processed.txt"
    output:
        OUTPUT_DIR+"/{batch}.tar.xz"
    shell:
        """
        ./{TOOLS_DIR}/miniphy2 compress -p '{wildcards.batch}/' -lfo {output} {input}
        """