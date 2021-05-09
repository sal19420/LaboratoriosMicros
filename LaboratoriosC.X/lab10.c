/*
 * File:   lab10.c
 * Author: Josue Salazar
 *
 * Created on 4 de mayo de 2021, 11:31 PM
 */
// CONFIG1
#pragma config FOSC = INTRC_NOCLKOUT// Oscillator Selection bits (INTOSCIO oscillator: I/O function on RA6/OSC2/CLKOUT pin, I/O function on RA7/OSC1/CLKIN)
#pragma config WDTE = OFF       // Watchdog Timer Enable bit (WDT disabled and can be enabled by SWDTEN bit of the WDTCON register)
#pragma config PWRTE = ON       // Power-up Timer Enable bit (PWRT enabled)
#pragma config MCLRE = OFF      // RE3/MCLR pin function select bit (RE3/MCLR pin function is digital input, MCLR internally tied to VDD)
#pragma config CP = OFF         // Code Protection bit (Program memory code protection is disabled)
#pragma config CPD = OFF        // Data Code Protection bit (Data memory code protection is disabled)
#pragma config BOREN = OFF      // Brown Out Reset Selection bits (BOR disabled)
#pragma config IESO = OFF       // Internal External Switchover bit (Internal/External Switchover mode is disabled)
#pragma config FCMEN = OFF      // Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is disabled)
#pragma config LVP = ON         // Low Voltage Programming Enable bit (RB3/PGM pin has PGM function, low voltage programming enabled)

// CONFIG2
#pragma config BOR4V = BOR40V   // Brown-out Reset Selection bit (Brown-out Reset set to 4.0V)
#pragma config WRT = OFF        // Flash Program Memory Self Write Enable bits (Write protection off)

// #pragma config statements should precede project file includes.
// Use project enums instead of #define for ON and OFF.

#include <xc.h>
#include <stdint.h>
#include <stdio.h>

#define _XTAL_FREQ 8000000 

//variables ///////

///////Prototipos////////
void confi(void);
void putch(char DATA); //Funcion especial para la comunicacion
void texto(void);      // funcion de modos


//ciclo
void main(void) {
    confi();
    
    while(1){
        texto();
    }
    return;
}

void putch(char DATA){
    while (TXIF == 0);
    TXREG = DATA; // guardar el dato de la comunicacion
    return;
    
}

void texto(void){
    __delay_ms(250);// tiempo de despliegue de los modos
    printf("\r Escoga una opcion: \r");
     __delay_ms(250);
    printf("\r 1. Desplegar cadena de caracteres: \r");
     __delay_ms(250);
    printf("\r 2. Desplegar PORTA: \r");
     __delay_ms(250);
    printf("\r 3. Desplegar PORTB: \r");
     __delay_ms(250);
    printf("\r 4. BONUS \r");
    while(RCIF == 0);
  
    if (RCREG =='1'){ // Seleccion de modos por medio de caracteres en el teclado
         __delay_ms(250);
         printf("\r WAO SIENTO QUE ME GUSTA DEMASIAUUUU \r");
         
    }
    if (RCREG == '2'){
        printf("\r Insertar caracter para colocar en PORTA: \r");
        while (RCIF == 0);
        PORTA = RCREG;
    }
    
    if (RCREG == '3'){
        printf("\r Insertar caracter para colocar en PORTB: \r");
        while (RCIF == 0);
        PORTB = RCREG;
    }
     if (RCREG =='4'){
         __delay_ms(250);
         printf("\r Colocar wao en youtube \r");
         
    }
    
    else {
        NULL; // si no es el caracter que se espera entones no hacer nada
        
    }
        
   return; 

}

void confi(void){
  ANSEL = 0b00000000;
  ANSELH = 0X00;
  //Aqui configuramos entradas y salidas
  TRISA = 0X00;
  TRISB = 0X00;
 
  
  PORTA = 0X00;
  PORTB = 0X00;
 
  // colocamos nuestro oscilador interno en 8Mhz
  OSCCONbits.IRCF2 = 1;
  OSCCONbits.IRCF1 = 1;
  OSCCONbits.IRCF0 = 1; 
  OSCCONbits.SCS = 1;
  
  //Configuracion de interrupciones
  PIR1bits.ADIF = 0;
  PIE1bits.ADIE = 1;
  INTCONbits.PEIE = 1;
  INTCONbits.GIE = 1;
  PIE1bits.RCIE = 1;
  PIE1bits.TXIE = 1;
  PIR1bits.TXIF = 0;
  PIR1bits.RCIF = 0;
  
  
  // Configuracion de TX y RX
  TXSTAbits.SYNC = 0;
  TXSTAbits.BRGH = 1;
  
  BAUDCTLbits.BRG16 = 1;
  
  SPBRG = 207;
  SPBRGH = 0;
  
  RCSTAbits.SPEN = 1;
  RCSTAbits.RX9 = 0;
  RCSTAbits.CREN = 1;
  
  TXSTAbits.TXEN = 1;
  
  

  return;
}
