load 0
store $1
load 1
store $3
load 10
#While:
    store $2
    load  $1
    add   $2
    store $1
    load  $2
    sub   $3
    jnz #While
load $1
hlt

