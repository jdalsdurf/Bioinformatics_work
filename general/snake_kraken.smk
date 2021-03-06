#### this passes all fastq files to the following programs
import os
import yaml

file_list = []
### location assumes that data is in kraken_in/ folder which is output of SPADES snake workflow
for entry in os.scandir("kraken_in/"):
    if entry.is_file():
        file_list.append(entry.name)
#### this tells where data is that will be used for dictionary
config_dict = {"samples":{i.split(".")[0]:"kraken_in/"+i for i in file_list}}

with open("config_kraken.yaml","w") as handle:
    yaml.dump(config_dict,handle)

##### rule all is a general rule that says this is the results we are lookin for in the end.
##### Need to think back to front
configfile: "config_kraken.yaml"

print("Starting kraken2 workflow")

rule all:
    input:
        expand("kraken_subset/{sample}_krakenSubset.fasta", sample = config["samples"])

rule kraken subset:
	input:
		fa = lambda wildcards: config["samples"][wildcards.sample],
		kf = "kraken/{sample}.kraken",
	params:
		tax = "590",
		report = "report_kraken/{sample}.report.txt"
	output:
		"kraken_subset/{sample}_krakenSubset.fasta"
	shell:
		"~/krakendb/krakenStandardDb/KrakenTools/extract_kraken_reads.py -k {input.kf} -s {input.fa} -o {output} -t {params.tax} --include-children -r {params.report} "

rule kraken2:
    input:
        lambda wildcards: config["samples"][wildcards.sample]
    output:
        k = "kraken/{sample}.kraken",
        r = "report_kraken/{sample}.report.txt",
    shell:
        "kraken2 --use-names --db ~/krakendb/krakenStandardDb/ --report {output.r} {input} > {output.k}"

### avibacterium 728
### S.suis 1307
### reovirus 38170
### h.parasuis 738
