# Attempt to construct Expirement class via factory pattern

# Acts as a proxy whenever possible. Reads the expirement yml.
class Expirement 

end

# A class to manage specific samples.
class Sample 
	attr_reader :raw_reads 

	# sample_info is a hash found in the yml file.
	def initialize (sample_info)
		@raw_reads = []
	
		unless sample_info['r1'] 
			raise "At minimum \"r1\" reads need to be defined"
		end

		@raw_reads.push sample_info['r1']  
		@raw_reads.push sample_info['r2'] if sample_info['r2'] 

	end 
	# Returns a list of fastq files with the cleaned reads 
	def clean_reads 
		raw_reads # Don't clean reads
	end

	# Returns true if reads are paired
	def paired? 
		raw_reads.length == 2 
	end 

	def sample_recipes 

	end
end

puts Sample.new( "r1"=>"test.fq", "r2"=>"test2.fq" ).raw_reads.to_s




#TODO come up with better name.
#
# This class should never be instantiated.

class SequenceSource
	@@subclasses = {}

	# Recall self denotes class method
	def self.inherited(klass)
		key = klass.to_s.to_sym
		@@subclasses[key] = klass
	end 

	# Construct a new Sequence Source. 
	def self.create(type)
		puts @@subclasses
		return @@subclasses[type.to_sym].new if @@subclasses[type.to_sym]
		raise "No such type #{type}"
	end

end

class IlluminaTruSeq < SequenceSource
	def initialize 
		puts "IlluminaTruSeq created"
	end

	def to_s
		"IlluminaTruSeq"
	end

end


puts (SequenceSource.create :IlluminaTruSeq.to_s)
