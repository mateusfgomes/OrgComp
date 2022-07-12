jmp main

posicaoMeteoro : var #30
char : var #30
linha : string "============"
MensagemFinal: string "FIM DO MUNDO!"
StrPressEnter: string "Aperte ENTER para"
StrJogarNovmente: string "jogar novamente"
StrOuP: string "Ou 'p' para"
StrFinalizar: string "finalizar programa" 


score : var #1
jogador : var #1

cont : var #1 

Letra : var #1 

derrota : var #1 

velocidade : var #1

estado: var #1

inicializaVariaveisDoJogo:
	push r0
	push r1
	push r2
	
	loadn r0, #posicaoMeteoro
	loadn r1, #30
	loadn r2, #40
	call preencheVetor 
	
	loadn r0, #char
	loadn r1, #30
	loadn r2, #0
	call preencheVetor 
	
	loadn r0 , #0 
	store score, r0
	store derrota, r0
	store cont, r0
	store estado, r0
	
	loadn r0 , #8
	store jogador, r0
	
	loadn r0 , #255
	store Letra, r0
	
	loadn r0 , #950
	store velocidade, r0
	
	
	pop r2
	pop r1
	pop r0
	rts

rand : var #1
static rand, #53 ; Seed inicial
; Gerador de primos módulo p (no caso, p = 256)

; (SEED * a + c) % p
geraRand:
	push r0
	push r1
	push r2
	push r3
	
	load r0, rand ;SEED
	loadn r1,#97  ; a
	loadn r2, #133 ; c
	loadn r3, #256 ; p
	mul r0,r0,r1  ; SEED * a
	add r0,r0,r2  ;	SEED * a + c
	mod r0,r0,r3  ; (SEED * a + c) % p
	
	store rand, r0
	
	pop r3
	pop r2
	pop r1
	pop r0
	rts

;---- Inicio do Programa Principal -----

main:
	; começa rex
	call ApagaTela
	loadn r1, #telaInicioLinha0		; Imprime a tela inicial do jogo na cor marrom;
	loadn r2, #2304
	call ImprimeTela
	
	
	
	jmp Loop_Inicio				; Loop do inicio do jogo;
	
	Loop_Inicio:
	
		
		call DigLetra 			; Le uma letra do teclado
		
		loadn r0, #' '			; Quando a tecla espaco for acionada, comeca o jogo
		load r1, Letra
		cmp r0, r1
		jne Loop_Inicio
	
	
	
	; termina rex 
	
	call ApagaTela
	
	call inicializaVariaveisDoJogo
	
	
	loadn r1, #telaChaoLinha0		; Imprime a tela inicial do jogo na cor prata;
    loadn r2, #768
	call ImprimetelaChao
	
	call imprimePrimeiroFrame
	call desenhaPersonagens
	
	
	
	loadn r3, #1
	loadn r4, #29
	loadn r5, #40
	
	
loopmain:	
	
	call atualizaTela
	
	
	
	load r0, velocidade
	loadn r1, #119
	call imprimeNum
	
	
	load r0,derrota
	cmp r0,r3 ;se derrota == 1, acaba o jogo
	jeq telaDeDerrota
	
	call delay
	
	
	jmp loopmain
	
telaDeDerrota:
	
	call imprimeTelaDerrota
	call apagaTelaInteira
	jmp main
	
fimPrograma:	
	halt
	

;---- Inicio das Subrotinas -----



