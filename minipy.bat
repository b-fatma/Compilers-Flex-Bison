flex projet.l
bison -d projet.y
bison -v projet.y
gcc lex.yy.c projet.tab.c -lfl -ly -o minipy
minipy <test.txt