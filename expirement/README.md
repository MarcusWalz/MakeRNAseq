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

In order to use Rake outside of top level scope you need to require the
rake DSL module.

Here is an example:

~~~~

class Greeting
 	include Rake::DSL # Needed to use rake within instance methods
	def initialize ( name ) 
		@name = name 

		make_rule
	end 

	def greeting
		"Hello"
	end

	def make_rule
		task name do 
			puts "#{name} says #{greeting}"
		end
	end 


	def name 
		@name
	end
end

Greeting.new("Bob")
Greeting.new("John")


# These greeting are too generic for Tom. Let's spice things up a bit:

class SillyGreeting < Greeting 

	def greeting
		"HIIIIIIIYYAAAAAAAAA"
	end

end

SillyGreeting.new("Tom")
~~~ 


Then the command: 

~~~
$ rake Bob John Tom
~~~

Outputs:

~~~
Bob says Hello
John says Hello
Tom says HIIIIIIIYYAAAAAAAAA
~~~

Whoa!!! What just happened? Rake was able to generate rules on object instantiation.
All we need was `include Rake::DSL` below the class definition. This all works because Rules
get executed in the same scope they were defined in.  Everything is suprisingly intuitive.

The advantage of this approach is that it allows rules to be written on a "single sample" basis
instead of an "every sample" basis. So instead of worrying about wildcards and pattern matching 
Rake can dynamically generate "contrete" rules. While the above example may seem a bit verbose,
when working in complicated real-world scenarios it tends to simplify things greatly.

This approach is stable and is even used in the Ruby on Rails framework to unify Rake rules from
many disjoint extensions. In addition Rakefiles can import simple Makefiles dynamically.

Applying this approach to bioinformatic workflows means that:

* Details about expirment design from the logic of the workflow can be decoupled.
* Sequencing specific paramaters and adjustments to the workflow can be
	handled concisely object-oriented inheritance.
* Parallel execution of the workflow is both efficient and implicit.
* Workflow execution halts affected computations the event of an error.
* Workflow can be extened uses Ruby modules.
