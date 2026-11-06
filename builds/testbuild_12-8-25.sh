#!/bin/sh
printf '\033c\033]0;%s\a' pmd-the-fate-of-many-and-the-fate-of-one
base_path="$(dirname "$(realpath "$0")")"
"$base_path/testbuild_12-8-25.x86_64" "$@"
