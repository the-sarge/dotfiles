# shell functions are collected here and sourced in .bashrc and .zshrc

function bbman()
{
cmd=$(tr "[:lower:]" "[:upper:]" <<< "$1")
man $1 | col -b | bbedit --view-top --clean -t "$cmd MANUAL"
}