imprimeTelaDerrota:
	push r0
	push r1
	push r2
	
	loadn r0, #583	; Posicao na tela onde a mensagem sera' escrita
	loadn r1, #MensagemFinal	; Carrega r1 com o endereco do vetor que contem a mensagem
	loadn r2, #0		; Se7leciona a COR da Mensagem
	call Imprimestr
	
	loadn r0, #620	; Posicao na tela onde a mensagem sera' escrita
	loadn r1, #StrPressEnter ; Carrega r1 com o endereco do vetor que contem a mensagem
	loadn r2, #0		; Seleciona a COR da Mensagem
	call Imprimestr
	
	loadn r0, #661	; Posicao na tela onde a mensagem sera' escrita
	loadn r1, #StrJogarNovmente ; Carrega r1 com o endereco do vetor que contem a mensagem
	loadn r2, #0		; Seleciona a COR da Mensagem
	call Imprimestr
	
	loadn r0, #703	; Posicao na tela onde a mensagem sera' escrita
	loadn r1, #StrOuP ; Carrega r1 com o endereco do vetor que contem a mensagem
	loadn r2, #0		; Seleciona a COR da Mensagem
	call Imprimestr
	
	loadn r0, #740	; Posicao na tela onde a mensagem sera' escrita
	loadn r1, #StrFinalizar ; Carrega r1 com o endereco do vetor que contem a mensagem
	loadn r2, #0		; Seleciona a COR da Mensagem
	call Imprimestr
	
	
	pop r2
	pop r1
	pop r0
	rts
	


apagaTelaInteira:
	loadn r0, #1200
	loadn r1, #0
	loadn r2, #' '

apagaTelaInteira_loop:
	outchar r2, r1
	inc r1
	cmp r1,r0
	jne apagaTelaInteira_loop
	
	rts
	

atualizaScore :
	push r0
	push r1
	push r2

	loadn r0, #posicaoMeteoro
	loadn r1, #25
	add r0,r0,r1
	
	
	loadi r1, r0 
	load r2, jogador 

    inc r2
    inc r2
    inc r2
    inc r2
    
    cmp r1,r2
	ceq telaDeDerrota
	dec r2
    
	cmp r1,r2
	ceq telaDeDerrota
	dec r2
	
	cmp r1,r2 
	ceq telaDeDerrota
	dec r2

	cmp r1,r2
	ceq telaDeDerrota
	dec r2

	cmp r1,r2
	ceq telaDeDerrota

	dec r2
	cmp r1,r2
	ceq telaDeDerrota
	
	dec r2
	cmp r1,r2
	ceq telaDeDerrota


	jmp AtualizaMiss 

AtualizaMiss:
	pop r2
	pop r1
	pop r0
	rts


ProcessaEntrada:
	push r0
	push r1

	load r0, Letra

	loadn r1, #'a'
	cmp r0, r1
	ceq moveEsquerdajogador
	loadn r1, #'d'
	cmp r0, r1
	ceq moveDireitajogador
	
	pop r1
	pop r0
	rts

delay:
	push r0
	push r1
	push r2
	push r3
	push r4
	push r5
	
	load r5,estado
	
	loadn r0, #0

	loadn r3, #255
	
	loadn r1, #100 ;
delay1:
	load r2, velocidade
	delay2:
		inchar r4

        ; Aguarda entrada do usuário; se não receber nada, fica com 255
		cmp r4,r3
		jne entradaValida
			loadn r5,#0
			jmp DelayVelocidade
		entradaValida :
			cmp r5,r0
			jne DelayVelocidade
			
			store Letra, r4	
			loadn r5,#1
			call ProcessaEntrada
		DelayVelocidade:
            dec r2
            cmp r2,r0
            jne delay2
	dec r1
	cmp r1,r0
	jne delay1
	
	load r2, velocidade
	loadn r1, #2010; velocidade maxima vai ser 1990
	cmp r2,r1
	jle fim_delay
	loadn r1, #10; step do aumento
	sub r2,r2,r1
	store velocidade,r2
fim_delay:
	store estado,r5
	pop r5
	pop r4
	pop r3
	pop r2
	pop r1
	pop r0
	rts


moveDireitajogador:
	push r0
	push r1
	
	load r0, jogador
	
	loadn r1, #35
	
	cmp r0,r1
	jeq fimMoveDireitajogador
	
	inc r0
	call apagarPersonagens
	store jogador, r0
	call desenhaPersonagens
	
	call atualizaScore ; permitir pegar a Meteoro enquanto anda pra cima se movimenta
	
fimMoveDireitajogador:
	pop r1
	pop r0
	rts

