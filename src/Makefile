all:
	flex mini_l.lex
	bison -v -d --file-prefix=y mini_l.y
	gcc -o parser lex.yy.c y.tab.c -lfl

clean:
	rm -f parser lex.yy.c y.tab.c y.tab.h y.output