;+----------------------------------------------+
;	PROGRAMA LABERINTO ASM-6809		;
; Javier García Pechero   		;
; Germán Francés Tostado  		;
;+----------------------------------------------+
.module subrutinas
	
pantalla	.equ 0xFF00
;;;;;;;;;;;;;;;;;;;;;;;;; SUBRUTINAS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	.globl  imprime_cadena
	.globl  imprime_laberinto
	.globl  laberinto_tamano
	.globl	laberintos
	.globl  imprime_laberinto_especifico
	.globl  calculo_pos_inicial
	.globl	calculo_pos_final
	.globl	calculo_desplazamiento
	.globl	imprime_numeros
	.globl	limpia_laberinto_especifico
	.globl	calculos
;;;;;;;;;;;;;;;;;;;;;;;;; VARIABLES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	.globl	direccion_inicio
	.globl	direccion_final
	.globl  temp
	.globl	col
	.globl	fil
	.globl	pos_inicio
	.globl	fila_ultima
	.globl	base_tablero
	.globl	desplazamiento
	.globl	desplazamiento_final
	.globl	aux
	.globl	lv
	.globl	option
	.globl	direccion_auxiliar
;;;;;;;;;;;;;;;;;;;;;;;;; VARIABLES TEXTO ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	.globl	clearScreen
	.globl	setUnderlined
	.globl	setNormal
	.globl	setNegative
	.globl	setYellow
	.globl	setBlue
	.globl	setRed	
	.globl	setBold
	.globl	setGreen
;;;;;;;;;;;;;;;;;;;;;;;;; DEFINICIONES VARIABLES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;; VARIABLES DE TEXTO ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
setRed:			.asciz	"\33[31m"
setBlue:		.asciz  "\33[36m"
setYellow:		.asciz  "\33[33m"
setGreen:		.asciz	"\33[32m"
setNormal:      	.asciz  "\33[0m"
setUnderlined:      	.asciz  "\33[4m"
setNegative:      	.asciz  "\33[7m"
setBold:      		.asciz  "\33[1m"
clearScreen:		.asciz  "\33[2J"
;;;;;;;;;;;;;;;;;;;;;;;;; VARIABLES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pos_inicio:		.word	0
pos_final:		.word	0
direccion_inicio:	.word	0
direccion_final:	.word	0
direccion_auxiliar:	.word	0
fila_ultima:		.word	0
base_tablero:		.word	0
filporancho:		.word	0
desplazamiento:		.word	0
desplazamiento_final:	.word	0
col:			.byte	0
fil:			.byte	0
aux:			.byte	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; imprime_cadena                                                   ;
;     saca por la pantalla la cadena acabada en '\0 apuntada por X ;
;                                                                  ;
;   Entrada: X-direccion de comienzo de la cadena                  ;
;   Salida:  ninguna                                               ;
;   Registros afectados: X, CC.                                    ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
imprime_cadena:
		pshu	a,x
ic_sgte:	
		lda 	,x+
		beq	ret_imprime_cadena
		sta 	pantalla
		bra 	ic_sgte		
ret_imprime_cadena:
		pulu	a,x
		rts	 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; imprime_laberinto                                                ;
;     saca por la pantalla un laberinto y añade \n cada linea      ;
;                                                                  ;
;   Entrada: X-direccion de comienzo de la cadena                  ;
;   Salida:  ninguna                                               ;
;   Registros afectados: CC.                                       ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
imprime_laberinto:
		pshu	a
		ldb 	#'\n
		stb 	pantalla
		clrb 
il_sgte:
		lda 	,x+
		beq	rts_imprime_laberinto
		sta	pantalla
		incb
		cmpb	laberinto_tamano
		beq	il_retorno
		
		bra 	il_sgte
il_retorno:
		clrb 
		ldb	#'\n
		stb	pantalla
		clrb
		bra	il_sgte
rts_imprime_laberinto:
		pulu	a
		rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; imprime_laberinto_especifico                                     ;
;     saca por la pantalla un laberinto concreto                   ;
;     y añade \n cada linea      				   ;
;                                                                  ;
;   Entrada: X-direccion de comienzo de la cadena                  ;
;   Salida:  ninguna                                               ;
;   Registros afectados: CC.                                       ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
imprime_laberinto_especifico:	
		ldd	temp
		leax 	d,x
		clra
		pshu	a,x
		clrb
		stx	direccion_auxiliar
