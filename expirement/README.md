Running bioinformatics workflows efficiently on high performance computing (HPC) 
infrastructure is hard. A typical workflow consists of dozens of batch steps comprising of 
hundreds of individual tasks. This is further complicated by the fact that 
somewhere, something will fail do to the instability of HPC platforms and bioinformatic
tools. Since the underlying tasks that compose a bioinformatic workflow are computationally
expensive, speedy iterative devolpment of a bioinformatic workflow requires that superfolous 
computations are avoided whenever possible.

To simplify a workflow we encode it as a dependency graph so that HPC job submission and monitoring 
becomes implicitly handled by the program `rake`--the ruby programming language's version of the popular
build automation tool `make`. Only computations that are considered obsolete or nonexistant are run speeding
up time of development.



