%{
#include <string.h>
#include "sp1.tab.h"
extern int curr_line;

typedef unsigned short ushort; 
typedef signed char    byte;
typedef unsigned char  ubyte;

%}
%option noyywrap
%%
[;].*             { } 
[-]?[0-9]+        { yylval.number = (byte)  atoi( yytext );     return NUMBER; }
[$][0-9]+         { yylval.addr   = (ubyte) atoi( &yytext[1] ); return MEMORY; } 
(?i:load)         { yylval.instr = LOAD;  return INSTR; } 
(?i:store)        { yylval.instr = STORE; return INSTR; } 
(?i:add)          { yylval.instr = ADD;   return INSTR; } 
(?i:jz)           { yylval.instr = JZ;    return INSTR; } 
(?i:jnz)          { yylval.instr = JNZ;   return INSTR; } 
(?i:sub)          { yylval.instr = SUB;   return INSTR; } 
(?i:hlt)          { yylval.instr = HLT;   return INSTR; }
(?i:jmp)          { yylval.instr = JMP;   return INSTR; }
(?i:jg)           { yylval.instr = JG;    return INSTR; }
(?i:jge)          { yylval.instr = JGE;   return INSTR; }
(?i:jl)           { yylval.instr = JL;    return INSTR; }
(?i:jle)          { yylval.instr = JLE;   return INSTR; }
(?i:and)          { yylval.instr = AND;   return INSTR; }
(?i:or)           { yylval.instr = OR;    return INSTR; }
(?i:not)          { yylval.instr = NOT;   return INSTR; }
(?i:mul)          { yylval.instr = MUL;   return INSTR; }
(?i:div)          { yylval.instr = DIV;   return INSTR; }
(?i:dec)          { yylval.instr = DEC;   return INSTR; }
(?i:inc)          { yylval.instr = INC;   return INSTR; }

['#'][a-zA-Z0-9]+ { strncpy( yylval.label, &yytext[1], 128 );    return LABEL; }
[\n]              { curr_line++;  return EOL; }
[ \t]             { }  
.                 { return yytext[0]; }