ile_sgte:
		lda 	,x+
		beq	rts_imprime_laberinto_especifico
		sta	aux
		stx	direccion_auxiliar
		cmpa	#'o
		beq	cambiaverde
		cmpa	#'.
		beq	cambiaverde
		bra	ile_sigue
cambiaverde:
		ldx	#setGreen
		jsr	imprime_cadena
ile_sigue:
		lda	aux
		sta	pantalla
		ldx	#setBlue
		jsr	imprime_cadena
		ldx	direccion_auxiliar
		incb
		cmpb	laberinto_tamano
		beq	ile_retorno
		bra 	ile_sgte
ile_retorno:
		clrb 
		ldb	#'\n
		stb	pantalla
		clrb
		bra	ile_sgte
rts_imprime_laberinto_especifico:
		pulu	a,x
		rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; limpia_laberinto_especifico                                      ;
;     limpia el laberinto seleccionado sustituyendo por espacio    ;
;     si hay . o el jugador                                        ;
;   Entrada: X-direccion de comienzo de la cadena                  ;
;   Salida:  ninguna                                               ;
;   Registros afectados: CC.                                       ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
limpia_laberinto_especifico:	
		ldd	temp
		leax 	d,x
		clra
		pshu	a,x
		clrb
lolo:
		tfr	x,y
		lda 	,x+
		beq	limpia_fin_laberinto_especifico
		cmpa	#'X
		bne	limpia
		bra	lolo
limpia:			
		clra
		lda	#32				;Si encuentra algo distinto a X, pone un espacio en su lugar
		sta	,y
		clra
		bra	lolo
limpia_fin_laberinto_especifico:
		pulu	a,x
		rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; calculo_pos_incial                      			   ;
;     calcula la posición de inicio del jugador		           ;
;                                                                  ;
;   Entrada: X-direccion de comienzo de la cadena                  ;
;   Salida:  ninguna                                               ;
;   Registros afectados: X,D,CC.                                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
calculo_pos_inicial:
		clra
		clrb
		lda	laberinto_tamano
		ldb	laberinto_tamano	
		decb
		mul					;Calculo ultima fila laberinto: laberinto_tamano*(laberinto_tamano-1)
		std	fila_ultima			;Guardamos los bytes correspondientes a la primera pos de la ult fila
		
		ldx	#laberintos			
		ldd	temp				;Variable que calcula el laberinto elegido
		leax	d,x				;Direccion efectiva del laberinto elegido
		stx	base_tablero			;Guardamos la direccion base del tablero
		ldd	fila_ultima			;Cargamos en registro d los bytes correspondientes a la fil ultima
				
		leax	d,x				;Direccion efectiva fila ultima
		pshu	a,x
		clrb
			
bukle:							;Bucle para calcular la posicion del espacio
		lda 	,x+				;Cargamos en a lo que apunta x
		cmpa	#'!-1				;Comparacion con el espacio
		beq	encontrada				
		incb
		bra	bukle	
encontrada:
		stb	pos_inicio			;Guardamos cuantas posiciones hay desde col 0 hasta la posicion inicial
		stb 	col	
		ldd	temp
		ldx	#laberintos
		leax	d,x
		ldd 	fila_ultima				
		leax	d,x
		lda	#'o				;Cargamos jugador
		ldb	pos_inicio
		sta	b,x				;Cargamos jugador en la posicion que le corresponde
		leax	b,x
		stx	direccion_inicio		;Guardamos direccion inicio
		clrb
		clra
		ldb	laberinto_tamano
		decb
		stb	fil				;Guardamos en fil la ultima fila que sera (laberinto_tamano - 1)
finfin:
		pulu	a,x
		rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; calculo_pos_final                      			   ;
;     calcula la posición final (meta)			           ;
;                                                                  ;
;   Entrada: X-direccion de comienzo de la cadena                  ;
;   Salida:  ninguna                                               ;
;   Registros afectados: X,D,CC.                                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
calculo_pos_final:
		clra
		clrb		
		ldx	#laberintos
		ldd	temp				;Variable que calcula el laberinto elegido
		leax	d,x				;Direccion efectiva del laberinto elegido
				
		pshu	a,x
		clrb
			
buklazo:						;Bucle para calcular la posicion del espacio
		lda 	,x+
		cmpa	#'!-1				;Comparacion con codigo ascii del espacio 32
		beq	encontradal			;Salto una vez que lo encuentre
		incb
		bra	buklazo	
