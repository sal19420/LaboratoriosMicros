/* 
 * File:   Lab10.c
 * Author: pablo
 *
 * Created on 4 de mayo de 2021, 9:57
 */

#include <xc.h>// </editor-fold>
#include <stdint.h>
// PIC16F887 Configuration Bit Settings

// 'C' source line config statements
// CONFIG1

#pragma config FOSC = INTRC_NOCLKOUT// Oscillator Selection bits (RC oscillator: CLKOUT function on RA6/OSC2/CLKOUT pin, RC on RA7/OSC1/CLKIN)
#pragma config WDTE = OFF        // Watchdog Timer Enable bit (WDT enabled)
#pragma config PWRTE = ON      // Power-up Timer Enable bit (PWRT disabled)
#pragma config MCLRE = OFF       // RE3/MCLR pin function select bit (RE3/MCLR pin function is MCLR)
#pragma config CP = OFF         // Code Protection bit (Program memory code protection is disabled)
#pragma config CPD = OFF        // Data Code Protection bit (Data memory code protection is disabled)
#pragma config BOREN = OFF       // Brown Out Reset Selection bits (BOR enabled)
#pragma config IESO = OFF        // Internal External Switchover bit (Internal/External Switchover mode is enabled)
#pragma config FCMEN = OFF       // Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is enabled)
#pragma config LVP = ON         // Low Voltage Programming Enable bit (RB3/PGM pin has PGM function, low voltage programming enabled)

// CONFIG2
#pragma config BOR4V = BOR40V   // Brown-out Reset Selection bit (Brown-out Reset set to 4.0V)
#pragma config WRT = OFF        // Flash Program Memory Self Write Enable bits (Write protection off)

//----------------------------------Variables-----------------------------------
const char var = 97;
//--------------------------------valores definidos-----------------------------
#define _XTAL_FREQ 8000000
//---------------------------------prototipos-----------------------------------
void setup (void);
void interrupcion(void);
//-------------------------------interrupciones---------------------------------
void __interrupt()interrupcion(void){
//----------------------------iterrupcion EUSART--------------------------------    
    if(PIR1bits.RCIF){ //revisa si se recibieron datos
        PORTB = RCREG; //Se mandan los datos al puerto b
    }
    return;
}
//------------------------------loop principal----------------------------------
void main(void) {
    setup();
  
    while (1){ 
        //cada 500ms manda datos
        __delay_ms(500);
        
        if (PIR1bits.TXIF){    //revisamos si ya se incia la conversión
            TXREG = var;
        }
    }
    return;
}
//------------------------------configuraciones---------------------------------
void setup(void){
    //Estabalecer que puertos vamos a usar 
    ANSEL = 0b00000000;    
    ANSELH = 0x00;
    
    //TRISA = 0b00000000;     //Primeros dos pines de puerto A como entrada 
    TRISB = 0x00;     //Puerto B como salida
   
    //PORTA = 0X00;           //Limpiar puertos
    PORTB = 0x00;
    
    //configuracion de reloj
    OSCCONbits.SCS = 1;     //RELOJ INTERNO
    OSCCONbits.IRCF = 0b111;   //OSCILADOR DE 8MHz 111
    
    //Configuración del RX y TX
    TXSTAbits.SYNC = 0;     //modo sincrono desabilitado
    TXSTAbits.BRGH = 1;     //Bound rate High
    BAUDCTLbits.BRG16 = 1;  //16 bits para generar fire brake
    
    SPBRG = 207;    //SPBRG con 0.16% de error
    SPBRGH = 0;
    
    RCSTAbits.SPEN = 1; //Puertos seriales 
    RCSTAbits.RX9 = 0;  //No se van a recibir 9 bits
    RCSTAbits.CREN = 1; //habilitar recepción
    TXSTAbits.TXEN = 1; //habilitar transmisión
  
    //Configuracion de interrupciones
    INTCONbits.GIE = 1;
    PIR1bits.RCIF = 0;
    PIE1bits.RCIE = 1;
    INTCONbits.GIE = 1;   
    return;
}