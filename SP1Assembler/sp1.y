%{

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
typedef unsigned short ushort; 
typedef unsigned char ubyte; 
typedef signed char  byte;


typedef struct __label_t {
    char  label[128];
    int   addr;
    byte  done;
    int   line;
} label_t;


#define DCL_LABEL -1
#define JMP_LABEL  2

byte mem[256];
label_t labels[128];

int idx_label = 0;
int idx_mem   = 0;
int curr_line = 1;
int errors    = 0;

//char yylex();
//void yyerror( char * str );

int has_label( label_t * l, char label[128] ) {
    int i = 0;
    for( i = 0; i < idx_label; i++ ) {
        if( strcmp( label, labels[i].label ) == 0 ) {
            l->addr = labels[i].addr;
            l->done = labels[i].done;
            strcpy( l->label, labels[i].label );
            return i;
        }
    }   
    l->addr = -1;
    l->done = 0;
    strcpy( l->label, label );
    return -1;
}


void put_label( char label[128], byte instr ) {
    int idx  = 0;
    int addr_mem = 0;
    label_t l;
    idx = has_label( &l, label );
    if( instr != DCL_LABEL ) {
        mem[idx_mem++] = instr;
        if( l.addr == -1 ) {
            strncpy( labels[idx_label].label, label, 128 );
            labels[idx_label].addr = idx_mem;
            labels[idx_label].line = curr_line;
            labels[idx_label++].done = 0;
            
            idx_mem++;
        } else if( l.done == 1 ) {
            mem[idx_mem++] = labels[idx].addr;
        }
    } else {
        if( l.addr == -1 ) {
            strncpy( labels[idx_label].label, label, 128 );
            labels[idx_label].addr = idx_mem;
            labels[idx_label++].done = 1;
        } else {
            if( l.done == 1 ) {
                char str[256];
                sprintf(str, "label '%s' is already defined", label);
                yyerror( str );
                idx_mem++;
                return;
            }
            mem[labels[idx].addr] = idx_mem;
            labels[idx].addr = idx_mem;
            labels[idx].done = 1;                        
        }
    }                  
}

%}

%union  { 
    unsigned char instr;
    signed char   number;
    unsigned char addr;
    char label[128];
}

%token <number> NUMBER
%token <number> MEMORY
%token INSTR

%token <instr> LOAD    0
                    // 1 Load number
%token <instr> STORE   2
%token <instr> ADD     3
%token <instr> SUB     4 
%token <instr> MUL     5
%token <instr> DIV     6
%token <instr> INC     7
%token <instr> DEC     8
%token <instr> AND     9
%token <instr> OR     10
%token <instr> NOT    11
%token <instr> JMP    12
%token <instr> JZ     13
%token <instr> JNZ    14 

%token <instr> JG     15 
%token <instr> JL     16 
%token <instr> JGE    17 
%token <instr> JLE    18 


%token <instr> HLT    19



%token <label> LABEL

%token EOL

%start program

%%


program: 
            | program line
            ;
            
            
line:         EOL        
            | stm EOL 
            ;

stm:          INSTR            { if( $<instr>1 != HLT && $<instr>1 != INC && $<instr>1 != DEC && $<instr>1 != NOT )  yyerror("incomple instruction");
                                 else{ mem[idx_mem++] = $<instr>1; mem[idx_mem++] = 0; } }
                                 
            | INSTR NUMBER     { if( $<instr>1 != LOAD ) yyerror("syntax error, unexpected number (tip: you use '$' to acess memory)"); 
                                 else { mem[idx_mem++] = LOAD + 1; mem[idx_mem++] = $<number>2; }          
                               }
            | INSTR MEMORY     { if( $<instr>1 == JG || $<instr>1 == JL || $<instr>1 == JGE || $<instr>1 == JLE || $<instr>1 == JMP || $<instr>1 == JZ || $<instr>1 == JNZ || $<instr>1 == HLT || $<instr>1 == INC || $<instr>1 == DEC ) yyerror("syntax error, unexpected memory");
                                 else { mem[idx_mem++] = $<instr>1; mem[idx_mem++] = ($<addr>2 & 0xff); } }
                               
            | INSTR LABEL      { if( $<instr>1 != JG && $<instr>1 != JL && $<instr>1 != JGE && $<instr>1 != JLE && $<instr>1 != JZ && $<instr>1 != JNZ && $<instr>1 != JMP ) yyerror("syntax error, unexpected label"); 
                               else{  put_label($<label>2, $<instr>1 ); } }

            | LABEL ':'        { put_label( $<label>1, DCL_LABEL ); }      
            
            | LABEL            { yyerror("syntax error, (tip: use ':' after the label)");}             
            ;
%%
void yyerror( char * str ) {
    errors ++;
    printf("error: %s in line %d\n", str, (curr_line==0)?1:curr_line );
}
void printhelp() {
    printf("SP1 Assembler -- SP1A v1.0.0.\n");
    printf("CEFET-RJ, 2014. Pedro CS Lara.\n\n"); 
    printf("sp1a INPUT_FILE [OPTIONS]... \n\n");  
    printf("OPTIONS:\n");
    printf("-h\n\tPrint help.\n"); 
    printf("-o [file]\n\tOutput file.\n"); 
    exit( 0 );            
}
int main(int argc, char **argv) {
    extern FILE * yyin;
    int i = 0;
    char output[256] = { 0 };
    char input[256] = { 0 };
    int has_input = 0;
    int has_output = 0;
    
    if( argc == 1 )
        printhelp();
    
    for( i = 1; i < argc; i++ ) {
            if( strcmp( argv[i], "-h" ) == 0 ) {
                printhelp();     
            } else if( strcmp( argv[i], "-o" ) == 0 ) {
                if( i + 1 != argc && has_output == 0) {
                    strncpy( output, argv[i + 1], 256 );    
                    i++;
                    has_output = 1;
                } else {
                    fprintf( stderr, "error: specify a output file\n");
                    return 3;
                }
            } else {
                    if( has_input == 0 ) {
                        strncpy( input, argv[i], 256 );    
                        has_input = 1;   
                    }
            }
    }
    
    yyin = fopen( input, "r");
    if( yyin != 0 )
        yyparse();
    else {
        fprintf( stderr, "error: input file not found\n");
        return 1;
    }
            
    for( i = 0; i < idx_label; i++ ) {
        if( labels[i].done == 0 ) {
            fprintf( stderr, "error: reference to label '%s' not found in line %d\n", labels[i].label, labels[i].line );   
            errors++;     
        }
    }
    
    if( errors == 0 ) {
        if( has_output == 0 )
            strcpy( output, "a.sp1" );
        FILE * out = fopen( output, "wb" );
        if( out == NULL ) {
            fprintf(stderr, "Error to write in '%s'\n", output );
            return -1;
        }
        
        for( i = 0; i < idx_mem; i++ )
            fwrite( &mem[i], sizeof( byte ), 1, out );
        
        fclose( out );
    }   
}