encontradal:
		stb	pos_final			;Guarda la columna correspondiente	
		ldd	temp				;Variable que calcula bytes correspondiente a la base del tablero elegido
		ldx	#laberintos
		leax	d,x			
		ldb	pos_final
		leax	b,x				;Desplazamos direccion efectiva en la posicion que le corresponde a la posfin
		stx	direccion_final			;Guardamos la direccion de memoria de la posicion final(meta)
		clrb
		clra
finfinfin:
		pulu	a,x
		rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; calculo_desplazamiento                      			   ;
;     calcula la posición a la que se desplaza el jugador          ;
;                                                                  ;
;   Entrada: X-direccion de comienzo de la cadena                  ;
;   Salida:  ninguna                                               ;
;   Registros afectados: X,D,CC.                                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
calculo_desplazamiento:
		lda	fil				;Carga en a la fila correspondiente al movimiento
		ldb	laberinto_tamano		;Carga en b laberinto_tamano
		mul					;d = fil * laberinto_tamano
		std	filporancho			;Guardamos en una variable auxiliar para calculos
		clra
		clrb					;Limpiamos registros
		ldx	filporancho			;Cargamos en x la multiplicacion anterior
		ldb	col				;Cargamos en b la columna correspondiente al movimiento
		abx					;A x le sumamos b, filporancho + col
		stx	desplazamiento			;Guardamos el desplazamiento en una variable
		ldd	base_tablero			;Cargamos la base del tablero en d
		addd	desplazamiento			;Sumamos la variable desplazamiento
		std	desplazamiento_final		;Guardamos la posicion de memoria final que es donde nos desplazaremos
		rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; calculos                      			  	   ;
;     calcula temp los bytes hasta el tabero elegido               ;
;                                                                  ;
;   Entrada: X-direccion de comienzo de la cadena                  ;
;   Salida:  ninguna                                               ;
;   Registros afectados: X,D,CC.                                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
calculos:	
		clrb
		ldb	lv				;Cargamos en b el numero nivel laberinto correspondiente
		decb					;Decrementamos b una unidad
		stb	option				;Cargamos el valor de b una variable auxiliar para los calculos
		std	temp				;Cargamos en temp el valor de d
		ldb	option
haha:							;Bucle for de n a 0		
		cmpb	#0				;Comparamos variable option si es igual a 0					
		beq	uwu				;Salto a uwu: salida de la subrutina
		decb
		stb	option				;Decrementamos option una unidad
		lda	laberinto_tamano
		ldb	laberinto_tamano
		mul					;d = laberinto_tamano * laberinto_tamano
		addd 	temp				;d = temp + d
		std	temp				;Guardamos el valor de D en temp
		ldd	#0				;Inicializamos D a 0
		ldb	option				;Cargamos en b option y saltamos a comienzo bucle: haha
		bra	haha
uwu:
		rts	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	imprime_numeros								  	   ;
;       Subrutina que imprime los numeros correspondientes a numero de movimientos	   ;
;	Saca por la pantalla un número decimal de 3 cifras 				   ;
;											   ;
;	Entrada: A - Número a representar						   ;
;	Salida: nunguna									   ;
;	Registros afectados: X, D, CC							   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;											   
imprime_numeros:									   										   
		pshs	b				;primera cifra								           
       		ldb 	#'0										   
        	cmpa 	#100									   
        	blo 	Menor100									   
        	suba 	#100									   
        	incb										   
        	cmpa 	#100									   
        	blo 	Menor200									   
        	incb								  		   
        	suba 	#100									   
Menor100:										   
Menor200:										   
        	stb 	pantalla			;segunda cifra.  En A quedan las dos Ultimas cifras				   
        	clrb									 	   
        	cmpa 	#80									   
        	blo 	Menor80									   
        	incb										   
        	suba 	#80									   
Menor80:
		lslb										   
        	cmpa 	#40									   
        	blo 	Menor40									   
        	incb										   
        	suba 	#40								  	   
Menor40:
		lslb										   
        	cmpa 	#20									   
        	blo 	Menor20									   
        	incb										   
        	suba 	#20									   
Menor20:
		lslb										   
        	cmpa 	#10									   
        	blo 	Menor10									   
        	incb										   
        	suba 	#10									   
Menor10:
		addb 	#'0									   
        	stb 	pantalla									   
        	adda 	#'0									   
        	sta 	pantalla									   											   
		puls	b									   									   
		rts										   			   
