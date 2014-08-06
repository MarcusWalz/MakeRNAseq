# Let's see what each macro does.
# To run all the rules run:
# $ make test.txt

# match with wildcard
%.txt : dependency1 dependency2 dependency1;
	echo $$\@ $@ \<-- target name               >  $@
	echo $$\? $? \<-- younger dependencies      >> $@
	echo $$\* $* \<-- suffix match, i.e. prefix >> $@
	echo $$\^ $^ \<-- dependency array \(no duplicates\) >> $@
	echo $$\+ $+ \<-- dependency array \(with duplicates\) >> $@
	echo $$\$$ $$ \<-- prints the money sign  >> $@
	@echo "Check out the file "$@""


