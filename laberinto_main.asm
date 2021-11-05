;+----------------------------------------------+
;	PROGRAMA LABERINTO ASM-6809 ;
; Javier García Pechero  		;
; Germán Francés Tostado  		;
;+----------------------------------------------+
	.module laberinto_main
;;;;;;;;;;;;;;;;;;;;;;;;; Definicion de constantes,cadenas,variables ;;;;;;;;;;;;;;;;;;;;;	
fin		.equ 0xFF01
teclado 	.equ 0xFF02
pantalla	.equ 0xFF00
;;;;;;;;;;;;;;;;;;;;;;;;; VARIABLES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
temp:			.word	0
lv:			.byte	0
option:			.byte	0
contadormov:		.word	0
tecla:			.byte	0
direccion_anterior:	.byte	0
guardado:		.byte	0
direccion_guardado:	.word	0
direccion_imprimir:	.word	0
;;;;;;;;;;;;;;;;;;;;;;;;; MENSAJES Y MENUSES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
presentacion_mp: 	.ascii	"\n+-----------------------------+\n"
			.ascii	"|          Laberinto          |\n"
			.ascii	"+-----------------------------+\n"
			.ascii  "\33[37m1)\33[33m ELEGIR LABERINTO\n"
			.ascii  "\33[37m2)\33[33m JUGAR\n"
			.ascii  "\33[37m3)\33[33m SALIR\n"
			.byte 0  
elija_opcion: 
			.asciz "\nIntroduzca una opcion:"
elegir_lab:
			.asciz	"Elija un laberinto "
opciones:
			.asciz	"(1-"
parentesis:
			.asciz	"):"
opcion_erronea:
			.asciz "\nOpcion erronea, introduzcala de nuevo: "
msg_error:
			.asciz	"\nOpcion erronea, introduzca una opcion valida\n"
elija_laberinto:
			.asciz "\n\nELEGIR LABERINTO\n"

lbrt_seleccionado:
			.asciz	"\nHa elegido el laberinto numero "
msg_salida: 
			.asciz "\n\nHa salido correctamente.\n\n\33[0m"
			
presentacion_menu_2: 		
			.ascii "\n1) Volver al menu principal\n"
			.ascii "2) Jugar\n"
			.ascii "Opcion: "
			.byte 	0
menu_next_lv:		
			.ascii "\n1) Volver al menu principal\n"
			.ascii "2) Jugar siguiente nivel\n"
			.ascii "Opcion: "
			.byte 	0
			
mensaje_victoria:
			.asciz "\n\tENHORABUENA HAS COMPLETADO EL JUEGO <3\n\33[0m"

reiniciar:
			.ascii "\n\33[33m\33[1m1) Reiniciar juego\n"
			.ascii "2) Salir del juego\n"
			.ascii "Opcion: "
			.byte 	0

lab_completado:		.asciz  "\nLABERINTO COMPLETADO\n"

msg_pared:		.asciz	"\nNo se puede mover hay una pared\n"	

nivel:			.asciz	"\nLABERINTO: "

movimientos:		.asciz	"Movimientos:"

teclas:			.asciz	"\n(O\P\Q\A)(X):"
;;;;;;;;;;;;;;;;;;;;;;;;;; PROGRAMA ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	.globl 	programa
;;;;;;;;;;;;;;;;;;;;;;;;;; BIBLIOTECA DE SUBRUTINAS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	.globl 	imprime_cadena 
	.globl 	imprime_laberinto
	.globl 	laberintos
	.globl 	laberinto_numero
	.globl	laberinto_tamano
	.globl 	imprime_laberinto_especifico
	.globl	calculo_pos_inicial
	.globl	calculo_desplazamiento
	.globl	imprime_numeros
	.globl	calculo_pos_final
	.globl	limpia_laberinto_especifico
	.globl	calculos
;;;;;;;;;;;;;;;;;;;;;;;;;; CONSTANTES COLORES Y OTROS EFECTOS TEXTO ;;;;;;;;;;;;;;;;;;;;;;;
	.globl	clearScreen				;Limpiarpantalla
	.globl	setNormal				
	.globl	setNegative
	.globl	setUnderlined
	.globl	setYellow		
	.globl	setBlue
	.globl	setRed
	.globl	setGreen
	.globl	setBold
;;;;;;;;;;;;;;;;;;;;;;;;; VARIABLES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	.globl	option
	.globl	lv
	.globl	temp
	.globl	contadormov
	.globl	col
	.globl	fil
	.globl	pos_inicio
	.globl	direccion_inicio
	.globl	direccion_final
	.globl	base_tablero
	.globl	desplazamiento
	.globl	desplazamiento_final
	.globl	direccion_anterior
	.globl	direccion_guardado
	.globl	direccion_imprimir

