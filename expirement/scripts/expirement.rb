# Attempt to construct Expirement class via factory pattern

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


SequenceSource.create :IlluminaTruSeq
