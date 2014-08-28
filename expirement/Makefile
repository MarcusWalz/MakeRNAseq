# This workflow translates raw read data in the form of fastq files 
# to differential expression data against a reference genome.


# Edits to make:
# 
# Use symbolic link and scaffold hacks to make workflow more flexible.
#
# 1. Change directory structure. 
#
# Introduce Genome Directory
# E.g. 
# genome/ZV8/source.sh 
# genome/ZV8/genome.fa 
# genome/ZV8/transcripts.gtf 
# genome/ZV8/bowtie_genome_idx/
# genome/ZV8/bowtie_transcripts_idx/
#
# Introduce Expirement Directory
# expirement/<expirement_name>/
# 	samples/<conditon_name>-R<replicate_number>/
#   genome/ -> ../../ZV8 (should be a symlink)
#   diff/
#   scripts/
#   
#   This way sample sheets can be generated from the directory structure using a generic rule.
#
#   All outputs for the expirement stay inside this directory.


# Prevent Make from Deleting Intermediate Files. If disk space is an
# issue, deleting the seconday flag will let Make will delete intermediate
# files as soon as possible. 
.SECONDARY:
	
# Usage: 
# 0. install tophat bowtie2 cufflinks fastqc cutadapt samtools 
# Everything BUT cutadapt is preinstalled in the bin directory for Avi.
export PATH := bin:$(PATH)

# Installing cutadapt on Avi, for now you can use my own personal version. 
# N.b. this is likely to break.
export PATH := /share7/SPH/ptone_a/mewalz/software/python/bin/:$(PATH)

# Download a file
%: %.source ; 
	wget -O $@ `cat $<`

# Ungzip a file
% : %.gz ; 
	gzcat $< > $@

# Download and ungzip file
genome/%/genome.fq: genome/%/genome.fq.gz.source ; 
	wget -O - o /dev/null `cat $<` | gunzip > $@

genome/%/bowtie2_idx.output : genome/%/genome.fq ;
	salloc --mem 8000 srun bowtie2-build $< $(@D)/bowtie2 | tee $@

# The following rule checks to make sure all required software is available.
# To run:
# $ make test_software 
test_software : ;
	which bowtie2 tophat cufflinks fastqc cutadapt samtools

# 1. Each Sample needs to be stuck in the samples directory so that the 
# directory samples/<sample_name>/raw_reads contains the following files:
# - r1.fq.gz   Left reads
# - r2.fq.gz   Right reads
# - index      file containing Illumina Adapter Index Used. 
#
# Note that the file "index"  must be a single lined file. A nice way to generate this file is
# to simply echo it into a file like so:
#	echo "AGGGTC" > samples/BC8/raw_reads/index
#
# I do not recommend performing step 1 manually since user error is inevitable. Instead, 
# link the files by looping through a tab delimetted file. See scripts/build_structs.sh
# and scripts/samples for an example on how to do this. 

# 2. Also we need to include the genome data.
# Note that this workflow assumes every sample uses the same genome. 

genome_fa = genome/zebrafish.fa
# Genome's corresponding GTF  
genome_gtf = genome/zebrafish.gtf
# Location/name of Indexed Genome, this is automatically generated.
genome_pre = genome/zebrafish
genome_idx = $(genome_pre)-idx 

# Directory containing each chromosome in individual FASTA file
genome_chromo_dir = genome/chromo


# 3. Next encode some information about the expirment into this very makefile.
# Follow the examples below. This is essentially a game of coping and pasting.

# 4. Now the workflow should be ready to run. To run it using up to 40 concurrent
# SLURM jobs, excute the following command from the very same directory this file lives in. 
#
# $ make -j 48 diff/retina 
#
# It's a good idea to submit the command as an sbatch job. Depending on how busy the 
# cluster is and the size of the data set, this can take between 4 and 24 hours. 


