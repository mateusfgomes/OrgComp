jmp main

Letra: var #1

pacman: string "." 			; char que desenha o pacman
fantasma: string "@"		; char que desenha o inimigo 
fruta: string  "*"	 	; char que desenha a comida
score : string "Score: " 	; pontuação

pos_pacman: var #490 		; posição do pacman
pontos: var #1				; pontos

delay1: var #1				; Variaveis para o delay (quanto maior, mais lento)
delay2: var #1

Rand : var #30				; tabela de números aleatórios	
	static Rand + #0, #1
	static Rand + #1, #2
	static Rand + #2, #2
	static Rand + #3, #1
	static Rand + #4, #1
	static Rand + #5, #2
	static Rand + #6, #1
	static Rand + #7, #2
	static Rand + #8, #1
	static Rand + #9, #2
	static Rand + #10, #2
	static Rand + #11, #1
	static Rand + #12, #1
	static Rand + #13, #2
	static Rand + #14, #2
	static Rand + #15, #1
	static Rand + #16, #2
	static Rand + #17, #2
	static Rand + #18, #1
	static Rand + #19, #2
	static Rand + #20, #1
	static Rand + #20, #2
	static Rand + #21, #1
	static Rand + #22, #2
	static Rand + #23, #2
	static Rand + #24, #1
	static Rand + #25, #1
	static Rand + #26, #1
	static Rand + #27, #2
	static Rand + #28, #2
	static Rand + #29, #2


incr_rand: var #1			; Variavel para incrementar os numeros randomicos
incRand: var #2