;;;;;;;;;;;;;;;;;;;;;;;;; INICIO PROGRAMA ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
programa:
		ldu	#pantalla			;Incializa la pila
		ldb	#1				;Inicializa lv = 1
		stb	lv
		ldd	#0				
		std	temp				;Inicializa temp = 0
		ldd	#0		
		std	contadormov			;Inicializa contador movimientos = 0
		clra
		clrb
b_for_limpiar:	
		ldb	lv				;Bucle for(a=1;a<laberinto_numero;a++);
		cmpb 	laberinto_numero
		bhi  	main
		jsr	calculos			;Salto subrutina para calcular cada laberinto correspondiente
		ldx	#laberintos
		jsr	limpia_laberinto_especifico	;Salto a subrutina para limpiar cada laberinto especifico
		clrb
		ldb	lv				;Cargar nivel
		incb 
		stb	lv				;Guardar nivel en variable lv
		clrb
		bra	b_for_limpiar
;;;;;;;;;;;;;;;;;;;;;;;;; INICIO MAIN ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
main:		
		ldd	#0
		std	temp				;Inicializa temp a 0
		ldb 	#1 				;Inicializa b a 1 por si juega directamente, empieza en el lab1
		stb	lv
		clra
		clrb
menu_principal:						
		ldx	#clearScreen			;LimpiaPantalla
		jsr	imprime_cadena
		ldx	#setBold			;Define letra negrita por defecto
		jsr	imprime_cadena
		ldx	#setYellow			;Define color amarillo
		jsr	imprime_cadena
		ldx 	#presentacion_mp 		;Carga el menu principal
		jsr 	imprime_cadena			;Llamada a la función de imprimir
		ldx 	#elija_opcion	
		jsr 	imprime_cadena
mp_ask_sgte: 						;Menu principal pregunta siguiente opcion
		lda 	teclado
		cmpa	#'1
		beq 	opcion1				;Si a = 1 salto 1)Elegir laberinto
		cmpa	#'2
		lbeq 	jugardirect			;Si a = 2 salto 2)Jugar
		cmpa 	#'3
		lbeq 	opcion3				;Si a = 3 salto 3)Salir del programa
		ldx	#opcion_erronea			;Si no se teclea opcion valida
		jsr 	imprime_cadena
		bra 	mp_ask_sgte
menu_2: 					 	;Menu secundario tras elegir un laberinto 2
		ldx 	#presentacion_menu_2		
		jsr 	imprime_cadena
m2_ask_sgte:						;Solicitud opciones menu 2
		lda 	teclado	
		cmpa	 #'1
		beq 	menu_principal			;Si a = 1 salto menu principal
		cmpa 	#'2
		lbeq 	opcion2				;Si a = 2 salto a jugar
		ldx 	#opcion_erronea			;Si no se teclea ninguna opcion valida
		jsr 	imprime_cadena
		bra 	m2_ask_sgte
;;;;;;;;;;;;;;;;;;;;;;;;; OPCION 1 = ELEGIR LABERINTO ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
opcion1: 					
		clrb
		ldb	#1				;Establece variable lv a 1 para empezar por el primer laberinto para limpiarlos
		stb	lv
		ldd	#0			
		std	temp				;Establece la variable temp a 0 para empezar por el primer laberinto para limpiarlos
b_for_limpiar_elegirlb:					;Bucle para limpiar los laberintos
		ldb	lv				;Bucle for(a=1;a<laberinto_numero;a++);
		cmpb 	laberinto_numero	
		bhi  	elegirlb			;Salto fin bucle
		jsr	calculos			;Salto subrutina calcula direccion memoria de inicio de cada laberinto
		ldx	#laberintos
		jsr	limpia_laberinto_especifico	;Salto subrutina que limpia un laberinto
		clrb
		ldb	lv	
		incb 					;Incremento del nivel para limpiar el siguiente laberinto
		stb	lv	
		clrb
		bra	b_for_limpiar_elegirlb		;Salto bucle principio
elegirlb:
		ldx 	#elija_laberinto		
		jsr 	imprime_cadena	
		ldx	#setBlue
		jsr	imprime_cadena
		ldx 	#laberintos
		lda	#1