moveEsquerdajogador:
	push r0
	push r1
	
	load r0, jogador
	
	loadn r1, #2 ;
	
	cmp r0,r1
	jeq fimMoveEsquerdajogador
	
	dec r0
	call apagarPersonagens
	store jogador, r0
	call desenhaPersonagens
	
	call atualizaScore ; permitir pegar a Meteoro enquanto se movimenta
	
fimMoveEsquerdajogador:
	pop r1
	pop r0
	rts



desenhaPersonagens:
	push r0
	push r1
	push r2
	push r3


	; --------- JOGADOR
	load r0, jogador
	loadn r3, #256

	loadn r1, #1003
	add r1, r1, r0
	dec r1
	
	loadn r2, #'_'
    add r2, r2, r3
	outchar r2, r1 
	inc r1
	
	loadn r2, #'_'
    add r2, r2, r3;
    outchar r2, r1 
	inc r1
	
	loadn r2, #' '
    add r2, r2, r3
    outchar r2, r1 
	inc r1
	
	loadn r1, #1040 
	add r1, r1, r0
	dec r1
	
	loadn r2, #' '
    add r2, r2, r3
	outchar r2, r1 
	
	loadn r2, #'_'
    add r2, r2, r3
	outchar r2, r1 
	
	loadn r2, #' '
	inc r1
    add r2, r2, r3
	outchar r2, r1
	 
	loadn r2, #'/'
	inc r1
    add r2, r2, r3
	outchar r2, r1 
	
	loadn r2, #'.'
	inc r1
    add r2, r2, r3
	outchar r2, r1
	
	loadn r2, #'_'
	inc r1
    add r2, r2, r3
	outchar r2, r1
	
	loadn r2, #')'
	inc r1
    add r2, r2, r3;
	outchar r2, r1
	
	loadn r1, #1078
	add r1, r1, r0
	
	loadn r2, #'|'
    add r2, r2, r3;
	outchar r2, r1 
	
	loadn r2, #' '
	inc r1
    add r2, r2, r3;
	outchar r2, r1
	
	loadn r2, #' '
	inc r1
    add r2, r2, r3;
	outchar r2, r1
	
	
	loadn r2, #'/'
	inc r1
    add r2, r2, r3;
	outchar r2, r1
	
	
	loadn r1, #1119
	add r1, r1, r0
	
	dec r1
	loadn r2, #'|'
    add r2, r2, r3;
	outchar r2, r1 
	inc r1
	outchar r2, r1 
	inc r1
	outchar r2, r1 
	
    pop r3
	pop r2
	pop r1
	pop r0
	rts


apagarPersonagens:
	push r0
	push r1
	push r2
	
	; ------- JOGADOR
	load r0, jogador
	
	loadn r1, #1003
	add r1, r1, r0
	dec r1
	
	loadn r2, #' '
	outchar r2, r1
	inc r1
	
	outchar r2, r1
	inc r1
	
	outchar r2, r1
	inc r1
	
	outchar r2, r1 
	inc r1
	outchar r2, r1
	
	loadn r1, #1040
	add r1, r1, r0
	dec r1
	
	outchar r2, r1 
	inc r1
	
	outchar r2, r1 
	inc r1
	outchar r2, r1 
	inc r1
	
	outchar r2, r1 
	inc r1
	
	outchar r2, r1 
	inc r1
	outchar r2, r1
	
	inc r1
	outchar r2, r1
	
	loadn r1, #1078
	add r1, r1, r0
	
	outchar r2, r1 
	inc r1
	
	outchar r2, r1 
	inc r1
	
	outchar r2, r1 
	inc r1
	
	outchar r2, r1 
	inc r1
	
	outchar r2, r1 
	inc r1
	
	outchar r2, r1 
	
	loadn r1, #1119
	add r1, r1, r0
	
	dec r1
	outchar r2, r1 
	
	inc r1
	inc r1
	outchar r2, r1
	
	
	pop r2
	pop r1
	pop r0
	rts