main:
	
	call ApagaTela
	loadn r1, #telaInicioLinha0		; Imprime a tela inicial do jogo na cor marrom;
	loadn r2, #1536
	call ImprimeTela
	
	loadn r1, #telaBarrasLinha0		; Imprime a tela inicial do jogo na cor prata;
	loadn r2, #1280
	call ImprimetelaGameOver
	
	jmp Inicio				; Loop do inicio do jogo;
	
	
	Inicio:
		
		call tecla_inicia		; leitura da tecla espaço para início do jogo
		
		loadn r0, #' '			; início do jogo
		load r1, Letra
		cmp r0, r1
		jne Inicio
	
	
	valores_iniciais:			; valores iniciais das variáveis de pontuação
		
		push r2
		loadn r2, #0
		store pontos, r2
		pop r2
		
		loadn r0, #300
		store delay1, r0
		
		loadn r0, #350
		store delay2, r0
		

	inicializacao:					; preparação para o início do jogo		
		
		call ApagaTela				; Imprime a tela inicial do jogo
		loadn r1, #telaPadraoLinha0
		loadn r2, #768
		call ImprimeTela
		
		loadn r1, #telaChaoLinha0	; Endereco da primeira linha do cenario
		loadn r2, #768
		call ImprimetelaGameOver   	; Rotina que imprime o cenario
		
		push r2						; zera o placar
		loadn r2, #0
		store pontos, r2
		pop r2
		
		loadn r0, #31				; Imprime a tela inicial
		loadn r1, #score		
		loadn r2, #0
		call ImprimeStr
		
		loadn r7, #' '			; Parametro para saber se a tecla certa foi pressionada
		loadn r6, #490			; posição do pacman que só se movimenta por pulos(verticalmente)
		loadn r3, #510			; posição da fruta
		loadn r2, #519			; posição do fantasma
		load r0, fruta			; desenho da fruta 
		load r4, pacman			; desenho do pacman
		loadn r1, #0
		;load r1, fantasma		; desenho do fantasma
		loadn r5, #0			; Ciclo do pulo (0 = chao, entre 1 e 3 = sobe, maior que 3 = desce)
		
		
		jmp jogo
	
	jogo:						; loop do jogo
		
		call colisaoFantasma	; checa a colisão entre o pacman fantasma
		
		call colisaoFruta		; checa a colisão entre o pacman e a fruta
		
		call atualiza_pontos	; atualização do número de pontos
		
		
		call ApagaPersonagem 	; Desenha o personagem na tela
		nop
		nop
		nop
		call PrintaPersonagem
		nop
		nop
		nop
		call AtObstaculo ; Move o obstaculo
		nop
		nop
		nop
		nop
		nop
		;call AtPosicaoFruta		; move a fruta
		push r2
		
		loadn r2, #1
		outchar r7, r3
		
		nop
		nop
		nop
		nop
		
		sub r3, r3, r2
		
		loadn r2, #480
		
		nop
		nop
		nop
		nop
		
		cmp r2, r3
			ceq para_zero
			
		nop
		nop
		nop
		nop
			
		loadn r2, #440
		
		nop
		nop
		nop
		nop
		
		cmp r2, r3
			ceq para_zero
			
		pop r2
		
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		
		load r0, fruta
		
		push r2
		
		nop
		nop
		nop
		nop
		
		loadn r2, #0
		
		nop
		nop
		nop
		nop
		nop
		
		cmp r1, r2
			ceq desenha_fruta
			
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		
		loadn r2, #1
		
		nop
		nop
		nop
		nop
		
		cmp r1, r2
			ceq altera_r3 			; desenho da fruta
			
		nop
		nop
		nop
		nop
		nop
		nop
		
		pop r2
		
		push r1
		
		load r1, fantasma
		
		outchar r1, r2 			; desenho do fantasma
		push r3
		load r3, fantasma
		nop
		nop
		cmp r1, r3
			ceq printa_fantasma
		pop r3
		
		pop r1
			
		call DelayChecaPulo		; Atrasa a execucao e le uma tecla do teclado
		nop
		nop
		nop
		call AtPosicaoBoneco	; Atualiza a posicao do boneco de acordo com a situacao
			
		push r3 				; Checa se pode pular (personagem no chao)
		loadn r3, #0 
		cmp r5, r3
			ceq ChecaPulo 		; Checa se o jogador pressionou tecla para o personagem pular
		pop r3
			
		jmp jogo 				; Volta para o inicio do loop
		
	desenha_fruta:
		outchar r0, r3
		rts
		
	altera_r3:
		loadn r3, #441
		loadn r1, #0
		rts
		
	para_zero:
		loadn r3, #510
		loadn r1, #0
		rts

	IncPontos:	; Funcao que  incrementa os pontos do jogador

		push r1
		push r2
		push r3
	
		load r2, pontos
	
		inc r2
	
		;load r1, delay1
	
		;loadn r3, #23		;guarda 23 em r3
	
		;sub r1, r1, r3		;subtrai r1 por r3
		;store delay1, r1	;guarda novo delay
	
		store pontos, r2
	
		pop r3
		pop r2
		pop r1
		rts
	
	atualiza_pontos:		; Funcao que atualiza os pontos do jogador
	
		push r1
		push r5
		push r6
	
		loadn r1, #490		; Caso o obstaculo tenha passado pela posicao do jogador, incrementa a pontuacao
		cmp r2, r1
			ceq IncPontos
		
		loadn r1, #410		; Idem, porem para o caso do obstaculo estar em  outra linha
		cmp r2, r1
			ceq IncPontos
	
		loadn r1, #370		; Idem, porem para o caso do obstaculo estar em  outra linha
		cmp r2, r1
			ceq IncPontos
		
		
		load r5, pontos
		
		loadn r6, #38
	
		call PrintaNumero	; Imprime a pontuacao na tela
	
		pop r6
		pop r5
		pop r1
		rts
			
	GameOver:						; Funcao de game over
	
		call ApagaTela				; Imprime a tela do fim do jogo
		loadn r1, #telaGameOverLinha0
		loadn r2, #256
		call ImprimeTela
		
		load r5, pontos
		loadn r6, #865	
		call PrintaNumero
		call tecla_inicia
		
		loadn r0, #'n'
		load r1, Letra
		cmp r0, r1
		jeq fim_do_jogo
		
		loadn r0, #'s' 				; Espera que a tecla 's' seja digitada para reiniciar o jogo
		cmp r0, r1
		jne GameOver
		
		call ApagaTela
	
		pop r2
		pop r1
		pop r0

		pop r0
		jmp inicializacao
		
	printa_fruta: 					; imprime o fantasma na tela
		loadn r1, #40
		sub r3, r3, r1
		load r0, fruta
		nop
		nop
		nop
		nop
		nop
		
		outchar r0, r3
		;load r1, fruta
		add r3, r3, r1
		rts
		
	printa_fantasma: 					; imprime o fantasma na tela
		loadn r3, #40
		sub r2, r2, r3
		load r1, fantasma
		nop
		nop
		nop
		nop
		nop
		
		outchar r1, r2
		;load r1, obstaculo_cactus_baixo
		add r2, r2, r3
		rts
		
		
	fim_do_jogo:					; fim do jogo
		call ApagaTela
		halt


; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; 			FUNCOES DE SUBROTINA
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Imprimestr:							; rotina de impresao de mensagens

	push r0							; posicao da tela que o primeiro caractere da mensagem sera' impresso
	push r1							; endereco onde comeca a mensagem
	push r2							; cor da mensagem
	
	loadn r3, #'\0'					; criterio de parada (\0)


ImprimestrLoop:						; loop para impressao de mensagens
	loadi r4, r1
	cmp r4, r3
	jeq ImprimestrSai
	add r4, r2, r4
	nop
	nop
	nop
	nop
	nop
	
	outchar r4, r0
	inc r0
	inc r1
	jmp ImprimestrLoop


