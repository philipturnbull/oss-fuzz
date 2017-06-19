#!/bin/bash -eu
# Copyright 2016 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
################################################################################

set -x
./script/configure

(cd ./externals/utf8proc; git reset --hard 40e605959eb5cb90b2587fa88e3b661558fbc55a) # XXX TEMP: update utf8proc to include fix for OOB read
make -f project.Makefile

languages=(go javascript ruby python c cpp typescript)

for lang in ${languages[@]}; do
  lang_dir="tree-sitter-$lang"
  git clone --depth 1 "https://github.com/tree-sitter/$lang_dir" "$lang_dir"


  # The following assumes each language is implemented as src/parser.c plus an
  # optional scanner in src/scanner.c/cc
  objects=()

  lang_scanner="${lang_dir}/src/scanner"
  if [ -e "${lang_scanner}.cc" ]; then
    $CCC $CXXFLAGS -g -O1 "-I${lang_dir}/src" -c "${lang_scanner}.cc" -o "${lang_scanner}.o"
    objects+=("${lang_scanner}.o")
  elif [ -e "${lang_scanner}.c" ]; then
    # If it's plain C, compile it separately
    $CC $CFLAGS -g -O1 "-I${lang_dir}/src" -c "${lang_scanner}.c" -o "${lang_scanner}.o"
    objects+=("${lang_scanner}.o")
  fi


  $CC $CFLAGS -g -O1 "-I${lang_dir}/src" "${lang_dir}/src/parser.c" -c -o "${lang_dir}/src/parser.o"
  objects+=("${lang_dir}/src/parser.o")


  $CXX $CXXFLAGS -std=c++11 -Iinclude -D TSLANG="tree_sitter_$lang" "../fuzzer.cc" "${objects[@]}" ./out/Release/obj.target/libruntime.a -lFuzzingEngine -o "$OUT/${lang}_fuzzer"
  python $SRC/gen-dict.py "${lang_dir}/src/grammar.json" > "$OUT/$lang.dict"
done
