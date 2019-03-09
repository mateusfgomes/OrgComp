# Programa que calcula o fatorial de um numero dado
# Mateus Ferreira Gomes	09/03/2019
# ICMC - USP

.data

	.align 0			
	quanto: .asciiz "Fatorial de quanto?\n"

.text
	
	
	li $v0, 4			#Carrega a funcao de printar uma string
	la $a0, quanto		#Posiciona no registrador
	syscall			#Printa
	
	li $v0, 5			#Carrega a funcao de ler um int
	syscall			#Le o int
	
	move $t0, $v0		#Move o numero lido (ate onde fazer o fatorial) para o registrador $t0
	addi $t0, $t0, 1		#Soma 1 para realizar a multiplicacao ate o numero correto
	
	li $t2, 1			#Guarda "1" no registrador que contará para fazer a multiplicacao  ("contador")
	li $t1, 1			#Guarda "1" no registrador que guardará o resultado das multiplicacoes
	
	loop:

		mul $t1, $t1, $t2		# $t1 = $t1*$t2
		addi $t2, $t2, 1		# $t2++
		beq $t2, $t0, fim_loop	#enquanto $t2 nao chegar no fatorial desejado (salvo em $t0)
		j loop				
	
	fim_loop:
		
		li $v0, 1		#carrega a funcao de printar o numero resultado do fatorial
		move $a0, $t1	#coloca o resultado em $a0
		syscall		#printa o resultado
		
		li $v0, 10
		syscall	#finaliza o programa
