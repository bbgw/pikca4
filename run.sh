#!/usr/bin/env bash

file=${1:-../ApplEdible.g4}

runp () {
    pushd py
    pygrun \
     ANTLRv4 grammarSpec -tree "${file}"
    popd
}

runj () {
    pushd java
    java -Xmx500M -cp "/usr/local/lib/antlr-4.9.2-complete.jar:$CLASSPATH" org.antlr.v4.gui.TestRig \
     ANTLRv4 grammarSpec -tree "${file}"
    popd
}

runj $@