b_for_imprimir:						;Muestra en pantalla todos los laberintos
		stx	direccion_imprimir		;Bucle for(a=1;a<laberinto_numero;a++);
		cmpa 	laberinto_numero		;Comparacion numero laberintos
		bhi  	ask_sgte			;Salida bucle for
		ldx	#setYellow		
		jsr	imprime_cadena
		ldx	#nivel
		jsr	imprime_cadena
		ldx	#setRed
		jsr	imprime_cadena
		adda	#'0				;Añade el ascii del 0 para visualizar qué numero de laberinto está imprimiendo
		sta	pantalla
		suba	#'0
		ldx	#setBlue
		jsr	imprime_cadena
		ldx	direccion_imprimir
		jsr	imprime_laberinto   	 	;Imprime n laberintos
		inca 
		bra	b_for_imprimir			;Vuelta principio bucle for
ask_sgte: 
		ldx	#setYellow			;Minimenu: Introduzca una opcion(1-n):
		jsr	imprime_cadena		
		ldx 	#elegir_lab
		jsr 	imprime_cadena
		ldx	#opciones
		jsr	imprime_cadena
		lda	laberinto_numero
		adda	#'0
		sta	pantalla	
		ldx	#parentesis
		jsr	imprime_cadena
bwhile_opcion:						;Bucle while para verificar si la opcion está dentro de 0-n lbrt	
		ldb 	teclado
		subb	#'0		
		cmpb 	#0
		ble	repetir_while
		cmpb	laberinto_numero
		ble	w_seguir
repetir_while:
		ldx	#opcion_erronea			;Mensaje opcion erronea
		jsr 	imprime_cadena
		bra 	bwhile_opcion			;Salto inicio bucle while
w_seguir:
		lda	#0
		sta	guardado			;Establecemos valor 0 a variables guardado y contadormov
		sta	contadormov
		ldx	#clearScreen
		jsr	imprime_cadena
		ldx	#lbrt_seleccionado		
		jsr	imprime_cadena
		addb	#'0
		ldx	#setRed
		jsr	imprime_cadena
		stb	pantalla	
		subb	#'0
		stb	lv				;lv=laberinto seleccionado
		ldx	#setYellow
		jsr	imprime_cadena
		bra	lbrt
;;;;;;;;;;;;;;;;;;;;;;;;; CALCULOS LBRT SELECCIONADO Y MOSTRAR EN PANTALLA EL LBRT ;;;;;;;
jugardirect:	
		ldx	#clearScreen
		jsr	imprime_cadena
lbrt:
		clra				
		jsr	calculos			;Salto subrutina calculos
next:
		ldx	#setYellow			;Imprime laberinto para jugar con su numero correspondiente
		jsr	imprime_cadena
		ldx	#nivel
		jsr	imprime_cadena
		ldx	#setRed
		jsr	imprime_cadena
		ldb	lv	
		addb	#'0
		stb	pantalla
		clrb
		ldb	#'\n
		stb	pantalla
		clrb
		ldx	#setBlue			
		jsr	imprime_cadena
		ldx 	#laberintos		
		jsr 	imprime_laberinto_especifico
		ldx	#setYellow
		jsr	imprime_cadena
		lbra 	menu_2				;Salto menu2		
;;;;;;;;;;;;;;;;;;;;;;;;; OPCION 2 = JUGAR ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
opcion2:	
		clra
		lda	guardado			;Cargamos guardado en a por si guardado = 1 quiere decir que hay que reanudar el juego
		cmpa	#1
		beq	continuar_guardado		;Salto para continuar con la partida guardada
		jsr	calculo_pos_inicial		;Salto subrutina que calcula la posicion inicial del personaje
		jsr	calculo_pos_final		;Salto subrutina que calcula la posicion final(la meta)
		ldy	direccion_inicio		;Carga direccion inicio del personaje en y
		sty	direccion_anterior		;Guarda la direccion de inicio en direccion anterior(variable auxiliar para movimientos) 
		sty	direccion_guardado		;Guarda direccion inicio en la de guardar partida(solo ocurre cuando comienza un nivel nuevo)
		sty	desplazamiento_final		;Guardamos en desplazamiento final en caso de salir de la partida nada más empezar la partida
		bra	jugar
continuar_guardado:
		ldy	direccion_guardado		;Carga en y la direccion guardada
		sty	direccion_anterior		;Carga la direccion guardada en direccion anterior para realizar bien los movimientos
		bra	jugar				;Salto a jugar directamente
error:							;Caso teclear opcion erronea
		ldx	#clearScreen			;Limpia pantalla
		jsr	imprime_cadena
		ldx	#setNegative
		jsr	imprime_cadena
		ldx	#msg_error
		jsr	imprime_cadena
		ldx	#setNormal
		jsr	imprime_cadena
		ldx	#setBold
		jsr	imprime_cadena
		ldx	#setYellow
		jsr	imprime_cadena
		bra	jueganext			;Salto imprimir laberinto e interfaz para jugar
					
