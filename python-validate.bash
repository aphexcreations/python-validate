#!/bin/bash

##
## Runs PEP8 and PyLint Validations
##

THIS_DIR=$(dirname ${0})
PYLINT_RC=$(readlink -f "${THIS_DIR}/pylintrc")

if [ -z "${1}" ]; then
    echo "A PATH ARGUMENT IS REQUIRED."
    echo "IT CAN EITHER BE A FILE OR DIRECTORY PATH."
    exit 1
elif [[ "$1" = /* ]]; then
    ## Absolute path
    start_point="${1}"
else
    ## Relative path
    start_point="$(pwd)/${1}"
fi;

if [ -d "${start_point}" ]; then
    ##
    ## Is a Directory
    ##

    ## Change to dir
    cd ${start_point}

    ##
    ## Get python files
    ##
    files=$(
        find . \
            -type f -and \
            -iname "*.py" -and \
            \( \
                -not \
                \( \
                    -iwholename "*/tests/*" -or \
                    -iwholename "*/test/*" -or \
                    -iwholename "*/.git/*" -or \
                    -iwholename "*/migrations/*" -or \
                    -iname "test_*.py" \
                \) \
            \)
    )
elif [ -f "${start_point}" ]; then
    ##
    ## Is a file
    ##

    ## Change to dir
    cd $(dirname ${start_point})
    files="${start_point}"
else
    ##
    ## Something else
    ##
    echo "PATH ARGUMENT IS NOT A VALID DIRECTORY OR FILE PATH."
    exit 1
fi;

for file in ${files}; do
    pep_res=$(pep8 "${file}" 2>&1)
    pep_status=${?}
    if [ ${pep_status} -ne 0 ]; then
        echo
        echo "CODE DOES NOT PASS PEP8. FILE:"
        echo
        echo "> ${file}"
        echo
        echo -e "${pep_res}"
        echo
        exit 1
    fi
    pylint_res=$(
         pylint --rcfile="${PYLINT_RC}" "${file}" 2>&1
    )
    pylint_status=${?}
    if [ ${pylint_status} -ne 0 ]; then
        echo
        echo "CODE DOES NOT PASS PYLINT. FILE:"
        echo
        echo "> ${file}"
        echo
        echo -e "${pylint_res}"
        echo
        exit 1
    fi
done;

exit 0

