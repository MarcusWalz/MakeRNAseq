# This rule creates a file called Hello.
Hello : ;
	echo Hello > Hello
# This rule creates a file called World.
World : ;
	echo World > World
# This rule combines the files Hello and World.
# n.b. Hello and World are dependencies for the rule below.
HelloWorld : Hello World ;
	cat Hello World > HelloWorld
