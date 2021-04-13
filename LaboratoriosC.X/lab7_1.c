/* 
 * File:   Lab07.c
 * Author: Josue Salazar
 *
 * Created on 13 de abril de 2021, 03:01 PM
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

#define _XTAL_FREQ 8000000 
#define _TMR0_VALUE 217
////////////DEFINICION DE VARIABLES 

unsigned char cont = 1;
///////Prototipos////////
void confi(void);
void inttimer0 (void);


/////Interrupcion///////////

void __interrupt() inttimer0(void){
    if(T0IF == 1){
    PORTD++;
    
    TMR0 = _TMR0_VALUE;
    INTCONbits.T0IF = 0;
    }
    
    if (RBIF == 1){
        if (RB0 == 0){
            PORTC = PORTC + 1; 
        }
        if (RB1 == 0){
            PORTC = PORTC - 1 ;  
        }
        INTCONbits.RBIF = 0;
    }
    
    //return;
}

/*
 * 
 */
void main(void) {
    confi();
    while(1){
    }
        
}
void confi(void){
  ANSEL = 0X00;
  ANSELH = 0X00;
  
  TRISB = 0X03;
  TRISC = 0X00;
  TRISD = 0X00;
  
  PORTB = 0X00;
  PORTC = 0X00;
  PORTD = 0X00;
  
  
  OSCCONbits.IRCF2 = 1;
  OSCCONbits.IRCF1 = 1;
  OSCCONbits.IRCF0 = 1; 
  OSCCONbits.SCS = 1;
  
  
  INTCONbits.GIE = 1;
  INTCONbits.T0IE = 1;
  INTCONbits.T0IF = 0;
  
  OPTION_REGbits.PSA = 0; 
  OPTION_REGbits.T0CS = 0; 
  OPTION_REGbits.PS2 = 1; 
  OPTION_REGbits.PS1 = 1; 
  OPTION_REGbits.PS0 = 1; 
  
  OPTION_REGbits.nRBPU = 0;
  WPUBbits.WPUB0 = 1;
  WPUBbits.WPUB1 = 1;
  IOCBbits.IOCB0 = 1;
  IOCBbits.IOCB1 = 1;
  
  
  
  
  TMR0 = _TMR0_VALUE; 
  return;
  
}
