;Archivo: Lab6.s
;Dispositivo: PIC16F887
;Autor: Josue Salazar
; Compilador: pic-as (v2.31), MPLABX v5.45
; 
; Programa: TMR01 Y TMR02
; Hardware: 7 SEGMENTOS EN PUERTO C Y LED EN PUERTO D, TRANSISTORES PARA MULTIPLEX
;
;Creado: 23 mar, 2021
;Ultima Modificacion:    27 mar, 2021
    
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
    movlw   254		    ; valor inicial/ delay suficiente
    movwf   TMR0	    ; se coloca el valor en el inicio 
    bcf	    T0IF	    ; limpiar la bandera del timer para no sobre poner valores
    endm
reiniciarT1 macro
    banksel PORTA	
    movlw   238		    ; valor inicial/ delay suficiente este valor se divide en 2 bytes
    movwf   TMR1L
    movlw   133
    movwf   TMR1H
    bcf	    TMR1IF	 ; limpiar la bandera del timer para no sobre poner valores    
    endm
    
reiniciarT2 macro
    banksel TRISA	
    movlw   245	    ; valor inicial/ delay suficiente
    movwf   PR2	    ; colocar el valor inicial en el registro de comparacion
    
    banksel PORTA
    bcf	    TMR2IF  ; limpiar la bandera del timer para no sobre poner valores
    endm

PSECT udata_shr    ;comoon memory
    W_TEM:	DS 1
    ESTATUS:	DS 1
    cont:	DS 1
PSECT udata_bank0
    var:      DS 1
    banderas: DS 1
    nibbles:  DS 2
    dise:     DS 2
 
    
  
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
    
    btfsc   T0IF	    ; revisar bandera de Timer0
    call    inttimer	    ;interrupcion del timer
    
    btfsc TMR1IF	    ; revisar bandera de Timer1
    call inttimer1	    ;interrupcion del timer
    
    btfsc   TMR2IF	    ; revisar bandera de Timer2
    call inttimer2	    ;interrupcion del timer
    
pop:
    swapf   ESTATUS, W
    movwf   STATUS
    swapf   W_TEM, F
    swapf   W_TEM, W
    retfie
;-------------------------sub rutinas INT-----------------------------------------

inttimer:
  	      
    reiniciarT0
    bcf    PORTD,0
    bcf    PORTD,1
    ;Multiplexiar
    ; Crear un ciclo de condiciones
    btfsc   banderas,0		    ;If bandera,0 entonces ir al display 1
    goto    disp1
    
disp0:
	movf	dise,W		    ; mover el valor a W para colocarlo en el PORTC
	movwf	PORTC
	bsf	PORTD,0		    ; revisar si el bit del transitor que controla el display esta encendido
	goto	sigdis1 ; ir a siguiente display 
	
	
disp1:
	movf	dise+1,W
	movwf	PORTC
	bsf	PORTD,1
	bcf	banderas,0
	return

	
sigdis1:
	movlw   1		;mover 1 a w y realizar un XOR guardado en F 
	xorwf   banderas,F
	return  
	
inttimer1:
    reiniciarT1		;reiniciar para colocar un valor nuevo	
    incf var, F		; incrementar en el contador
    return
inttimer2:
    reiniciarT2		; reiniciar
    btfsc banderas,1	;revisar banderas, si esta apagada entonces 
    goto ON
OFF:
    bsf	    banderas,1	; setear la bandera 
    return
ON:
    bcf	    banderas,1	; limpiar la bandera
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
    call contimer   ; llamar las congiguraciones deL TIMER0
    call coninten   ; llamar las congiguraciones de banderas de interrupciones
    call contimer1  ; llamar las congiguraciones deL TIMER1
    call contimer2  ; llamar las congiguraciones deL TIMER2
   banksel PORTA    
    ;----------loop principal---------------------------------------------------
loop: 
    call    separarnib
    
    btfss   banderas,1	; si la bandera esta apagada entonces 
    call    dison2	; llamar a encender todo
    
    btfsc   banderas,1	; si la  bandera esta prendida entonces
    call apagar		; llamar a apagar
    ; esto se realiza para ver el titileo
    
    
    goto loop
  ;-------------------------sub rutinas-----------------------------------------

io:
     banksel ANSEL 
     clrf    ANSEL 
     clrf    ANSELH
     
    banksel TRISA  
    clrf TRISC
    bcf TRISD,0
    bcf TRISD,1
    bcf	TRISD,2
    
    
 
    banksel PORTA
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
    
contimer1:
    banksel PORTA
    bsf	TMR1ON	    ; habilitamos el TMR1
    bcf TMR1CS	    
    bcf T1OSCEN
    bsf	T1CKPS0
    bsf	T1CKPS1
    bcf	TMR1GE
    
    banksel PORTA
    reiniciarT1
    return
contimer2:
    banksel PORTA  
    bsf	    T2CKPS1 ; en esta parte colocaremos el PreScaler a 1:8
    bsf	    T2CKPS0
    bsf	    TMR2ON  ; habilitaremos el TMR2
    bsf	    TOUTPS3 ; colocaremos el PostScaler a 1:16
    bsf	    TOUTPS2
    bsf	    TOUTPS1
    bsf	    TOUTPS0
    
    banksel TRISA
    reiniciarT2
    return
conclock:
    banksel OSCCON
    bcf	    IRCF0 ;el reloj oscilara a 1MHz
    bcf	    IRCF1 
    bsf	    IRCF2 
    bsf	    SCS	    ; habilitar reloj interno
    
    return
    
coninten:
    ; en esta parte declararemos y colocaremos las banderas necesarias para cada Timer
    banksel PORTA
    bsf	    GIE	    ; INTCON	
    bsf	    PEIE
    
    bsf	    T0IE
    bcf	    T0IF
    ; colocamos las banderas de habilitar interrupcion
    
    banksel TRISA
    bsf	TMR1IE
    bsf TMR2IE
    ; limpiamos las banderas de interrupcion para crear nuestros ciclos
    banksel PORTA
    bcf TMR1IF
    bcf	TMR2IF
   
    return


separarnib:
    ; se separa la varible de nibbles para los primeros contadores que se muestran con el valor de PORT A
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
    movwf   dise
    
    movf    nibbles+1, w
    call    tabla
    movwf   dise+1
    
    bsf	    PORTD,2	    ; Cuando realizemos el conteo necesario y separemos valores, encederemos la led cada 250 ms
    
    return
    
apagar:
    movlw   0
    movwf   dise
    movwf   dise+1
    
    bcf	PORTD,2
    return

    end



