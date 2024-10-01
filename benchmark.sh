#!/bin/bash

project_euler_benchmarks_path=$(pwd)
cd ..
project_euler_path=$(pwd)/project_euler
cd $project_euler_benchmarks_path

problem() {
    problem_path=$1
    problem_name=$(basename $1)
    problem_file="$project_euler_benchmarks_path/$problem_name.md"

    cd $project_euler_benchmarks_path

    echo "## $problem_name" >$problem_file
    echo "" >>$problem_file

    for problem_solution_file in $problem_path/*; do
        if [[ -f $problem_solution_file ]]; then
            language
        fi
    done
}

language() {
    if [ ! -s $problem_solution_file ]; then
        return
    fi

    problem_solution_filename=$(basename $problem_solution_file)

    case $problem_solution_filename in
    [a-z]*.rb)
        run_ruby $problem_file
        ;;
    [a-z]*.c)
        run_clang $problem_file
        ;;
    [a-z]*.cr)
        run_crystal $problem_file
        ;;
    [a-z]*.go)
        run_golang $problem_file
        ;;
    [a-z]*.js)
        run_javascript $problem_file
        ;;
    [a-z]*.lua)
        run_lua $problem_file
        ;;
    [a-z]*.php)
        run_php $problem_file
        ;;
    [a-z]*.py)
        run_python $problem_file
        ;;
    [a-z]*.rs)
        run_rust $problem_file
        ;;
    [a-z]*.ex)
        run_elixir $problem_file
        ;;
    *.md | *.MD | *.txt) ;;
    *)
        echo "language not found: $problem_solution_filename"
        ;;
    esac
}

run_and_write_to_file() {
    local title=$1
    local command=$2
    local filename=$problem_file

    echo "## $title" >>$filename
    echo "" >>$filename

    time_output=$({ /usr/bin/time -v $command >/dev/null; } 2>&1)
    printf "\`\`\`\n" >>$filename
    echo "$time_output" >>$filename
    printf "\`\`\`\n\n" >>$filename
}

run_ruby() {
    if ! command -v ruby &>/dev/null; then return; fi

    run_and_write_to_file "Ruby" "ruby $problem_solution_file"
    run_and_write_to_file "Ruby (YJIT)" "ruby --yjit $problem_solution_file"
}

run_clang() {
    if ! command -v gcc &>/dev/null; then return; fi

    output_file="$problem_solution_file.bin"
    gcc -O3 -o $output_file $problem_solution_file

    if [[ ! -f $output_file ]]; then return; fi

    run_and_write_to_file "C" $output_file
    rm $output_file
}

run_crystal() {
    if ! command -v crystal &>/dev/null; then return; fi

    output_file="$problem_solution_file.bin"
    crystal build --release $problem_solution_file -o $output_file

    if [[ ! -f $output_file ]]; then return; fi

    run_and_write_to_file "Crystal" $output_file
    rm $output_file
}

run_golang() {
    if ! command -v go &>/dev/null; then return; fi

    output_file="$problem_solution_file.bin"
    CGO_ENABLED=0 GOOS=linux go build -o $output_file $problem_solution_file

    if [[ ! -f $output_file ]]; then return; fi

    run_and_write_to_file "Golang" $output_file
    rm $output_file
}

run_javascript() {
    if ! command -v node &>/dev/null; then return; fi

    run_and_write_to_file "Node.js" "node $problem_solution_file"
}

run_lua() {
    if ! command -v lua &>/dev/null; then return; fi

    run_and_write_to_file "Lua" "lua $problem_solution_file"
}

run_php() {
    if ! command -v php &>/dev/null; then return; fi

    run_and_write_to_file "PHP" "php $problem_solution_file"
}

run_python() {
    if ! command -v python &>/dev/null; then return; fi

    run_and_write_to_file "Python" "python $problem_solution_file"
}

run_rust() {
    if ! command -v rustc &>/dev/null; then return; fi

    output_file="$problem_solution_file.bin"
    rustc -C opt-level=3 -o $output_file $problem_solution_file

    if [[ ! -f $output_file ]]; then return; fi

    run_and_write_to_file "Rust" $output_file
    rm $output_file
}

run_elixir() {
    if ! command -v elixirc &>/dev/null; then return; fi

    elixirc -o $problem_path $problem_solution_file
    run_and_write_to_file "Elixir" "elixir -pa $problem_path -e Main.run"
    rm $problem_path/*.beam
}

case $1 in
[0-9]*)
    problem=$1
    problem_path="$project_euler_path/$problem"

    if [[ -d $problem_path ]]; then
        problem $problem_path
    fi
    ;;
all)
    for problem_path in $project_euler_path/*; do
        if [[ -d $problem_path ]]; then
            problem $problem_path
        fi
    done
    ;;
*)
    echo "tutorial"
    ;;
esac