paredes:						;Caso chocar con pared
		ldx	#clearScreen
		jsr	imprime_cadena
		ldx	#msg_pared
		jsr	imprime_cadena	
		bra	jueganext			;Salto imprimir laberinto e interfaz para jugar	
jugar:							;Jugar directamente con pantalla limpia
		ldx	#clearScreen
		jsr	imprime_cadena
		clra
jueganext:						;Impresión laberinto e interfaz juego
		ldx	#setYellow
		jsr	imprime_cadena
		ldx	#nivel				;Laberinto: n
		jsr	imprime_cadena
		ldx	#setRed
		jsr	imprime_cadena
		ldb	lv	
		addb	#'0
		stb	pantalla
		clrb
		ldb	#'\n
		stb	pantalla
		ldx	#setYellow
		jsr	imprime_cadena
		ldx	#movimientos			;Movimientos: xxxx
		jsr	imprime_cadena
		ldx	#setRed
		jsr	imprime_cadena
		lda	contadormov
		jsr	imprime_numeros
		stb	pantalla
		clrb	
		ldx	#setBlue
		jsr	imprime_cadena
		ldx	#laberintos			;Imprime laberinto seleccionado
		jsr	imprime_laberinto_especifico
		ldx	direccion_anterior
		cmpx	direccion_final			;Compara x para ver si se ha llegado al final
		lbeq	next_lb
pedir_movimiento:					;Solicitud movimientos
		ldx	#setYellow
		jsr	imprime_cadena
		ldx	#teclas				;Imprime controles del juego
		jsr	imprime_cadena
		clra
		lda	teclado	
		sta	tecla				;Variable que guarda el codigo ascii de la tecla introducida
comprobar_mov:						;Comprueba movimiento segun tecla introducida
		cmpa	#'q
		beq	arriba
		cmpa	#'p
		beq	derecha
		cmpa	#'o
		beq	izquierda
		cmpa	#'a
		beq	abajo
		cmpa	#'x
		lbeq	querer_ir_menu
		ldx	#opcion_erronea
		jsr	imprime_cadena
		lbra	error
arriba:							;Arriba->Decrementamos una fila
		ldb	fil
		decb
		stb	fil
		jsr	calculo_desplazamiento		;Salto subrutina que calcula el desplazamiento	
		clrb
		bra	comprobacion			;Salto comprobacion del movimiento elegido
derecha:						;Derecha->Incrementamos una columna
		ldb	col
		incb
		stb	col
		jsr	calculo_desplazamiento		;Salto subrutina que calcula el desplazamiento	
		clrb
		bra	comprobacion			;Salto comprobacion del movimiento elegido
izquierda:						;Izquierda->Decrementamos una columna
		ldb	col
		decb
		stb	col
		jsr	calculo_desplazamiento		;Salto subrutina que calcula el desplazamiento
		clrb
		bra	comprobacion			;Salto comprobacion del movimiento elegido
abajo:							;Abajo->Incrementamos una fila
		ldb	fil				
		incb
		stb	fil
		jsr	calculo_desplazamiento		;Salto subrutina que calcula el desplazamiento	
		clrb
		bra	comprobacion			;Salto comprobacion del movimiento elegido
comprobacion:						;Comprobacion lo que hay en la posición de memoria tras el calculo del movimiento deseado
		ldx	base_tablero			;Cargamos en x la base del tablero
		ldd	desplazamiento			;Variable que tiene cargada el desplazamiento a realizar, la cargamos en d
		leax	d,x				;Desplazamos d posiciones para calcular la direccion efectiva de la posicion de memoria que tiene que apuntar x
		clra
		lda	,x				;Carga en A el caracter al que apuntaba X y lo compara con las posibles opciones para realizar la accion
		cmpa	#'X				;Comparaciones si es pared o espacio o punto
		beq	pared
		cmpa	#'!-1
		beq	espacio
		cmpa	#'.
		beq	punto
pared:							;Caso pared
		clra
		lda	#7				;Codigo ascii del sonido
		sta	pantalla
		clra
		lda	tecla				;Cargamos tecla en a para comparar y decidir como hay que corregir el cambio efectuado para el movimiento 
		cmpa	#'q
		beq	corregir_arriba
		cmpa	#'p
		beq	corregir_derecha
		cmpa	#'o
		beq	corregir_izquierda
		cmpa	#'a
		beq	corregir_abajo
corregir_arriba:					;Corrige Arriba fil+1
		clrb
		ldb	fil
		incb
		stb	fil
		lbra	paredes
