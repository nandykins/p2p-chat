#!/bin/bash
FILES="
src/Types.hs
src/Options.hs
src/Math.hs
src/Crypto.hs
src/Util.hs
src/P2P.hs
src/Queue.hs
src/Sending.hs
src/Messaging.hs
src/Serializing.hs
src/Parsing.hs
src/Processing.hs
"

MAINFILE="Main"

GHC_WARNS="
-Wall
-fno-warn-name-shadowing
-fno-warn-orphans
-fno-warn-missing-signatures
-fno-warn-type-defaults
-fno-warn-unused-do-bind
"

GHC_OPTS="${GHC_WARNS} -hidir bin/obj -odir bin/obj"

mkdir -p bin/obj
rm -f -- bin/obj/Main.*
hlint ${FILES} src/${MAINFILE}.hs
ghc ${GHC_OPTS} ${FILES} src/${MAINFILE}.hs -o bin/${MAINFILE} && bin/${MAINFILE} $@