atualizaTela:
	push r0
	push r1
	push r2
	push r3
	push r4
	push r5
	push r6
	push r7
	
	call atualizaScore
	call apagaVetorDaTela
	call apagarPersonagens

	call MoveMeteoro
	
	
	loadn r1, #1
	load r6, cont
	add r7,r6,r1
	
	loadn r1, #6 ;numero de linhas entre cada Meteoro
	mod r7, r7, r1
	store cont, r7
	
	
	mov r2, r6
	
	loadn r6, #posicaoMeteoro
	loadn r7, #char
	
	loadn r1, #40
	loadn r0, #0
	storei r6, r1
	storei r7, r0
	
	cmp r2,r0 ; se cont != 0 nao escreve Meteoro na tela
	jne pula_escrita_atualizaTela
	
	call geraRand
	load r0, rand
	
	loadn r1, #1
	mod r0,r0,r1;
	
	loadn r1, #'@'
	add r0,r1,r0 ;

	call geraRand
	load r1, rand
	
	loadn r2, #37
	mod r1,r1,r2 
	loadn r2, #1
	add r1,r1,r2
	
	storei r6, r1
	storei r7, r0
	
pula_escrita_atualizaTela:	
	
	call imprimeVetor
	call desenhaPersonagens
	
	   
	pop r7
	pop r6
	pop r5
	pop r4
	pop r3
	pop r2
	pop r1
	pop r0
	rts

;--------------------------------------------------------------------------------------------------------

apagaVetorDaTela:
	push r0
	push r1
	push r2
	push r3
	push r4
	push r5
	push r6
	push r7
	
	loadn r6, #posicaoMeteoro
	loadn r7, #char
	
	loadn r0,#30
	loadn r1,#0 ; i=0
	


loopApagaVetDaTela:
	loadn r2, #40
	mul r3, r1, r2 ;r3 = linha atual
	loadi r4, r6 ;r4 = pos na linha
	loadn r5, #' ' ; r5 = char da linha
	
	cmp r4,r2
	jeq naoPrintEspacoApaga
	
	add r4,r4,r3 ; r4 = pos na tela pra imprimir
	outchar r5, r4
	
	loadn r2, #29 ; marcador da linha do '='
	
	cmp r1,r2
	jne naoPrintEspacoApaga
	loadn r5, #'=';
	outchar r5, r4
	
naoPrintEspacoApaga:
	inc r6
	inc r7
	inc r1
	cmp r1,r0
	jne loopApagaVetDaTela

	
	pop r7
	pop r6
	pop r5
	pop r4
	pop r3
	pop r2
	pop r1
	pop r0
	rts

;---------------------------------------------------------------------------------------------------------
;Função que pega as informaçoes do vetor e printa na tela
;Nao apaga o que estava antes, so escreve por cima(chamar função pra limpar tela antes)
;
imprimeVetor:
	push r0
	push r1
	push r2
	push r3
	push r4
	push r5
	push r6
	push r7
	
	loadn r6, #posicaoMeteoro
	loadn r7, #char
	
	loadn r0,#30
	loadn r1,#0 ; i=0
	
	loadn r2, #40 ; marcador do tam da linha
loopImprimeVetor:
	mul r3, r1, r2 ;r3 = linha atual
	loadi r4, r6 ; r4 = pos na linha
	loadi r5, r7 ; r5 = char da linha
	
	cmp r4,r2
	jeq naoImprimeVetNaTela
	
	add r4,r4,r3 ; r4 = pos na tela pra imprimir
	outchar r5, r4
	
naoImprimeVetNaTela:

	inc r6
	inc r7	
	inc r1
	cmp r1,r0
	jne loopImprimeVetor
	
	
	
	pop r7
	pop r6
	pop r5
	pop r4
	pop r3
	pop r2
	pop r1
	pop r0
	rts
	
;----------------------------------------------------------------------------------------------------------
;r0 - end inicial do vet de tam 30
;
MoveMeteoro:
	push r0
	push r1
	push r2
	push r3
	push r4
	push r5
	push r6
	push r7
	
	loadn r6, #posicaoMeteoro
	loadn r7, #char
	
	loadn r0,#28
	loadn r1,#0 ; i=0
		
	add r6,r6, r0; r6[final]
	add r7,r7, r0; r7[final]
	
	loadn r0,#29