corregir_derecha:					;Corrige Derecha col mas uno
		clrb
		ldb	col
		decb
		stb	col
		lbra	paredes
corregir_izquierda:					;Corrige Izquierda col menos uno
		clrb
		ldb	col
		incb
		stb	col
		lbra	paredes
corregir_abajo:						;Corrige Abajo fil menos uno
		clrb
		ldb	fil
		decb	
		stb	fil
		lbra	paredes		
punto:							;Caso punto suma a contador movimientos mas cinco
		clra
		lda	contadormov
		adda	#5
		sta	contadormov
		bra 	movimiento			;Salto a movimiento
espacio:						;Caso espacio suma contador movimientos 
		clra	
		lda	contadormov
		inca
		sta	contadormov
		clra
movimiento:						;Colocamos personaje y punto 
		ldy	direccion_anterior		;Cargamos en y la direccion anterior
		lda	#'.				;Carga en a el . para que lo sustituya por la posicion actual del jugador
		sta	,y				;Guardamos en la posicion de memoria apuntada por y el punto
		tfr	x,y				;Pone en y la posición a la que pasará el jugador que es la que estaba apuntando X para comprobar qué había
		lda	#'o				;Carga en a el personaje 'o' para que sustituya el caracter que antes ocupaba la nueva posicion del personaje
		sta	,y				;Guardamos en la posicion de memoria apuntada por y el personaje
		stx	direccion_anterior		;Guardamos en direccion anterior la que está apuntando x
		lbra	jugar				;Vuelve a jugar para seguir avanzando en el juego
querer_ir_menu:						;Solicitud querer ir al menu
		clra		
		lda	#1				
		sta	guardado			;Variable utilizada como flag para saber si se guarda la partida
		ldy	desplazamiento_final		;Cargamos en y desplazamiento final que es la posicion de memoria en la que está el personaje
		sty	direccion_guardado		;Guardamos en direccion guardado la posicion de memoria del personaje por si queremos reanudar
		lbra	menu_principal		
				
next_lb:						;Siguiente laberinto, en orden claro	lab n mas uno
		ldx	#setYellow			
		jsr	imprime_cadena
		ldx	#setNegative
		jsr	imprime_cadena
		ldx	#lab_completado
		jsr	imprime_cadena
		ldx	#setNormal
		jsr	imprime_cadena
		ldx	#setBold
		jsr	imprime_cadena
		ldx	#setYellow
		jsr	imprime_cadena
		clra
		clrb
		lda	lv
		inca
		cmpa	laberinto_numero		;Compara si se ha llegado al ultimo laberinto
		bhi	end				;Salto para final del juego
		sta	lv
		clra
		lda	#0
		sta	guardado			;Flag guardado = 0
		ldd	#0
		std	contadormov			;Reseteamos movimiento para el siguiente nivel, contadormov = 0
menu_next_lb:						;Menu para si se desea jugar el siguiente laberinto
		ldx	#menu_next_lv			
		jsr	imprime_cadena	
		lda 	teclado
		cmpa	#'1
		lbeq 	menu_principal			;Salto menu principal
		cmpa 	#'2
		lbeq 	jugardirect			;Salto a jugar directamente el siguiente nivel	
		ldx 	#opcion_erronea
		jsr 	imprime_cadena
		bra 	menu_next_lb			;Inicio bucle while menu_next_lb si no se teclea ninguna opcion valida		
end:							;Final con mensaje de enhorabuena crack
		ldx	#mensaje_victoria
		jsr	imprime_cadena
		ldx	#reiniciar			;Mensaje reiniciar juego o salir de el
		jsr	imprime_cadena
		ldx	#laberintos
		jsr	limpia_laberinto_especifico
final:							;Bucle while opciones menu final
		clra
		lda	teclado
		cmpa	#'1
		lbeq	programa
		cmpa	#'2
		beq	opcion3
		ldx	#opcion_erronea
		jsr	imprime_cadena
		bra	final				;Salto inicio bucle while final
;;;;;;;;;;;;;;;;;;;;;;;;; OPCION 3 = SALIR ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
opcion3: 
		
		ldx	#setUnderlined
		jsr	imprime_cadena
		ldx	#setNegative
		jsr	imprime_cadena
		ldx	 #msg_salida
		jsr 	imprime_cadena
		clra
		sta 	 fin				;Fin del programa
		.area FIJA (ABS) 			;area fija para el vector de reset
		.org 0xFFFE  				;vector de reset, almacena la direccion de la primera instruccion del programa que se va a ejecutar
		.word programa 				;siempre que arranque saltara a la posicion de memoria de programa