#Index the genome. This takes a long time
$(genome_idx) : $(genome_fa) ;
	salloc --mem 8000 srun bowtie2-build $(genome_fa) $(genome_pre) > $@

samples/%/cleaned_reads : ;
	mkdir $@ && true

#Clean the reads via the the script scripts/cutadapt.sh
samples/%/cleaned_reads/r1.fq.gz : \
	scripts/cutadapt.sh \
	samples/%/raw_reads/index \
	samples/%/raw_reads/r1.fq.gz \
	samples/%/raw_reads/r2.fq.gz ;
	salloc -c 1 -N 1 -J cutadapt  srun scripts/cutadapt.sh samples/$*/

#Dummy rule used for fastqc reports
samples/%/cleaned_reads/r2.fq.gz : samples/%/cleaned_reads/r1.fq.gz ;

#Generate a fastqc report for a a fastq file.
%.fq_fastqc.zip : %.fq.gz ;
	salloc -c 1 -J $@  srun fastqc --outdir $(@D) $<

#Produce transcriptome using cufflinks
samples/%/cufflinks/transcripts.gtf : \
	samples/%/tophat/accepted_hits.bam \
	scripts/cufflinks.sh \
	$(genome_fa) \
	$(genome_gtf) 
	salloc -c 8 -N 1 --mem 21000 -J cufflinks srun scripts/cufflinks.sh $(@D)


#Align to genome via tophat via the script: scripts/tophat.sh
#scripts/tophat.sh is removed from dependencies to prevent timely computations
samples/%/tophat/accepted_hits.bam : \
	$(genome_idx) \
	$(genome_gtf) \
	scripts/tophat.sh \
	samples/%/cleaned_reads/r1.fq.gz \
	samples/%/cleaned_reads/r2.fq.gz ;
	salloc -c 8 -N 1 --mem 21000 -J tophat srun scripts/tophat.sh $(@D)

#Index bam
samples/%/tophat/accepted_hits.bam.bai : samples/%/tophat/accepted_hits.bam ;
	salloc --mem 5000 -J samtools-index srun samtools index $< 




# Do some alignment QC

samples/%/align_report : samples/%/tophat/accepted_hits.bam ;
	salloc -c 8 -J qualimap srun qualimap bamqc \
		-bam $< \
		-nt 8 \
		-outformat PDF \
		-outdir $@

##########################
# Here we need to encode some information about each expirement.
# Some of the rules are expirement specific. 
##########################

all_samples = $(wildcard samples/*/)
all_r1_qc = $(addsuffix cleaned_reads/r1.fq_fastqc.zip, $(all_samples))
all_r2_qc = $(addsuffix cleaned_reads/r2.fq_fastqc.zip, $(all_samples))

all_r1_raw_qc = $(addsuffix raw_reads/r1.fq_fastqc.zip, $(all_samples))
all_r2_raw_qc = $(addsuffix raw_reads/r2.fq_fastqc.zip, $(all_samples))

all_fastqc : $(all_r1_qc) $(all_r2_qc); 

all_raw_fastqc : $(all_r1_raw_qc) $(all_r2_raw_qc) ;

# Samples we'll be analyzing 

brain_samples  = $(wildcard samples/B*/)
retina_samples = $(wildcard samples/R*/)
ovary_samples  = $(wildcard samples/A*/)
embryo_samples  = $(wildcard samples/F*/)

#Location of the gtf file. 

brain_samples_gtf  = $(addsuffix cufflinks/transcripts.gtf, $(brain_samples))
retina_samples_gtf = $(addsuffix cufflinks/transcripts.gtf, $(retina_samples))
ovary_samples_gtf  = $(addsuffix cufflinks/transcripts.gtf, $(ovary_samples))
embryo_samples_gtf  = $(addsuffix cufflinks/transcripts.gtf, $(embryo_samples))

#Location of the bam file. 

