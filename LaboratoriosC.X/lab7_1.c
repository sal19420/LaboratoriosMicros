/* 
 * File:   Lab07.c
 * Author: Josue Salazar
 *
 * Created on 13 de abril de 2021, 03:01 PM
 * Modified on 17 de abril de 2021
 * Contador en C
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
char display[10] = {0X3F,0X06,0X5B,0X04F,0X66,0X6D,0X7D,0X07,0X7F,0X67};
//Aqui se definen las variables para las 
//conversiones a decimal y el multiplexado
int banderas;
int UNI;
int DECE;
int CEN;
int cont;
int res;


///////Prototipos////////
void confi(void);
void ISR (void);
int  division(void);


/////Interrupcion///////////

void __interrupt() ISR(void){
    if(T0IF == 1){
     PORTB = 0X00;
     
       if (banderas == 0b00000000){// Cuando la interrupcion del timer 0 se
         PORTBbits.RB4 = 0;        // encienda, entonces revisara la variable 
         PORTBbits.RB2 = 1;        // banderas y encendera mi display 
         PORTD = (display[UNI]);   // correspondiente y colocar el valor deseado
         banderas = 0b00000001;   
        }
     else if (banderas == 0b00000001){
         PORTBbits.RB2 = 0;
         PORTBbits.RB3 = 1;
         PORTD = (display[DECE]);
         banderas = 0b00000010;   
        }
     else if (banderas == 0b00000010){
         PORTBbits.RB4 = 1;
         PORTBbits.RB3 = 0;
         PORTD = (display[CEN]);
         banderas = 0b00000000;   
            }
     TMR0 = _TMR0_VALUE;
     INTCONbits.T0IF = 0;
     
        }
     
     if (RBIF == 1){
        if (RB0 == 0){       //Aqui se hara el contador con los botones
            PORTC++;         //si el boton 1 se presiona entonces se incrtementa en
        }                    // el puerto C y si el boton dos se presiona 
        if (RB1 == 0){       //entonces se decrementa el puerto C
            PORTC-- ;  
        }
        INTCONbits.RBIF = 0;
      }

    return;
}

/*
 * 
 */
void main(void) {
    confi();// llamamos a nuestras configuraciones
    while(1){   
        division();//creamos un loop y llamamos a la funcion de divison y que la0
        cont = PORTC;   //variable contador reciba el valor que posee el puertoC
    }
        
}
void confi(void){
  ANSEL = 0X00;
  ANSELH = 0X00;
  //Aqui configuramos entradas y salidas
  TRISB = 0X03;
  TRISC = 0X00;
  TRISD = 0X00;
  
  PORTB = 0X00;
  PORTC = 0X00;
  PORTD = 0X00;
  
  // colocamos nuestro oscilador interno en 8Mhz
  OSCCONbits.IRCF2 = 1;
  OSCCONbits.IRCF1 = 1;
  OSCCONbits.IRCF0 = 1; 
  OSCCONbits.SCS = 1;
  
  //Llamamos a las banderas del timer 0
  INTCONbits.GIE = 1;
  INTCONbits.T0IE = 1;
  INTCONbits.T0IF = 0;
  //configuramos el timer 0
  OPTION_REGbits.PSA = 0; 
  OPTION_REGbits.T0CS = 0; 
  OPTION_REGbits.PS2 = 1; 
  OPTION_REGbits.PS1 = 1; 
  OPTION_REGbits.PS0 = 1; 
  // aqui llamamos a las banderas de los Pulll up del puerto B y a las IOC 
  OPTION_REGbits.nRBPU = 0;
  WPUBbits.WPUB0 = 1;
  WPUBbits.WPUB1 = 1;
  IOCBbits.IOCB0 = 1;
  IOCBbits.IOCB1 = 1;
  // inicializamos el valor de la bandera que ayuda a nuestro multiplexado
  banderas = 0b00000000;
  
  
  
  TMR0 = _TMR0_VALUE; 
  return;
  
}
// esta es la funcion de division 
int division(void){
    CEN = cont/100; //declaramos que el valor de la centena estara dada por el 
                    //valor del puerto C dividido 100
    res = cont%100; // el residuo de la division anterior sera colocado en otra 
                    //variable
    DECE = res/10;  // la variable antes mencionada se dividira por 10 y se 
                    // encontraran las decenas
    UNI = res%10;   // el residuo de la operacion anterior seran nuestras unidades
}
