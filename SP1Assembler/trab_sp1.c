#include <stdio.h>
#include <string.h>


#define loadMem 0
#define loadValue 1
#define store 2
#define add 3
#define sub 4
#define mul 5
#define div 6
#define inc 7
#define dec 8
#define and 9
#define or 10
#define not 11
#define jmp 12
#define jz 13
#define jnz 14
#define jg 15
#define jl 16
#define jge 17
#define jle 18
#define  hlt 19


typedef unsigned char byte;
typedef struct {
	byte opcode;
	byte operand;
}instrucao;


int main(int argc, char **argv){
	int pc = 0, i = 0, acc = 0;
	int stat = 0;
	
	if(argc < 2){
		printf("Nenhum arquivo foi passado!\n");
		return 1;
	}
	
	FILE * entrada = fopen(argv[1], "rb");
	
	if(entrada == NULL){
		printf("Erro ao abrir o arquivo %s\n", argv[1]);
		return 1;
	}
	
	instrucao instruction[256];
	int memoria[256];
	unsigned short buffer;
	
	while(fread(&buffer, sizeof(buffer), 1, entrada) != 0){ // eof
		instruction[i].opcode = buffer & 0xFF;
		instruction[i].operand = (buffer >> 8) & 0xFF;
		i++;
	}
	byte opcode=0;
	fclose(entrada);
	while(instruction[pc].opcode != hlt){ // enquanto for diferente do hlt
		byte opcode = instruction[pc].opcode;
		byte operand = instruction[pc].operand;
		
		switch(opcode){
			case loadMem: 
				acc = memoria[operand];
				if((acc & 0x100)!=0){
					stat = 1;
					// carry
				}
				else if(acc == 0){
					stat = 2;
					// zero acc
				}
				else{
					stat = 3;
					// nao utilizado
				}
				
				pc++;
				break;
			case loadValue:
				acc = operand;
				if((acc & 0x100)!=0){
					stat = 1;
					// carry
				}
				else if(acc == 0){
					stat = 2;
					// zero acc
				}
				else{
					stat = 3;
					// nao utilizado
				}
				pc++;
				break;
			case store:
				memoria[operand] = acc;
				pc++;
				break;
			case add:
				acc += memoria[operand];
				if(((acc - memoria[operand]) & 0x80) != (memoria[operand] & 0x80) &&  ((acc + memoria[operand]) & 0x80 )!= (acc & 0x80)) { // verifica se os operadores deram overflow e se o resultado da operação deu overflow
					stat = 0;
					// overflow
				}
				else if((acc & 0x100)!=0){
					stat = 1;
					// carry
				}
				else if(acc == 0){
					stat = 2;
				}
				else{
					stat = 3;
				}
				
				pc++;
				break;
				
			case sub: 
				acc -= memoria[operand];
				if(((acc + memoria[operand]) & 0x80) != (memoria[operand] & 0x80) &&  ((acc + memoria[operand]) & 0x80 )!= (acc & 0x80)) {
					stat = 0;
					// overflow
				}
				else if((acc & 0x100)!=0){
					stat = 1;
					// carry
				}
				else if(acc == 0){
					stat = 2;
				}
				else{
					stat = 3;
				}
				
				pc++;
				break;
			case mul: 
				acc = acc * operand;
				if(((acc / memoria[operand]) & 0x80) != (memoria[operand] & 0x80) &&  ((acc + memoria[operand]) & 0x80 )!= (acc & 0x80)) {
					stat = 0;
					// overflow
				}
				else if((acc & 0x100)!=0){
					stat = 1;
					// carry
				}
				else if(acc == 0){
					stat = 2;
				}
				else{
					stat = 3;
				}
				pc++;
				break;
			case div:
				acc = acc / operand;
				if(((acc * memoria[operand]) & 0x80) != (memoria[operand] & 0x80) &&  ((acc + memoria[operand]) & 0x80 )!= (acc & 0x80)) { // 0x80 == 128
					stat = 0;
					// overflow
				}
				else if((acc & 0x100)!=0){
					stat = 1;
					// carry
				}
				else if(acc == 0){
					stat = 2;
				}
				else{
					stat = 3;
				}
				
				pc++;
				break;
			case inc:
				acc ++;
				if(((acc - 1) & 0x80) != (memoria[operand] & 0x80) &&  ((acc + memoria[operand]) & 0x80 )!= (acc & 0x80)) {
					stat = 0;
					// overflow
				}
				else if((acc & 0x100)!=0){
					stat = 1;
					// carry
				}
				else if(acc == 0){
					stat = 2;
				}
				else{
					stat = 3;
				}
				
				pc++;
				break;
			case dec: 
				acc--;
				if(((acc + 1) & 0x80) != (memoria[operand] & 0x80) &&  ((acc + memoria[operand]) & 0x80 )!= (acc & 0x80)) {
					stat = 0;
					// overflow
				}
				 if((acc & 0x100)!=0){
					stat = 1;
					// carry
				}
				else if(acc == 0){
					stat = 2;
					// zero acc
				}
				else{
					stat = 3;
					// nao utilizado
				}
				
				pc++;
				break;
			case and:
				acc &= memoria[operand];
				pc++;
				break;
			case or:
				acc |= memoria[operand];
				pc++;
				break;
			case not:
				acc = !acc;
				pc++;
				break;
			case jmp: 
				pc = operand/2;
				pc++;
				break;
			case jz:
				if(acc == 0){
					pc = operand/2;
					continue;
				}else{
					pc++;
				}
				break;
			case jnz:
				if(acc != 0){
					pc = operand/2;
					continue;
				}else{
					pc++;
				}
				break;
			case jg:
				if(acc>0){
					pc = operand/2;
					continue;
				}else{
					pc++;
				}
				break;
			case jl:
				if(acc<0){
					pc = operand/2;
					continue;
				}else{
					pc++;
				}
				break;
			case jge:

				if(acc>=0){

					pc = operand/2;
					continue;
				}else{
					pc++;
				}
				break;			
			case jle:
				if(acc<=0){
					pc = operand/2;
					continue;
				}else{
					pc++;
				}
				break;
			case hlt:
				return 0;
				break;
			
		}
		printf("pc: %d, opcode: %d, operand: %d\n", pc, opcode, operand);

	}
	printf("acc = %d \n", acc);
	printf("Memoria: ");
	for(i=0;i<5;i++){
		printf("%d ", memoria[i]);
		
	}

	printf("\nStat = %d \n", stat);
	
	
}


// funciona se estiver sem label for no arquivo binario. Tem que dar gcc no programa toda vez que monta 