loopMoveMeteoro:
	loadi r4, r6 ; r4 = pos na linha
	loadi r5, r7 ; r5 = char da linha
	
	inc r6
	inc r7
	
	storei r6, r4
	storei r7, r5
	
	dec r6
	dec r6
	dec r7
	dec r7
	
	
	
	inc r1
	cmp r1,r0
	jne loopMoveMeteoro
	
	
	pop r7
	pop r6
	pop r5
	pop r4
	pop r3
	pop r2
	pop r1
	pop r0
	rts
	
	
imprimePrimeiroFrame:
	push r0	; protege o r0 na pilha para preservar seu valor
	push r1	; protege o r1 na pilha para preservar seu valor
	push r2	; protege o r2 na pilha para preservar seu valor
	push r3	; protege o r2 na pilha para preservar seu valor
	push r4
	push r5
		
	load r0, score
	loadn r1, #39
	call imprimeNum
	
	loadn r5, #' '
	loadn r0, #29
	loadn r1, #0
	loadn r2, #40
loopImprimePrimeiroFrame:
	mul r3,r2,r1
	loadn r4, #3
	add r3, r3, r4
	outchar r5, r3
	loadn r4,#11
	add r3,r4,r3
	outchar r5, r3
	
	inc r1
	cmp r1,r0
	jne loopImprimePrimeiroFrame
	
	pop r5
	pop r4
	pop r3
	pop r2
	pop r1
	pop r0
	rts


Imprimestr:	;  Rotina de Impresao de Mensagens:    r0 = Posicao da tela que o primeiro caractere da mensagem sera' impresso;  r1 = endereco onde comeca a mensagem; r2 = cor da mensagem.   Obs: a mensagem sera' impressa ate' encontrar "/0"
	push r0	; protege o r0 na pilha para preservar seu valor
	push r1	; protege o r1 na pilha para preservar seu valor
	push r2	; protege o r1 na pilha para preservar seu valor
	push r3	; protege o r3 na pilha para ser usado na subrotina
	push r4	; protege o r4 na pilha para ser usado na subrotina
	
	loadn r3, #'\0'	; Criterio de parada

ImprimestrLoop:	
	loadi r4, r1
	cmp r4, r3
	jeq ImprimestrSai
	add r4, r2, r4
	outchar r4, r0
	inc r0
	inc r1
	jmp ImprimestrLoop
	
ImprimestrSai:	
	pop r4	; Resgata os valores dos registradores utilizados na Subrotina da Pilha
	pop r3
	pop r2
	pop r1
	pop r0
	rts
	
;--------------------------------------------------------------------------------------------------------
preencheVetor:
	loadn r3, #0
	storei r0, r2
	inc r0
	dec r1
	cmp r1,r3
	jne preencheVetor 
	rts


;IMPRIMENUMERO
;param r0 - num
;param r1 - pos na tela inicial(vai escrever da direita para a esquerda)
imprimeNum:
	push r0
	push r1
	push r3
	push r4
	push r5
	
	loadn r5, #'0'
	
loopImprimeNum:
	loadn r4,#10
	
	mod r3,r0,r4; r3 = num % 10
	add r3,r3,r5; r3 = r3 + '0';
	
	outchar r3, r1
	
	dec r1
	div r0,r0,r4
	
	loadn r4,#0
	cmp r0,r4
	jne loopImprimeNum
	
	pop r5
	pop r4
	pop r3
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

	;  r1 = endereco onde comeca a primeira linha do Cenario
	;  r2 = cor do Cenario para ser impresso
	
	push r0
	push r1
	push r2
	push r3
	push r4
	push r5

	loadn r0, #0  					; Posicao inicial
	loadn r3, #40  					; Incremento da posicao da tela
	loadn r4, #41  					; Incremento do ponteiro das linhas da tela
	loadn r5, #1200 				; Limite da tela
	
   ImprimeTela_Loop:
		call ImprimeStr
		add r0, r0, r3  			; Incrementa posicao para a segunda linha na tela
		add r1, r1, r4  			; Incrementa o ponteiro para o comeco da proxima linha na memoria
		cmp r0, r5					; Compara r0 com 1200
		jne ImprimeTela_Loop		; Enquanto r0 < 1200

	pop r5							; Resgata os valores dos registradores
	pop r4
	pop r3
	pop r2
	pop r1
	pop r0
	rts

