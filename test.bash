#!/bin/bash

for f in test/test*.bash; do
  echo "$f";
  bash ${f}
done
