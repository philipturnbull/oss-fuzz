set -ex

if [ "$#" -ne 1 ]; then
  echo "usage: $0 <language>"
  exit 1
fi

lang="$1"
# XXX TEMP: only_ascii needed until OOB read in lexer is fixed
infra/helper.py run_fuzzer tree-sitter "${lang}_fuzzer" "-dict=/out/${lang}.dict" -artifact_prefix="${lang}_" -max_len=128 -only_ascii=1