DigLetra:							; Espera que uma tecla seja digitada e salva na variavel global Letra
	push r0
	push r1
	loadn r1, #255

   DigLetra_Loop:
		inchar r0					; Le o teclado, se nada for digitado = 255
		cmp r0, r1					;compara r0 com 255
		jeq DigLetra_Loop			; Fica lendo ate que o jogador digite uma tecla valida

	store Letra, r0					; Salva a tecla na variavel global "Letra"

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



ImprimetelaChao: 					;  Rotina de Impresao de Cenario na Tela Inteira

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
	
   ImprimetelaChao_Loop:
		call ImprimeStr2
		add r0, r0, r3  			; Incrementa posicao para a segunda linha na tela
		add r1, r1, r4  			; Incrementa o ponteiro para o comeco da proxima linha na memoria
		add r6, r6, r4  			; Incrementa o ponteiro para o comeco da proxima linha na memoria
		cmp r0, r5				; Compara r0 com 1200
		jne ImprimetelaChao_Loop		; Enquanto r0 < 1200
		
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


; --------------------------------------------- TELA INICIAL ---------------------------------------------
telaInicioLinha0:  string "                                        "
telaInicioLinha1:  string "                                        "
telaInicioLinha2:  string "#@@@@@.    @@  .@@/   @@    (@@@@%      "
telaInicioLinha3:  string "&@#   @@@  @@  /@.@@  @@  @@@    @@&    "
telaInicioLinha4:  string "&@#    @@  @@  /@, @@ @@  @@      @@    "
telaInicioLinha5:  string "&@#   @@@  @@  /@,  @@@@  @@@    @@(    "
telaInicioLinha6:  string "*@@@@&     @@  *@.   ,@@    (@@@@       "
telaInicioLinha7:  string "                                        "
telaInicioLinha8:  string "                                        "
telaInicioLinha9:  string "                                        "
telaInicioLinha10: string "                                        "
telaInicioLinha11: string "                                        "
telaInicioLinha12: string "@#  @@   @@%   @@   @@  @@@@@@   @@@@@@ "
telaInicioLinha13: string " @&@    @  @*  @@   @@ @@    @@ @@    @@"
telaInicioLinha14: string "  @*   @@@@@@  @@@@@@@ @@    @@ &@    @@"
telaInicioLinha15: string "  @    @    @  @@   @@ @@    @@ @@    @@"
telaInicioLinha16: string "  @    @    @  @@   @@   @@@@     @@@@  "
telaInicioLinha17: string "                                        "
telaInicioLinha18: string "                                        "
telaInicioLinha19: string "                                        "
telaInicioLinha20: string "                                        "
telaInicioLinha21: string "       Aperte espaco para iniciar       "
telaInicioLinha22: string "                                        "
telaInicioLinha23: string "                                        "
telaInicioLinha24: string "                                        "
telaInicioLinha25: string "                                        "
telaInicioLinha26: string "                                        "
telaInicioLinha27: string "                                        "
telaInicioLinha28: string "                                        "
telaInicioLinha29: string "                                        "



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
telaChaoLinha14 : string "                                        "
telaChaoLinha15 : string "                                        "
telaChaoLinha16 : string "                                        "
telaChaoLinha17 : string "                                        "
telaChaoLinha18 : string "                                        "
telaChaoLinha19 : string "                                        "
telaChaoLinha20 : string "                                        "
telaChaoLinha21 : string "                                        "
telaChaoLinha22 : string "                                        "
telaChaoLinha23 : string "                                        "
telaChaoLinha24 : string "                                        "
telaChaoLinha25 : string "                                        "
telaChaoLinha26 : string "                                        "
telaChaoLinha27 : string "                                        "
telaChaoLinha28 : string "                                        "
telaChaoLinha29 : string "########################################"