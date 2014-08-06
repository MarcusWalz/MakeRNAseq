# Let's see what each macro does.
# To run all the rules run:
# $ make test.txt

dependency2 : ; touch dependency2

%.txt : this_is_a_directory/i_live_in_a_subdir dependency1 dependency2 dependency1;
	@echo target name: $$\@ $@ >  $@
	@echo 1st dependency: $$\< $<  >> $@
	@echo Dependencies younger than target: $$\? $? >> $@
	@echo Suffix match: $$\* $* >> $@
	@echo Dependency Set: $$\^ $^  \(no duplicate dependencies\) >> $@
	@echo Dependency Array: $$\+ $+ \(same order as in rule, duplicates printed\) >> $@
	@echo Dollar Sign: $$\$$ $$ >> $@
	@echo Gets the parent directory: $$\(\<D\) $(<D) >> $@
	@echo "Check out the file "$@""
