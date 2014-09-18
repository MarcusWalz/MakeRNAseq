Running bioinformatics workflows efficiently on high performance computing (HPC) 
infrastructure is hard. A typical workflow consists of dozens of batch steps comprising of 
hundreds of individual tasks. This is further complicated by the fact that 
somewhere, something will fail do to the instability of HPC platforms and bioinformatic
tools. Since the underlying tasks that compose a bioinformatic workflow are computationally
expensive, speedy iterative devolpment of a bioinformatic workflow requires that superfolous 
computations are avoided whenever possible.

To simplify a workflow we generate a dependency graph that encodes the inputs and ouputs of each task of the workflow
allowing HPC job submission and monitoring to become implicitly handled by the program `rake`--the ruby programming
language's version of the popular build automation tool `make`. Only computations that are considered obsolete or
nonexistant are run speeding up time of development.


TODO introduce rules

`rake` is used instead of `make` in order to increase the versatility of the workflow by generating concrete rules
in a more flexible object-oriented style. This object-oriented approach allows expirment details to be encoded 
outside the workflows code in a human readable `yaml` file. The added versatility means the workflow can be fine
tuned for multiple expiremental data sets derived from different sequencing technologies simultanously. The `yaml`
file is then used to constuct the recipes
for handling the data specific to the expirement; e.g. how to clean the raw RNAseq reads and what parameters to 
supply to Cufflinks given a particular sequencing technology.


## Foundation

`rake` is really just an extension to Ruby. There are three core rules:

* `file` a rule with  an associated output file
	```
	file "foo" => [] do |t|
		sh "#{t.name}"
	end
	```
* `directory` a rule that ensures a particular directory exists
	```
	directory "my_dir" 
	```
* `task` a rule without any associated output files
	```
	task :symbol => ["foo"] do |t|
		sh "cat foo"
	end
	```
