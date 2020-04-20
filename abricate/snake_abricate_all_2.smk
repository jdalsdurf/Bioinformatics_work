#### this passes all fastq files to the following programs
import os
import yaml

file_list = []
### location assumes that data is in results/ folder which is output of SPADES snake workflow
for entry in os.scandir("results/"):
    if entry.is_file():
        file_list.append(entry.name)
#### this tells where data is that will be used for dictionary
config_dict = {"samples":{i.split(".")[0]:"results/"+i for i in file_list}}

with open("config_abricate_argannot.yaml","w") as handle:
    yaml.dump(config_dict,handle)

##### rule all is a general rule that says this is the results we are lookin for in the end.
##### Need to think back to front
configfile: "config_abricate_argannot.yaml"

print("Starting abricate workflow")

rule all:
    input:
        "all_abricate.csv"
##### Abricate argannot
rule argannot:
    input:
        lambda wildcards: config["samples"][wildcards.sample]
    params:
        db_argannot = "argannot",
        type = "csv"
    output:
        argannot = "abricate_results/{sample}_abricate_argannot.csv",
    shell:
        "abricate {input} --{params.type} --db {params.db_argannot} > {output.argannot}"
##### Abricate ncbi
rule ncbi:
    input:
        lambda wildcards: config["samples"][wildcards.sample]
    params:
        db_ncbi = "ncbi",
        type = "csv"
    output:
        ncbi = "abricate_results/{sample}_abricate_ncbi.csv",
    shell:
        "abricate {input} --{params.type} --db {params.db_ncbi} > {output.ncbi}"
##### Abricate resfinder
rule resfinder:
    input:
        lambda wildcards: config["samples"][wildcards.sample]
    params:
        db_resfinder = "resfinder",
        type = "csv"
    output:
        resfinder = "abricate_results/{sample}_abricate_resfinder.csv",
    shell:
        "abricate {input} --{params.type} --db {params.db_resfinder} > {output.resfinder}"
##### Abricate vfdb
rule vfdb:
    input:
        lambda wildcards: config["samples"][wildcards.sample]
    params:
        db_vfdb = "vfdb",
        type = "csv"
    output:
        vfdb = "abricate_results/{sample}_abricate_vfdb.csv",
    shell:
        "abricate {input} --{params.type} --db {params.db_vfdb} > {output.vfdb}"
##### Gatherin all csv files
rule gather:
    input:
        "abricate_results/*.csv",
    output:
        "all_abricate.csv"
    shell:
    "cat {input} > {output}"