ImprimestrSai:						; resgata os valores dos registradores utilizados na subrotina e sai da impressao
	pop r4	 
	pop r3
	pop r2
	pop r1
	pop r0
	rts


tecla_inicia:							; espera que uma tecla seja digitada e salva na variavel global Letra
	push r0
	push r1
	loadn r1, #255

   tecla_loop:
		inchar r0					; le o teclado, se nada for digitado = 255
		cmp r0, r1					;compara r0 com 255
		jeq tecla_loop			; lica lendo ate que o jogador digite uma tecla valida

	store Letra, r0					; salva a tecla na variavel global "Letra"

	pop r1
	pop r0
	rts


ApagaTela:							; Apaga as 1200 posicoes da tela
	push r0
	push r1
	
	loadn r0, #1200
	loadn r1, #' '
	
	   ApagaTela_Loop:
		dec r0
		nop
		nop
		nop
		
		outchar r1, r0
		jnz ApagaTela_Loop
 
	pop r1
	pop r0
	rts	


ImprimeTela: 						;  Rotina de impresao do cenario na tela
	
	push r0
	push r1
	push r2
	push r3
	push r4
	push r5

	loadn r0, #0  					; posicao inicial
	loadn r3, #40  					; incremento da posicao da tela
	loadn r4, #41  					; incremento do ponteiro das linhas da tela
	loadn r5, #1200 				; limite da tela
	
   ImprimeTela_Loop:
		call ImprimeStr
		add r0, r0, r3  			; incrementa posicao para a segunda linha na tela
		add r1, r1, r4  			; incrementa o ponteiro para o comeco da proxima linha na memoria
		cmp r0, r5				; compara r0 com 1200
		jne ImprimeTela_Loop			; enquanto r0 < 1200

	pop r5						; Resgata os valores dos registradores
	pop r4
	pop r3
	pop r2
	pop r1
	pop r0
	rts
	

ImprimetelaGameOver: 					;  Rotina de Impresao de Cenario na Tela Inteira

	; r1 = endereco onde comeca a primeira linha do Cenario
	; r2 = cor do Cenario para ser impresso

	push r0
	push r1
	push r2
	push r3
	push r4
	push r5
	push r6

	loadn R0, #0  					; Posicao inicial
	loadn R3, #40  					; Incremento da posicao da tela
	loadn R4, #41  					; Incremento do ponteiro das linhas da tela
	loadn R5, #1200 				; Limite da tela
	loadn R6, #telaInicioLinha0			; Endereco da primeira linha do cenario
	
   ImprimetelaGameOver_Loop:
		call ImprimeStr2
		add r0, r0, r3  			; Incrementa posicao para a segunda linha na tela
		add r1, r1, r4  			; Incrementa o ponteiro para o comeco da proxima linha na memoria
		add r6, r6, r4  			; Incrementa o ponteiro para o comeco da proxima linha na memoria
		cmp r0, r5				; Compara r0 com 1200
		jne ImprimetelaGameOver_Loop		; Enquanto r0 < 1200
		
	pop r6						; Resgata os valores dos registradores
	pop r5
	pop r4
	pop r3
	pop r2
	pop r1
	pop r0
	rts
		

ImprimeStr2:							; Rotina de Impresao de Mensagens: (ate encontrar '/0')

	push r0							; Posicao da tela que o primeiro caractere da mensagem sera' impresso
	push r1							; Endereco onde comeca a mensagem
	push r2							; Cor da mensagem
	push r3
	push r4
	push r5
	push r6	
	
	loadn r3, #'\0'					; Criterio de parada
	loadn r5, #' '					; Espaco em Branco

   ImprimeStr2_Loop:	
		loadi r4, r1
		cmp r4, r3					; If (Char == \0) sai da rotina
		jeq ImprimeStr2_Sai
		cmp r4, r5					; If (Char == ' ') pula  do espaco para nao apagar outros caracteres
		jeq ImprimeStr2_Skip
		add r4, r2, r4				; Soma a Cor
		nop
		nop
		nop
		nop
		nop
		
		outchar r4, r0				; Imprime o caractere na tela
   		storei r6, r4
   ImprimeStr2_Skip:
		inc r0						; Incrementa a posicao na tela
		inc r1						; Incrementa o ponteiro da String
		inc r6
		jmp ImprimeStr2_Loop
	
   ImprimeStr2_Sai:	
	pop r6							; Resgata os valores dos registradores
	pop r5
	pop r4
	pop r3
	pop r2
	pop r1
	pop r0
	rts

	