brain_samples_bam = $(addsuffix tophat/accepted_hits.bam, $(brain_samples))
retina_samples_bam = $(addsuffix tophat/accepted_hits.bam, $(retina_samples))
ovary_samples_bam = $(addsuffix tophat/accepted_hits.bam, $(ovary_samples))
embryo_samples_bam = $(addsuffix tophat/accepted_hits.bam, $(embryo_samples))

#Future location of cxb file

brain_cxb  = $(addsuffix abundance.cxb,$(brain_samples))
retina_cxb = $(addsuffix abundance.cxb,$(retina_samples))
ovary_cxb  = $(addsuffix abundance.cxb,$(ovary_samples))
embryo_cxb  = $(addsuffix abundance.cxb,$(embryo_samples))

#phony rule to prepare all the relevent gtf files used in merging
all_transcripts : $(brain_samples_gtf) $(retina_samples_gtf) $(ovary_samples_gtf) $(embryo_samples_gtf); 
	echo $@

#Generate a file containing the list of samples to be merged together. This file is required by cuffmerge. 
transcripts/retina.samples : $(retina_samples_gtf) ;
	echo $(retina_samples_gtf) | sed -e "s/\ /\n/g" > $@
transcripts/brain.samples : $(brain_samples_gtf) ;
	echo $(brain_samples_gtf) | sed -e "s/\ /\n/g" > $@
transcripts/ovary.samples : $(ovary_samples_gtf) ; 
	echo $(ovary_samples_gtf) | sed -e "s/\ /\n/g" > $@
transcripts/embryo.samples : $(embryo_samples_gtf) ; 
	echo $(embryo_samples_gtf) | sed -e "s/\ /\n/g" > $@

#merge the samples into single transcriptome via cuff merge.
transcripts/%/merged.gtf : transcripts/%.samples $(genome_fq) $(genome_gtf) ;
	salloc -c 8 -N 1 --mem 22000 -J cuffmerge srun \
	cuffmerge -o transcripts/$* --num-threads 8 --ref-sequence $(genome_fa) --ref-gtf $(genome_gtf) $< 

#compare to reference. THIS IS NOT WORKING
transcripts/%/stats : transcripts/%/merged.gtf $(genome_gtf) ;
	salloc -c 1 -N 1 --mem 2000 -J cuffcomapre srun \
	cuffcompare -o $@ -r $(genome_gtf)  $<

#cuffquant against generated transcriptomes. This speeds up downstream analysis.
samples/B%/abundances.cxb : transcripts/brain/merged.gtf samples/B%/tophat/accepted_hits.bam ; 
	salloc -c 8 -N 1 --mem 22000 -J cuffquant srun \
	cuffquant --output-dir samples/B$*/ --quiet --num-threads 8 $^
samples/R%/abundances.cxb : transcripts/retina/merged.gtf samples/R%/tophat/accepted_hits.bam ; 
	salloc -c 8 -N 1 --mem 22000 -J cuffquant srun \
	cuffquant --output-dir samples/R$*/ --quiet --num-threads 8 $^
samples/A-%/abundances.cxb : transcripts/ovary/merged.gtf samples/A-%/tophat/accepted_hits.bam ; 
	salloc -c 8 -N 1 --mem 22000 -J cuffquant srun \
	cuffquant --output-dir samples/A-$*/ --quiet --num-threads 8 $^
samples/F-%/abundances.cxb : transcripts/embryo/merged.gtf samples/F-%/tophat/accepted_hits.bam ; 
	salloc -c 8 -N 1 --mem 22000 -J cuffquant srun \
	cuffquant --output-dir samples/F-$*/ --quiet --num-threads 8 $^
	
#make all cxb_files
all_cxb : $(brain_cxb) $(ovary_cxb) $(retina_cxb) ;
	@echo $^ > $@

#Brain control samples
brain_c = $(addsuffix abundances.cxb, $(wildcard samples/BC*/))
#Treatment samples
brain_t = $(addsuffix abundances.cxb, $(wildcard samples/BT*/))

