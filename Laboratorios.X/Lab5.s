;Archivo: Lab5.s
;Dispositivo: PIC16F887
;Autor: Josue Salazar
; Compilador: pic-as (v2.31), MPLABX v5.45
; 
; Programa: Displays simultaneos
; Hardware: Leds en el puerto A. PushBotons en el puerto B, 7 segmentos en el puerto D y C
;
;Creado: 2 mar, 2021
;Ultima Modificacion:   06 mar, 2021
    
PROCESSOR 16F887

#include <xc.inc>

; CONFIG1
  CONFIG  FOSC = INTRC_NOCLKOUT ; Oscillator Selection bits (INTOSCIO oscillator: I/O function on RA6/OSC2/CLKOUT pin, I/O function on RA7/OSC1/CLKIN)
  CONFIG  WDTE = OFF            ; Watchdog Timer Enable bit (WDT disabled and can be enabled by SWDTEN bit of the WDTCON register)
  CONFIG  PWRTE = ON            ; Power-up Timer Enable bit (PWRT enabled)
  CONFIG  MCLRE = OFF           ; RE3/MCLR pin function select bit (RE3/MCLR pin function is digital input, MCLR internally tied to VDD)
  CONFIG  CP = OFF              ; Code Protection bit (Program memory code protection is disabled)
  CONFIG  CPD = OFF             ; Data Code Protection bit (Data memory code protection is disabled)
  CONFIG  BOREN = OFF           ; Brown Out Reset Selection bits (BOR disabled)
  CONFIG  IESO = OFF            ; Internal External Switchover bit (Internal/External Switchover mode is disabled)
  CONFIG  FCMEN = OFF           ; Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is disabled)
  CONFIG  LVP = ON              ; Low Voltage Programming Enable bit (RB3/PGM pin has PGM function, low voltage programming enabled)

; CONFIG2
  CONFIG  BOR4V = BOR40V        ; Brown-out Reset Selection bit (Brown-out Reset set to 4.0V)
  CONFIG  WRT = OFF             ; Flash Program Memory Self Write Enable bits (Write protection off)
;--------------macros---------------------------------------------------

reiniciarT0 macro
    banksel PORTA	
    movlw   178		    ; valor inicial/ delay suficiente
    movwf   TMR0
    bcf	    T0IF
    endm
  
PSECT udata_shr    ;comoon memory
    W_TEM:	DS 1
    ESTATUS:	DS 1
    cont:	DS 1
PSECT udata_bank0
    var:      DS 1
    banderas: DS 1
    nibbles:  DS 2
    UNI:      DS 1
    DECE:     DS 1
    CEN:      DS 1
    dise:     DS 8
    verif:    DS 3
    
  
  PSECT resVect, class=CODE, abs, delta=2
  ;--------------vector reset---------------------------------------------------
  ORG 00h	 ;posicion 0000h para el reset
  resetVec: 
      PAGESEL main
      goto main
PSECT intVect, class=CODE, abs, delta=2
;--------------vector interrupcion---------------------------------------------------
 ORG 04h
 
 push:
    movwf   W_TEM	    ; guardar valores en status 
    swapf   STATUS, W
    movwf   ESTATUS
    
 isr:
    btfsc   RBIF	    ; revisar bandera 
    call    INTIOCB	    ;Interrupt onchange Port b
    
    btfsc   T0IF	    ; revisar bandera de Timer0
    call    inttimer	    ;interrupcion del timer
    
pop:
    swapf   ESTATUS, W
    movwf   STATUS
    swapf   W_TEM, F
    swapf   W_TEM, W
    retfie
;-------------------------sub rutinas INT-----------------------------------------
INTIOCB: 
    banksel PORTA	    ; revisar botones e incrementar si se suelta 
    btfsc   PORTB,0
    incf    PORTA
    
    btfsc   PORTB, 1
    decf    PORTA
    
    bcf	    RBIF	    ; limpiar la bandera, pare reiniciar el conteo
    return
  