ImprimeStr:							; Rotina de Impresao de Mensagens: (ate encontrar '/0')
	push r0							; Posicao da tela que o primeiro caractere da mensagem sera' impresso
	push r1							; Endereco onde comeca a mensagem
	push r2							; Cor da mensagem
	push r3
	push r4
	
	loadn r3, #'\0'					; Criterio de parada

   ImprimeStr_Loop:	
		loadi r4, r1
		cmp r4, r3					; If (Char == \0) sai da rotina
		jeq ImprimeStr_Sai
		add r4, r2, r4				; Soma a Cor
		nop
		nop
		nop
		nop
		nop
		
		outchar r4, r0				; Imprime o caractere na tela
		inc r0						; Incrementa a posicao na tela
		inc r1						; Incrementa o ponteiro da String
		jmp ImprimeStr_Loop
	
   ImprimeStr_Sai:	
	pop r4							; Resgata os valores dos registradores
	pop r3
	pop r2
	pop r1
	pop r0
	rts


AtPosicaoBoneco:					; Funcao que atualiza a posicao do boneco na tela

	push r0
	
	;if r5 = 1						; Caso o ciclo do pulo esteja em 1, 2, 3 ou 4, o boneco sobe
	loadn r0, #1
	cmp r5, r0
		ceq Sobe

	;if r5 = 2
	loadn r0, #2
	cmp r5, r0
		ceq Sobe
		
	;if r5 = 3
	loadn r0, #3
	cmp r5, r0
		ceq Sobe
		
	;if r5 = 4
	loadn r0, #4
	cmp r5, r0
		ceq Sobe
	
	;if r5 = 5						; Caso o ciclo do pulo esteja em 5, 6, 7 ou 8, o boneco desce
	loadn r0, #5
	cmp r5, r0
		ceq Desce
		
	;if r5 = 6
	loadn r0, #6
	cmp r5, r0
		ceq Desce
		
	;if r5 = 7
	loadn r0, #7
	cmp r5, r0
		ceq Desce
		
	;if r5 = 8
	loadn r0, #8
	cmp r5, r0
		ceq Desce
		
	;if r5 != 0
	loadn r0, #0					; Caso o boneco estaja no chao (ciclo = 0), nao se altera o ciclo
	cmp r5, r0
		cne IncrementaCiclo			; Caso nao esteja no chao, o ciclo deve continuar sendo incrementado
		
	loadn r0, #9					; Ate que o ciclo chegue em 9, entao se torna 0 novamente (boneco esta no chao novamente)
	cmp r5, r0
		ceq ResetaCiclo
				
		
	pop r0
	rts


AtObstaculo:					; Funcao que atualiza a posicao do obstaculo na tela de acordo com a necessidade da situacao
	
	push r0
	push r3
	push r4
	loadn r4, #40
	sub r3, r2, r4
	loadn r0 , #' '
	nop
	nop
	nop
	nop
	
	outchar r0, r2
	nop
	nop
	nop
	nop
	
	outchar r0, r3
	
	dec r2

	;if posicao do obstaculo = 480 (fim da tela para a esquerda)
		
	loadn r0, #480
	cmp r2, r0
		ceq ResetaFantasma
		
	loadn r0, #360
	cmp r2, r0
		ceq ResetaFantasma
		
	pop r0
	pop r3
	pop r4
	rts
AtPosicaoFruta:					; Funcao que atualiza a posicao do obstaculo na tela de acordo com a necessidade da situacao
	
	push r2
	push r4

	loadn r2, #' '
	nop
	nop
	nop
	nop 
	
	outchar r2, r3
	nop
	nop
	nop
	nop
	
	dec r3

	;if posicao do obstaculo = 480 (fim da tela para a esquerda)
		
	loadn r2, #480
	cmp r3, r2
		ceq ResetaFruta
		
	loadn r2, #360
	cmp r3, r2
		ceq ResetaFruta
		
	pop r4
	pop r2
	rts
	
ResetaFruta:			; Funcao que reseta a posicao da fruta
	push r0
	push r4
	push r5
	
	loadn r1, #0
	loadn r3, #510		; Posicao (padrao da fruta)
	
	call GeraPosicaoFruta	; Gera a nova posicao para a fruta
	
	loadn r4, #2		;  Caso 1
	cmp r5,r4
	ceq AlteraPos1Fruta
	
	loadn r4, #1		; Caso 2
	cmp r5,r4
	ceq AlteraPos2Fruta
	
	pop r5
	pop r4
	pop r0
	
	loadn r1, #0
	rts

