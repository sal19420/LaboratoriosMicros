;Archivo: Lab4.s
;Dispositivo: PIC16F887
;Autor: Josue Salazar
; Compilador: pic-as (v2.31), MPLABX v5.45
; 
; Programa: Interrupciones en el Puerto B
; Hardware: Leds en el puerto A. PushBotons en el puerto B, 7 segmentos en el puerto D y C
;
;Creado: 23 feb, 2021
;Ultima Modificacion:  27 feb, 2021
    
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


PSECT udata_shr    ;comoon memory
    cont:	DS 2  ; 2 byte
    W_TEM:	DS 1
    ESTATUS:	DS 1
    dise:	DS 1
    
  
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
    btfss   PORTB,0
    incf    PORTA
    
    btfss   PORTB, 1
    decf    PORTA
    
    bcf	    RBIF	    ; limpiar la bandera, pare reiniciar el conteo
    return
  
inttimer:
    banksel PORTA   
    incf    cont	    ; si la bandera del timer0 es 1 entonces incrementar
    call    reiniciarT0
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
    call io
    call conclock
    call contimer
    call coninten
    call coniocb
    
    banksel PORTA   
  
    
    ;----------loop principal---------------------------------------------------
loop: 
    call dison		; subrutina para copiar leds en 7seg
    call delay_1s	; delay del timer0 en 1s= 1000ms
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
    movlw 0F0h
    movwf  TRISA ; salidas para leds
    
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
    call reiniciarT0
    return
    
reiniciarT0:    
    movlw   178		    ; valor inicial/ delay suficiente
    movwf   TMR0
    bcf	    T0IF
    return 
    
delay_1s:
    movlw   100
    subwf   cont, W
    btfss   STATUS, 2
    return
    incf   dise
    movf   dise, W
    call   tabla 
    movwf PORTD
    clrf cont
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
    return
dison: 
    movf PORTA, W
    call tabla
    movwf PORTC, F
    return


end