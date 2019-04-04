# Programa que calcula o fatorial de um numero dado
# Mateus Ferreira Gomes	09/03/2019
# ICMC - USP

.data

	.align 0			
	quanto: .asciiz "Fatorial de quanto?\n"

.text
	
	
	li $v0, 4			# Carrega a funcao de printar uma string
	la $a0, quanto		# Posiciona no registrador
	syscall			# Printa
	
	li $v0, 5			# Carrega a funcao de ler um int
	syscall			# Le o int
	
	move $a0, $v0		# Move o numero lido (ate onde fazer o fatorial) para o registrador $t0
	jal fatorial	# Chama o fatorial, colocando o $ra na proxima instrucao
	
	move $t1, $v0	# Colocando o resultado do fatorial em $t1 para printar
	
	li $v0, 1		# Carrega a funcao de printar o numero resultado do fatorial
	move $a0, $t1	# Coloca o resultado em $a0
	syscall		# Printa o resultado
		
	li $v0, 10
	syscall	# Finaliza o programa
	
	fatorial:
		
		addi $sp, $sp, -8 # Alocando espaco na pilha para armazenar o numero digitado
		sw $a0, 4($sp)    # e o conteudo de $ra para quando finalizar a funcao
		sw $ra, 0($sp)    # a0 esta' 4 posicoes distantes de $sp e $ra a 0
		addi $v0, $zero, 1	# Armazenando 1 em v0 para realizar o calculo de multiplicacao
		
		
		loop:

			mul $v0, $v0, $a0		# $v0 = $v0*$a0
			addi $a0, $a0, -1		# $a0--
			beq $a0, $zero, fim_loop	# Enquanto $a0 nao chegar a zero
			j loop				# realiza o loop
	
		fim_loop:
			
			lw $a0, 4($sp)			# Carregando de volta os valores nos
			lw $ra, 0($sp)			# registradores para retornar a posicao
			addi $sp, $sp, 8		# salva em $ra
			jr $ra
			
			