ResetaFantasma:			; Funcao que reseta a posicao do fantasma
	push r0
	push r4
	push r5
	
	loadn r2, #519		; Posicao (padrao do obstaculo)
	
	call GeraPosicaoFantasma	; Gera a nova  posicao para o obstaculo
	
	loadn r4, #1		;  Caso 1
	cmp r5,r4
	ceq AlteraPos1Fantasma
	
	loadn r4, #2		; Caso 2
	cmp r5,r4
	ceq AlteraPos2Fantasma
	
	pop r5
	pop r4
	pop r0
	rts
	
GeraPosicaoFantasma :			; Funcao que gera uma posicao aleatoria para o obstaculo
	push r0
	push r4
						; sorteia nr. randomico entre 0 - 7
	loadn r0, #Rand 	; declara ponteiro para tabela rand na memoria!
	load r4, incr_rand	; Pega Incremento da tabela Rand
	add r0, r0, r4		; Soma Incremento ao inicio da tabela Rand
						; R2 = Rand + IncRand
	loadi r5, r0 		; busca nr. randomico da memoria em R3
						; R3 = Rand(IncRand)
						
	inc r4				; Incremento ++
	loadn r0, #30
	cmp r4, r0			; Compara com o Final da Tabela e re-estarta em 0
	jne ResetaVetor
		loadn r4, #0		; re-estarta a Tabela Rand em 0
  ResetaVetor:
	store incr_rand, r4	; Salva incremento ++
	
	
	pop r4
	pop r0
	rts
	
GeraPosicaoFruta :			; Funcao que gera uma posicao aleatoria para o obstaculo
	push r0
	push r4
						; sorteia nr. randomico entre 0 - 7
	loadn r0, #Rand 	; declara ponteiro para tabela rand na memoria!
	load r4, incRand	; Pega Incremento da tabela Rand
	add r0, r0, r4		; Soma Incremento ao inicio da tabela Rand
						; R2 = Rand + IncRand
	loadi r5, r0 		; busca nr. randomico da memoria em R3
						; R3 = Rand(IncRand)
						
	inc r4				; Incremento ++
	loadn r0, #30
	cmp r4, r0			; Compara com o Final da Tabela e re-estarta em 0
	jne ResetaVetor
		loadn r4, #0		; re-estarta a Tabela Rand em 0
  ResetaVetor:
	store incRand, r4	; Salva incremento ++
	
	
	pop r4
	pop r0
	rts

ResetaAleatorio:	; Funcao que reseta a semente para a funcao de geracao aleatoria
		
		push r2
			
		loadn r2,#28

		
		sub r1,r2,r2 

		
		pop r2

		rts


AlteraPos1Fruta:		; Caso 1 da posicao da fruta
		push r4
		
		loadn r4,#0
		sub r3,r3,r4
		load r0, fruta

		pop r4
		rts

AlteraPos1Fantasma:		; Caso 1 da posicao do obstaculo
		push r4
		
		loadn r4,#0
		sub r2,r2,r4
		load r1, fantasma

		pop r4
		rts

AlteraPos2Fruta:	; Caso 2 da posicao da fruta
		push r4
		
		loadn r4,#80
		sub r3,r3,r4	
		
		load r0, fruta
		pop r4
		rts

AlteraPos2Fantasma:	; Caso 2 da posicao do obstaculo
		push r4
		
		loadn r4,#80
		sub r2,r2,r4	
		
		load r1, fantasma
		pop r4
		rts


ChecaPulo:	; Funcao que checa se o jogador pressionou 'space' e, se sim, inicia o ciclo do pulo

	push r3
	load r3, Letra 				; Caso ' space' tenha sido pressionado	
	cmp r7, r3
		loadn r3, #255
		store Letra, r3
		ceq IncrementaCiclo		; Inicia o ciclo do pulo
	pop r3 		
	rts


IncrementaCiclo:		; Incrementa o ciclo do pulo

	inc r5
	rts


ResetaCiclo:		; Reseta o ciclo do pulo

	loadn r5, #0
	rts


Sobe:	; Funcao que sobe o personagem para a linha de cima (-40 em sua posicao)

	push r1
	push r2
	
	call ApagaPersonagem
	
	loadn r1, #80
	sub r6, r6, r1
	
	pop r2
	pop r1
	rts 

	
Desce:	; Funcao que desce o personagem para a linha de cima (+40 em sua posicao)

	push r1
	push r2
	
	call ApagaPersonagem
	
	loadn r1, #80
	add r6, r6, r1
	
	pop r2
	pop r1
	rts
	

DelayChecaPulo:  		; Funcao que da' o delay de um ciclo do jogo e tambem le uma tecla do teclado
	push r0
	push r1
	push r2
	push r3
	
	load r0, delay1
	loadn r3, #255
	store Letra, r3		; Guarda 255 na Letra pro caso de nao apertar nenhuma tecla
	
	loop_delay_1:
		load r1, delay2

