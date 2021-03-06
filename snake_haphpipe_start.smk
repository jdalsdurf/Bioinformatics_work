#### this passes all fastq files to the following programs
import os
import yaml

file_list = []
### location assumes that data is in relabeled_reads/ibv/ folder
for entry in os.scandir("clean_fastq/"):
    if entry.is_file():
        file_list.append(entry.name)
#### this tells where data is that will be used for dictionary
config_dict = {"samples":{i.split(".")[0]:"clean_fastq/"+i for i in file_list}}

with open("config_haphpipe_denovo.yaml","w") as handle:
    yaml.dump(config_dict,handle)

##### rule all is a general rule that says this is the results we are lookin for in the end.
##### Need to think back to front
configfile: "config_haphpipe_denovo.yaml"

rule all:
    input:
#        expand("denovo_results/{sample}_denovo_contigs.fasta", sample = config["samples"])
        expand("{sample}_scaffold_results/{sample}_scaffold_padded.fasta", sample = config["samples"])

rule assemble_denovo:
    input:
        lambda wildcards: config["samples"][wildcards.sample]
    output:
        rename="denovo_results/{sample}_denovo_contigs.fasta",
        rename2="denovo_results/{sample}_denovo_contigs.txt",
    run:
        shell("haphpipe assemble_denovo --fqU {input} --ncpu 8"),
        shell("mv denovo_contigs.fna {output.rename}"),
        shell("mv denovo_summary.txt {output.rename2}"),

rule assemble_scaffold_linear:
    input:
        "denovo_results/{sample}_denovo_contigs.fasta"
    output:
        rename="{sample}_scaffold_results/{sample}_scaffold_aligned.fasta",
        rename1="{sample}_scaffold_results/{sample}_scaffold_assembly.fasta",
        rename2="{sample}_scaffold_results/{sample}_scaffold_imputed.fasta",
        rename3="{sample}_scaffold_results/{sample}_scaffold_padded.fasta",

    params:
        ref="prrs_mn11b_linear.fasta"
    run:
#        shell("mkdir scaffold_results"),
        shell("haphpipe assemble_scaffold --contigs_fa {input} --ref_fa {params.ref}"),
        shell("mv scaffold_aligned.fa {output.rename}"),
        shell("mv scaffold_assembly.fa {output.rename1}"),
        shell("mv scaffold_imputed.fa {output.rename2}"),
        shell("mv scaffold_padded.out {output.rename3}")
