.DEFAULT_GOAL := all

all : py ja _compile
.PHONY: py ja all pikchr

antlr4 := java -Xmx500M -cp "/usr/local/lib/antlr-4.9.2-complete.jar:$CLASSPATH" org.antlr.v4.Tool
grun := java -Xmx500M -cp "/usr/local/lib/antlr-4.9.2-complete.jar:$CLASSPATH" org.antlr.v4.gui.TestRig
antlr_formatter := java -jar /usr/local/lib/antlr4-formatter-standalone-1.2.1.jar --input

filedir := ./grammars-v4/antlr/antlr4/
filename := ANTLRv4Parser.g4
out_java := ./java
out_python := ./py

options := -visitor
version := $(shell git log -n 1 --pretty=format:%H -- $(filename) | cut -c 1-8)

py:
	@echo ">>>"
	$(antlr4) $(options) -Dlanguage=Python3 $(out_python)/ANTLRv4Parser.g4 $(out_python)/ANTLRv4Lexer.g4
	@echo "<<<"

# s.t. being able to use TestRig
ja:
	@echo ">>>"
	$(antlr4) $(options) -Dlanguage=Java $(out_java)/ANTLRv4Parser.g4 $(out_java)/ANTLRv4Lexer.g4
	@echo "<<<"

_compile: ja
	javac $(out_java)/*.java

clean:
	@echo "Cleaning up builds"
	rm $(out_python)/*.interp		\
	   $(out_python)/*.tokens		\
	   $(out_python)/ANTLRv4*.py	\
	   $(out_java)/*.interp			\
	   $(out_java)/*.tokens			\
	   $(out_java)/ANTLRv4*.java 	\
	   $(out_java)/*.class
	@echo "Done"
