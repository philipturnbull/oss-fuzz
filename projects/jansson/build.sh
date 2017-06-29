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

autoreconf -i
./configure --prefix=`pwd`/build
make -j$(nproc) install

find `pwd` -name jansson.h

$CXX $CXXFLAGS $SRC/fuzzer.cc -Ibuild/include build/lib/libjansson.a -lFuzzingEngine -o $OUT/jansson_fuzzer

find $SRC -name '*.dict'
cp $SRC/*.options $OUT/
cp $SRC/*.dict $OUT/

mkdir -p corpus
find test -type f -name 'input' | while read in_file
do
  # Genreate unique name for each input...
  out_file=$(sha1sum "$in_file" | cut -c 1-32)
  cp "$in_file" "corpus/$out_file"
done
zip -j $OUT/jansson_fuzzer_seed_corpus.zip corpus/*

# build fuzzers
# e.g.
# $CXX $CXXFLAGS -std=c++11 -Iinclude \
#     /path/to/name_of_fuzzer.cc -o $OUT/name_of_fuzzer \
#     -lFuzzingEngine /path/to/library.a
