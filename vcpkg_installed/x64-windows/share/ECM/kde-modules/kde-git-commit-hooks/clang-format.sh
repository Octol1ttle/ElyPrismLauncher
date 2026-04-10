#!/usr/bin/env bash

# Based on okular/hooks/pre-commit, credits go to Albert Astals Cid

clang_format_major_version=@KDE_CLANG_FORMAT_MAJOR_VERSION@
if [[ ${clang_format_major_version:-1} -ge 14 ]]; then
    readonly output=$(git clang-format --staged --extensions 'cpp,h,hpp,c' -v --diff)
else
    readonly output=$(git clang-format --extensions 'cpp,h,hpp,c' -v --diff)
fi

if [[ ! -f .clang-format ]]; then
    if [[ @HAS_CLANG_FORMAT_COMMAND_INCLUDED@ = TRUE ]]; then
        echo "ERROR: no .clang-format file found in repository root, abort format"
        echo "       run cmake for this repository to generate it"
    else
        echo "ERROR: no .clang-format file found in repository root, abort format"
        echo "Make sure the KDEClangFormat CMake module is included, which will copy the KDE .clang-format file during the CMake configuration."
        echo "Alternatively you can manually copy a .clang-format file to the repository root directory."
    fi
    exit 1
fi
if [[ "$output" == *"no modified files to format"* ]]; then exit 0; fi
if [[ "$output" == *"clang-format did not modify any files"* ]]; then exit 0; fi

echo "ERROR: You have unformatted changes, please format your files. You can do this using the following commands:"
if [[ ${clang_format_major_version:-1} -ge 14 ]]; then
    echo "       git clang-format --staged --extensions 'cpp,h,hpp,c' # format the changed parts"
    echo "       git clang-format --staged --extensions 'cpp,h,hpp,c' --diff # preview the changes done by the formatter"
else
    echo "       git clang-format --extensions 'cpp,h,hpp,c' --force # format the changed parts"
    echo "       git clang-format --extensions 'cpp,h,hpp,c' --diff # preview the changes done by the formatter"
fi
exit 1