inttimer:
  	      
    reiniciarT0
    bcf    PORTB,2
    bcf    PORTB,3
    bcf    PORTB,4
    bcf    PORTB,5
    bcf    PORTB,6
    bcf    PORTB,7
    ;Multiplexiar
    ; Crear un ciclo de condiciones
    btfsc   banderas,0		    ;If bandera,0 entonces ir al display 1
    goto    disp1
    btfsc   banderas,1		    ;If bandera,1 entonces ir al display 2
    goto    disp2
    btfsc   banderas,2		    ;If bandera,2 entonces ir al display 3  
    goto    disp3
    btfsc   banderas,3		    ;If bandera,3 entonces ir al display 4
    goto    disp4
    btfsc   banderas,4		    ;If bandera,4 entonces ir al display 5
    goto    disp5
    
disp0:
	movf	dise,W		    ; mover el valor a W para colocarlo en el PORTC
	movwf	PORTC
	bsf	PORTB,2		    ; revisar si el bit del transitor que controla el display esta encendido
	goto	sigdis1		    ; ir a siguiente display 
	
	
disp1:
	movf	dise+1,W
	movwf	PORTC
	bsf	PORTB,3
	goto	sigdis2
disp2:
	movf	dise+2,W
	movwf	PORTD
	bsf	PORTB,4
	goto	sigdis3
disp3:
	movf	dise+3,W
	movwf	PORTD
	bsf	PORTB,5
	goto	sigdis4
disp4:
	movf	dise+4,W
	movwf	PORTD
	bsf	PORTB,6
	goto	sigdis5
disp5:
	movf	dise+5,W
	movwf	PORTD
	bsf	PORTB,7
	goto	sigdis0
	
sigdis1:
	movlw   1		;mover 1 a w y realizar un XOR guardado en F 
	xorwf   banderas,F
	return
sigdis2:
	movlw   3
	xorwf   banderas,F
	return
sigdis3:
	movlw   6
	xorwf   banderas,F
	return
sigdis4:
	movlw   12
	xorwf   banderas,F
	return
sigdis5:
	movlw   24
	xorwf   banderas,F
	return 
    
 sigdis0:
	clrf	banderas,F
	
	return   
    
    
    
    
  PSECT code, delta=2, abs
  ORG 100h	; posicion para la tabla 
  tabla: 
    clrf    PCLATH
    bsf	    PCLATH,0 ; PCLATH = 01
    andlw   0x0f
    addwf   PCL 
    retlw   00111111B ;0
    retlw   00000110B ;1
    retlw   01011011B ;2
    retlw   01001111B ;3
    retlw   01100110B ;4
    retlw   01101101B ;5
    retlw   01111101B ;6
    retlw   00000111B ;7
    retlw   01111111B ;8
    retlw   01101111B ;9
    retlw   01110111B ;A
    retlw   01111100B ;B
    retlw   00111001B ;C
    retlw   01011110B ;D
    retlw   01111001B ;E
    retlw   01110001B ;F
    
  /*PSECT code, delta=2, abs
    ORG 114h */
  ;------------configuracion----------------------------------------------------
main:	
    

    call io	    ; llamar las congiguraciones de entrada y salida	
    call conclock   ; llamar las congiguraciones del reloj interno
    call contimer   ; llamar las congiguraciones deL TIMER
    call coninten   ; llamar las congiguraciones de banderas de interrupciones
    call coniocb    ; llamar las congiguraciones de interrupt on change port b
    
    banksel PORTA   
  
    
    ;----------loop principal---------------------------------------------------
loop: 
;    call dison		; subrutina para copiar leds en 7seg
    movf    PORTA, W	; colocar el valor del los leds en W
    movwf   verif	; mover el valor a una variable de almacenamiento para no alterar el PORTA
    call    centenas	; llamar sub rutina de division
    call    separarnib
    call    dison2
    goto loop
  ;-------------------------sub rutinas-----------------------------------------
coniocb:
    banksel TRISA
    bsf	    IOCB, 0	; HABILITAR INT EN EL PORT B
    bsf	    IOCB, 1
    
    banksel PORTA
    movf    PORTB, W
    bcf	    RBIF   
    
    return 

