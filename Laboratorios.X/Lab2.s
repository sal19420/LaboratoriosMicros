;Archivo: Lab2.1.s
;Dispositivo: PIC16F887
;Autor: Josue Salazar
; Compilador: pic-as (v2.31), MPLABX v5.45
; 
; Programa: contador en el puerto A
; Hardware: Leds en el puerto A, C, D. PushBotons en el puerto B. 
;
;Creado: 9 feb, 2021
;Ultima Modificacion: 12 feb, 2021
    
PROCESSOR 16F887

#include <xc.inc>

; CONFIG1
  CONFIG  FOSC = EXTRC_CLKOUT ; Oscillator Selection bits (INTOSCIO oscillator: I/O function on RA6/OSC2/CLKOUT pin, I/O function on RA7/OSC1/CLKIN)
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

PSECT udata_bank0 ;common memory
  cont_1:   DS 1;1byte
  cont_2:   DS 1
  dcont_1:  DS 1
  dcont_2:  DS 1
  sumat_J:   DS 1

PSECT resVect, class=CODE, abs, delta=2
;-----------vector reset---------
ORG 00h
resetVec: 
    PAGESEL main
    goto main
    
PSECT code, delta=2, abs
ORG 100h  ;posicion pare el codigo 
;-----------configuracion------------
main:
    banksel ANSEL ;banco 11
    clrf ANSEL    ;PINES DIGITALES I/O
    clrf ANSELH
    
    banksel TRISA  
    movlw 0F0h
    movwf TRISA	; colocar portA como salidas
    
    movlw 01Fh
    movwf TRISB ; colocar portB como entradas
    
    movlw 0F0h
    movwf TRISC  ; colocar portC como salidas
    
    movlw 0E0h
    movwf TRISD  ; colocar portD como salidas
    
    
    banksel PORTA
    clrf PORTA
    clrf PORTB
    clrf PORTC
    clrf PORTD
    

;-----------loop general------------    
loop: 
    btfsc PORTB, 0   ; si el boton de incrementar para el contador 1 entonces
    call  sumcont_1  ; llamar a sub rutina para incrementar 1
    btfsc PORTB, 1   ; si el boton de decrementar para el contador 1 entonces
    call  rescont_1  ; llamar a sub rutina para decrementar 1
    
    btfsc PORTB,2   ; si el boton de incrementar para el contador 2 entonces
    call sumcont_2  ; llamar a sub rutina para incrementar contador 2
    btfsc PORTB,3   ; si el boton de decrementar para el contador 2 entonces
    call rescont_2  ; llamar a sub rutina para decrementar contador 2
    
    btfsc PORTB,4   ; si el boton de suma entonces
    call suma_J     ; llamar a sub rutina para hacer la sumatoria
    
    goto loop ;loop forever
    
 ;-----------SUB RUTINAS------------     
sumcont_1:
    btfsc PORTB, 0  ; Cuando se active el primer bit en esta caso PB1
    goto  $-1		; ejecutar una linea atras
    incf  PORTA, 1	; Incrementar en el contador 1
    return
    
rescont_1: 
    btfsc PORTB, 1  ; Cuando se active el segundo bit en esta caso PB2
    goto  $-1		; ejecutar una linea atras
    decf  PORTA, 1  ; decrementar el contador 1
    return

sumcont_2:
    btfsc PORTB, 2  ; Cuando se active el tercer bit en esta caso PB3
    goto  $-1		; ejecutar una linea atras
    incf  PORTC, 1  ; incrementar en el contador 2
    return
    
rescont_2: 
    btfsc   PORTB, 3	; Cuando se active el cuarto bit en esta caso PB4
    goto    $-1		; ejecutar una linea atras
    decfsz  PORTC, 1	; decrementar en el contador 2
    return
;-----------------suma-------------------------
suma_J: 
    btfsc   PORTB, 4	; Cuando se active el quinto bit en esta caso PB5
    goto    $-1	
    
    movf    PORTA,0	 ; Colocar el valor del primer contador en w
    addwf   PORTC,0	 ; Sumar el valor del segundo contador en w
    movwf   PORTD	 ; Mover w al puerto D, en este caso los leds
    return

    
end