; Bloco de ler o Teclado no meio do DelayChecaPulo!!		
			loop_delay_2:
				inchar r2
				cmp r2, r3 
				jeq loop_skip
				store Letra, r2		; Se apertar uma tecla, guarda na variavel Letra
			
	loop_skip:			
		dec r1
		jnz loop_delay_2
		dec r0
		jnz loop_delay_1
		jmp sai_dalay
	
	sai_dalay:
		pop r3
		pop r2
		pop r1
		pop r0
	rts


PrintaNumero:	; Imprime um numero de 2 digitos na tela; R5 contem um numero de ate' 2 digitos e R6 a posicao onde vai imprimir na tela

	push r0
	push r1
	push r2
	push r3
	
	loadn r0, #10
	loadn r2, #48
	
	div r1, r5, r0	; Divide o numero por 10 para imprimir a dezena
	
	add r3, r1, r2	; Soma 48 ao numero pra dar o Cod.  ASCII do numero
	nop
	nop
	nop
	nop
	nop
	
	outchar r3, r6
	
	inc r6			; Incrementa a posicao na tela
	
	mul r1, r1, r0	; Multiplica a dezena por 10
	sub r1, r5, r1	; Pra subtrair do numero e pegar o resto
	
	add r1, r1, r2	; Soma 48 ao numero pra dar o Cod.  ASCII do numero
	nop
	nop
	nop
	nop
	nop
	
	outchar r1, r6
	
	pop r3
	pop r2
	pop r1
	pop r0

	rts


PrintaPersonagem:	; Desenha o personagem na tela
	push r0
	
	nop
	nop
	nop
	
	loadn r4, #'.'
	outchar r4, r6
	loadn r4, #'_'
	loadn r0, #40
	inc r6
	nop
	nop
	nop
	
	outchar r4, r6 
	loadn r4, #'>'
	inc r6
	nop
	nop
	nop
	nop
	
	outchar r4, r6 
	sub r6, r6, r0
	loadn r4, #' '
	nop
	nop
	nop
	
	outchar r4, r6 
	loadn r4, #'<'
	dec r6
	nop
	nop
	nop

	outchar r4, r6 
	loadn r4, #'('
	dec r6
	nop
	nop
	nop
	nop
	
	outchar r4, r6 
	sub r6, r6, r0
	loadn r4, #'.'
	nop
	nop
	nop
	nop
	
	outchar r4, r6 
	loadn r4, #'-'
	inc r6
	nop
	nop
	nop
	nop
	
	outchar r4, r6 
	loadn r4, #'>'
	inc r6
	nop
	nop
	nop
	nop
	
	outchar r4, r6 
	add r6, r6, r0
	add r6, r6, r0
	dec r6
	dec r6
	loadn r4, #'.'
	pop r0			
	rts


ApagaPersonagem:	; Apaga o personagem da tela
	
	push r4
	push r0
	push r6

	loadn r4, #' '	; Printa um espaco no lugar do personagem, apagando-o
	nop
	nop
	nop
	nop
	
	outchar r4, r6 	
	
	inc r6
	nop
	nop
	nop
	nop

	outchar r4, r6 
	
	inc r6
	nop
	nop
	nop
	nop
	
	outchar r4, r6 
	
	loadn r0, #40
	sub r6, r6, r0
	nop
	nop
	nop
	nop
	
	outchar r4, r6
	
	dec r6
	nop
	nop
	nop
	nop
	
	outchar r4, r6
	
	dec r6
	
	nop
	nop
	nop
	nop
	
	outchar r4, r6
	
	sub r6, r6, r0
	nop
	nop
	nop
	
	outchar r4, r6
	
	inc r6
	nop
	nop
	nop
	
	outchar r4, r6
	
	inc r6
	nop
	nop
	nop
	
	outchar r4, r6
	
	add r6, r6, r0
	add r6, r6, r0
	dec r6
	dec r6
	
	pop r6
	pop r0
	pop r4
	rts


colisaoFantasma:	; checa a colisão do pacman com os fantasmas
	push r0
	push r6
	push r2
	inc r6
	
	; compara a posição do pacman com a do fantasma (se o pé, meio ou cabeça do pacman encontrarem o fantasma é game over)
	cmp r2, r6   
	jeq GameOver

	loadn r0, #40
	sub r2, r2, r0
	cmp r2, r6
	jeq GameOver
	add r2, r2, r0
	
	loadn r0, #40
	sub r6, r6, r0
	inc r6
	cmp r2, r6	
	jeq GameOver
	
	loadn r0, #40
	sub r2, r2, r0
	cmp r2, r6
	jeq GameOver
	add r2, r2, r0
	
	loadn r0, #40
	sub r6, r6, r0
	cmp r2, r6	
	jeq GameOver
	
	add r6, r6, r0
	add r2, r2, r0
	
	pop r2
	pop r6
	pop r0
	
	rts
	