#ibid
retina_c = $(addsuffix abundances.cxb, $(wildcard samples/RC*/))
retina_t = $(addsuffix abundances.cxb, $(wildcard samples/RT*/))

#ibid
ovary_0ppm = $(addsuffix abundances.cxb, $(wildcard samples/A-00ppm*/))
ovary_1ppm = $(addsuffix abundances.cxb, $(wildcard samples/A-01ppm*/))
ovary_3ppm = $(addsuffix abundances.cxb, $(wildcard samples/A-03ppm*/))
ovary_10ppm = $(addsuffix abundances.cxb, $(wildcard samples/A-10ppm*/))

embryo_0ppm = $(addsuffix abundances.cxb, $(wildcard samples/F-00ppm*/))
embryo_1ppm = $(addsuffix abundances.cxb, $(wildcard samples/F-01ppm*/))
embryo_3ppm = $(addsuffix abundances.cxb, $(wildcard samples/F-03ppm*/))
embryo_10ppm = $(addsuffix abundances.cxb, $(wildcard samples/F-10ppm*/))

#make sample sheet for brain. This is file that specifies which cxb file belongs to which sample. 
brain_samples : $(brain_c) $(brain_t) ; 
	printf "sample_id\tgroup_label\n" > $@
	ls $(brain_c) | sed 's/$$/\tcontrol/' >> $@
	ls $(brain_t) | sed 's/$$/\ttreatment/' >> $@

retina_samples : $(retina_c) $(retina_t) ; 
	printf "sample_id\tgroup_label\n" > $@
	ls $(retina_c) | sed 's/$$/\tcontrol/' >> $@
	ls $(retina_t) | sed 's/$$/\ttreatment/' >> $@

#things are a bit more complicated here.
ovary_samples : $(ovary_0ppm) $(ovary_1ppm) $(ovary_3ppm) $(ovary_10ppm) ;
	printf "sample_id\tgroup_label\n" > $@
	ls $(ovary_0ppm) | sed 's/$$/\tppm0/' >> $@
	ls $(ovary_1ppm) | sed 's/$$/\tppm1/' >> $@
	ls $(ovary_3ppm) | sed 's/$$/\tppm3/' >> $@
	ls $(ovary_10ppm) | sed 's/$$/\tppm10/' >> $@

embryo_samples : $(embryo_0ppm) $(embryo_1ppm) $(embryo_3ppm) $(embryo_10ppm) ;
	printf "sample_id\tgroup_label\n" > $@
	ls $(embryo_0ppm) | sed 's/$$/\tppm0/' >> $@
	ls $(embryo_1ppm) | sed 's/$$/\tppm1/' >> $@
	ls $(embryo_3ppm) | sed 's/$$/\tppm3/' >> $@
	ls $(embryo_10ppm) | sed 's/$$/\tppm10/' >> $@



#run cuff norm over the sample file. Cuffdiff does all this and more.
norm/% : transcripts/%/merged.gtf %_samples ;
	salloc -c 8 -N 1 --mem 22000 srun cuffnorm \
		--num-threads 8 \
		--quiet \
		--output-dir $@ \
		--use-sample-sheet $^

#run cuff diff over the sample file
diff/% : transcripts/%/merged.gtf %_samples ;
	salloc -c 8 -N 1 --mem 22000 srun cuffdiff \
		--num-threads 8 \
		--quiet \
		--output-dir $@ \
		--use-sample-sheet $^

%_samples.boiler_plate : %_samples ;
	sed 's/abundances.cxb/\/tophat\/accepted_hits.bam/' < $< > $@

#run cuff diff, over boiler plate gtf 
diff_boiler/% : $(genome_gtf) %_samples.boiler_plate ;
	salloc -c 8 -N 1 --mem 22000 srun cuffdiff \
		--num-threads 8 \
		--quiet \
		--output-dir $@ \
		--use-sample-sheet $^
