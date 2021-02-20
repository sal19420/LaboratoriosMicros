;Archivo: Lab3.s
;Dispositivo: PIC16F887
;Autor: Josue Salazar
; Compilador: pic-as (v2.31), MPLABX v5.45
; 
; Programa: Timer0, contador y alerta
; Hardware: Leds en el puerto C, D. PushBotons en el puerto B, 7 segmentos en el puerto D.
 ;
;Creado: 16 feb, 2021
;Ultima Modificacion: 20 feb, 2021
    
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
    cont: DS 2  ; 2 byte
  
  PSECT resVect, class=CODE, abs, delta=2
  ;--------------vector reset---------------------------------------------------
  ORG 00h	 ;posicion 0000h para el reset
  resetVec: 
      PAGESEL main
      goto main
      
  PSECT code, delta=2, abs
  ORG 100h	; posicion para el codigo 
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
    banksel PORTA   
  
    
    ;----------loop principal---------------------------------------------------
loop: 
    btfss T0IF
    goto  $-1
    call reiniciarT0
    incf PORTC,1
    
    btfsc PORTB, 0   ; si el boton de incrementar para el contador 1 entonces
    call  sumcont_1
    
    btfsc PORTB, 1   ; si el boton de decrementar para el contador 1 entonces
    call  rescont_1  ; llamar a sub rutina para decrementar 1
    
    bcf	PORTE,0
    call alarma
    
    goto loop
  ;-------------------------sub rutinas-----------------------------------------
 

io:
     banksel ANSEL 
     clrf    ANSEL 
     clrf    ANSELH
     
    banksel TRISA  
    
    movlw 002h
    movwf TRISB ; colocar portB como entradas
    
    movlw 0F0h
    movwf TRISC  ; colocar portC como salidas
    
   
    clrf TRISD  ; colocar portD como salidas
    
    movlw 0FEh
    movwf TRISE
    
    banksel PORTA
    clrf PORTB
    clrf PORTC
    clrf PORTD
    clrf PORTE
    return
    
conclock:
    banksel OSCCON
    bsf	    IRCF0 
    bsf	    IRCF1 
    bcf	    IRCF2 
    bsf	    SCS	    ; habilitar reloj interno
    
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
    movlw   12
    movwf   TMR0
    bcf	    T0IF
    return 
    
sumcont_1:
    btfsc PORTB, 0  ; Cuando se active el primer bit en esta caso PB1
    goto  $-1		; ejecutar una linea atras
    incf  cont		; Incrementar en el contador 1
    movf  cont, 0
    call  tabla
    movwf PORTD, 1
    return
    
rescont_1:
    btfsc PORTB, 1  ; Cuando se active el segundo bit en esta caso PB2
    goto  $-1		; ejecutar una linea atras
    decf  cont		 ; decrementar el contador 1
    movf  cont, 0
    call  tabla
    movwf PORTD, 1
    return

    
alarma:
    movf    cont,0
    subwf   PORTC,0
    btfsc   STATUS,2
    call    alarmaenc
    return

    
alarmaenc:
    bsf	PORTE,0
    clrf    PORTC
    return
    
    
end