ApagaFruta:
	push r4;
	push r5;
	push r6;
	push r3;
	
	loadn r1, #1
	load r5, pontos
	loadn r6, #38
	
	call IncPontos
	nop
	nop
	nop
	nop
	
	call PrintaNumero	; Imprime a pontuacao na tela
	
	;loadn r4, #' '	; Printa um espaco no lugar do personagem, apagando-o
	;nop
	;nop
	;nop
	;nop
	
	;outchar r4, r3 	
	
	pop r3;
	pop r6;
	pop r5;
	pop r4;
	rts;colisaoFruta_fim
	
colisaoFruta:	; checa a colisão do pacman com as frutas
	push r0
	push r6
	push r3
	
	inc r6
	
	; compara a posição do pacman com a do fantasma (se o pé, meio ou cabeça do pacman encontrarem o fantasma é game over)
	cmp r3, r6   
		ceq ApagaFruta
	
	inc r6
	cmp r3, r6   
		ceq ApagaFruta
		
	nop
	nop
	nop
	
	loadn r0, #40
	sub r6, r6, r0
	cmp r3, r6
		ceq ApagaFruta
		
	nop
	nop
	nop
	
	loadn r0, #40
	sub r6, r6, r0
	cmp r3, r6	
		ceq ApagaFruta
		
	nop
	nop
	nop
	
	;loadn r0, #40
	;sub r3, r3, r0
	;cmp r3, r6
		;jeq ApagaFruta
	;add r3, r3, r0
	
	;loadn r0, #40
	;sub r6, r6, r0
	;cmp r3, r6	
		;jeq ApagaFruta
;colisaoFruta_fim:
	;add r6, r6, r0
	;add r6, r6, r0
	;add r3, r3, r0
	
	pop r3
	pop r6
	pop r0
	
	rts


telaInicioLinha0  : string "                                        "
telaInicioLinha1  : string "                                        "
telaInicioLinha2  : string "                                        "
telaInicioLinha3  : string "                                        "
telaInicioLinha4  : string "                                        "
telaInicioLinha5  : string "                                        "
telaInicioLinha6  : string "                                        "
telaInicioLinha7  : string "                                        "
telaInicioLinha8  : string "                                        "
telaInicioLinha9  : string "                                        "                    
telaInicioLinha10 : string "                                        "                  
telaInicioLinha11 : string "               PACMARIO                 "                  
telaInicioLinha12 : string "                                        "
telaInicioLinha13 : string "                                        "                   
telaInicioLinha14 : string "                                        "                  
telaInicioLinha15 : string "                                        "
telaInicioLinha16 : string "                                        "
telaInicioLinha17 : string "                                        "
telaInicioLinha18 : string "                                        "
telaInicioLinha19 : string "           PRESSIONE ESPACO             "
telaInicioLinha20 : string "                                        "
telaInicioLinha21 : string "                                        "
telaInicioLinha22 : string "                                        "
telaInicioLinha23 : string "                                        "
telaInicioLinha24 : string "                                        "
telaInicioLinha25 : string "                                        "
telaInicioLinha26 : string "                                        "
telaInicioLinha27 : string "                                        "
telaInicioLinha28 : string "                                        "
telaInicioLinha29 : string "                                        "

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; 			TELA PADRAO
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
telaPadraoLinha0  : string "                                        "
telaPadraoLinha1  : string "                                        "
telaPadraoLinha2  : string "                                        "
telaPadraoLinha3  : string "                                        "
telaPadraoLinha4  : string "                                        "
telaPadraoLinha5  : string "                                        "
telaPadraoLinha6  : string "                                        "
telaPadraoLinha7  : string "                                        "
telaPadraoLinha8  : string "                                        "
telaPadraoLinha9  : string "                                        "
telaPadraoLinha10 : string "                                        "
telaPadraoLinha11 : string "                                        "
telaPadraoLinha12 : string "                                        "
telaPadraoLinha13 : string "########################################"
telaPadraoLinha14 : string "                                        "
telaPadraoLinha15 : string "                                        "
telaPadraoLinha16 : string "                                        "
telaPadraoLinha17 : string "                                        "
telaPadraoLinha18 : string "                                        "
telaPadraoLinha19 : string "                                        "
telaPadraoLinha20 : string "########################################"
telaPadraoLinha21 : string "                                        "
telaPadraoLinha22 : string "                                        "
telaPadraoLinha23 : string "                                        "
telaPadraoLinha24 : string "                                        "
telaPadraoLinha25 : string "                                        "
telaPadraoLinha26 : string "                                        "
telaPadraoLinha27 : string "                                        "
telaPadraoLinha28 : string "                                        "
telaPadraoLinha29 : string "                                        "