io:
     banksel ANSEL 
     clrf    ANSEL 
     clrf    ANSELH
     
    banksel TRISA  
    clrf TRISA ; salidas para leds
    
    movlw 003h
    movwf TRISB ; colocar portB como entradas
    
    clrf TRISC  ; colocar portC como salidas
    
    clrf TRISD  ; colocar portD como salidas
    
    bcf	  OPTION_REG, 7 ; HABILITAR PULL UP 
    bsf	  WPUB, 0	  
    bsf	  WPUB, 1
 
    banksel PORTA
    clrf PORTA
    clrf PORTB
    clrf PORTC
    clrf PORTD
    return
    
contimer:
    banksel TRISA
    bcf	    T0CS ;RELOJ interno
    bcf	    PSA	; PRESCALER, se asigna al timer0
    bsf	    PS2
    bsf	    PS1
    bsf	    PS0; PS=111, velocidad de seleccion
    banksel PORTA
    reiniciarT0
    return


conclock:
    banksel OSCCON
    bsf	    IRCF0 
    bsf	    IRCF1 
    bsf	    IRCF2 
    bsf	    SCS	    ; habilitar reloj interno
    
    return
    
coninten:
    banksel PORTA
    bsf	    GIE	    ; INTCON	
    bsf	    RBIE    ; habilitar interrupcion
    bcf	    RBIF    ; cambio en la bandera
    bsf	    T0IE
    bcf	    T0IF


separarnib:
    ; se separa la varible de nibbles para los primeros contadores que se muestran con el valor de PORT A
    movf     PORTA, W
    movwf    var
    
    movf    var,W
    andlw   0x0f
    movwf   nibbles
    swapf   var, W
    andlw   0x0f
    movwf   nibbles+1
    return
    
dison2: 
	; aqui se preparan los displays, quiere decir que se coloca el valor que corresponde a cada 1
    movf    nibbles, w
    call    tabla
    movwf   dise,F
    
    movf    nibbles+1, w
    call    tabla
    movwf   dise+1,F
    
    movf    UNI,W
    call    tabla
    movwf   dise+2
    
    movf    DECE,W
    call    tabla
    movwf   dise+3
    
    movf    CEN,W
    call    tabla
    movwf   dise+4
    
    movlw    00111111B
    movwf   dise+5
    
    return
    
    centenas: 
	clrf	CEN	    ;limpiar variable donde se guardaran las centenas    
	movlw	100	    ;mover 100 a w
	subwf	verif, W    ;restar 100 al valor del PORT A
	btfsc	STATUS, 0   ;skip if el carry esta en 0
	incf	CEN	    ;incrementar el contador de la variable centena
	btfsc	STATUS, 0   ;skip if el carry esta en 0
	movwf	verif	   ; mover el valor de la resta a w
	btfsc	STATUS, 0   ;skip if el carry esta en 0
	goto	$-7	    ; si es posible restar 100 entonces realizar todo el proceso
	call	decenas	    ; si el numero ya no se puede restar 100 entonces ir a decenas
	return
    decenas:
	clrf DECE	    ;limpuiar la variable donde se guardan las decenas	
	movlw	10	    ;mover 10 a w
	subwf	verif, W    ;restar 10 al valor del PORT A
	btfsc	STATUS, 0   ;skip if el carry esta en 0
	incf	DECE	    ; incrementar el contador de la variable decenas
	btfsc	STATUS, 0   ;skip if el carry esta en 0
	movwf	verif	    ; mover el valor de la resta a w
	btfsc	STATUS, 0   ;skip if el carry esta en 0
	goto	$-7	    ; si se puede seguir restando 10 entonces realizar todo el proceso
	call unidades	    ; si ya no se puede restar 10, por que la bandera de carry se encendio entonces ir a unidades
	return
    unidades:
	clrf UNI	    ;limpiar la variable donde se guardan las unidades
	movlw	1	    ;mover 1 a w
	subwf	verif, F    ; restar 1 al valor del PORT A
	btfsc	STATUS, 0   ;skip if el carry esta en 0
	incf	UNI	    ; incrementar el contador de la variable unidades
	btfss	STATUS, 0   ; si tenemos un carry en el valor entonces realizar otra vez el proceso
	return		    ; si no se puede seguir restando 1 erntonces se regresa al stack 
	goto $-6
    end


