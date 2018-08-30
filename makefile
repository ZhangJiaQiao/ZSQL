zsql: zsql.lex.c zsql.tab.h zsql.tab.c main.c
	gcc -g -o $@ $^

zsql.lex.c: zsql.l zsql.tab.h
	flex -o zsql.lex.c zsql.l

zsql.tab.c zsql.tab.h: zsql.y
	bison -d --debug zsql.y

clean:
	rm -f zsql.tab.* zsql.lex.c zsql