telaGameOverLinha0  : string "                                        "
telaGameOverLinha1  : string "                                        "
telaGameOverLinha2  : string "                                        "
telaGameOverLinha3  : string "                                        "
telaGameOverLinha4  : string "                                        "
telaGameOverLinha5  : string "                                        "
telaGameOverLinha6  : string "                                        "
telaGameOverLinha7  : string "                                        "
telaGameOverLinha8  : string "                                        "
telaGameOverLinha9  : string "                                        "
telaGameOverLinha10 : string "                                        "
telaGameOverLinha11 : string "                                        "
telaGameOverLinha12 : string "                                        "
telaGameOverLinha13 : string "                                        "
telaGameOverLinha14 : string "                                        "
telaGameOverLinha15 : string "              GAME OVER                 "
telaGameOverLinha16 : string "                                        "
telaGameOverLinha17 : string "                                        "
telaGameOverLinha18 : string "                                        "
telaGameOverLinha19 : string "                                        "                                   
telaGameOverLinha20 : string "                                        "
telaGameOverLinha21 : string "               PONTOS:                  "
telaGameOverLinha22 : string "       					              "
telaGameOverLinha23 : string "                                        "
telaGameOverLinha24 : string "                                        "
telaGameOverLinha25 : string "                                        "
telaGameOverLinha26 : string "                                        "
telaGameOverLinha27 : string "                                        "
telaGameOverLinha28 : string "                                        "
telaGameOverLinha29 : string "                                        "

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; 			TELA CHAO (GRAMA)
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
telaChaoLinha0  : string "                                        "
telaChaoLinha1  : string "                                        "
telaChaoLinha2  : string "                                        "
telaChaoLinha3  : string "                                        "
telaChaoLinha4  : string "                                        "
telaChaoLinha5  : string "                                        "
telaChaoLinha6  : string "                                        "
telaChaoLinha7  : string "                                        "
telaChaoLinha8  : string "                                        "
telaChaoLinha9  : string "                                        "
telaChaoLinha10 : string "                                        "
telaChaoLinha11 : string "                                        "
telaChaoLinha12 : string "                                        "
telaChaoLinha13 : string "                                        "
telaChaoLinha14 : string "############### * ############## * #####"
telaChaoLinha15 : string "#### * ###### * 0 * ########## * 0 * ###"
telaChaoLinha16 : string "## * 0 * ###### * ############## * #####"
telaChaoLinha17 : string "#### * ################ * ##############"
telaChaoLinha18 : string "##################### * 0 * ############"
telaChaoLinha19 : string "####################### * ##############"
telaChaoLinha20 : string "                                        "
telaChaoLinha21 : string "                                        "
telaChaoLinha22 : string "                                        "
telaChaoLinha23 : string "                                        "
telaChaoLinha24 : string "                                        "
telaChaoLinha25 : string "                                        "
telaChaoLinha26 : string "                                        "
telaChaoLinha27 : string "                                        "
telaChaoLinha28 : string "                                        "
telaChaoLinha29 : string "                                        "

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; 			TELA BARRAS HORIZONTAIS
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
telaBarrasLinha0  : string "                                        "
telaBarrasLinha1  : string "                                        "
telaBarrasLinha2  : string "                                        "
telaBarrasLinha3  : string "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
telaBarrasLinha4  : string "                                        "
telaBarrasLinha5  : string "                                        "
telaBarrasLinha6  : string "                                        "
telaBarrasLinha7  : string "                                        "
telaBarrasLinha8  : string "                                        "
telaBarrasLinha9  : string "                                        "                   
telaBarrasLinha10 : string "                                        "               
telaBarrasLinha11 : string "                                        "               
telaBarrasLinha12 : string "                                        "            
telaBarrasLinha13 : string "                                        "                   
telaBarrasLinha14 : string "                                        "                  
telaBarrasLinha15 : string "                                        "
telaBarrasLinha16 : string "                                        "
telaBarrasLinha17 : string "                                        "
telaBarrasLinha18 : string "                                        "
telaBarrasLinha19 : string "                                  		"
telaBarrasLinha20 : string "                                        "
telaBarrasLinha21 : string "                                        "
telaBarrasLinha22 : string "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
telaBarrasLinha23 : string "                                        "
telaBarrasLinha24 : string "                                        "
telaBarrasLinha25 : string "                                        "
telaBarrasLinha26 : string "                                        "
telaBarrasLinha27 : string "                                        "
telaBarrasLinha28 : string "                                        "
telaBarrasLinha29 : string "                                        "
