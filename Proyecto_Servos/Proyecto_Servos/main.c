/*
 * Proyecto.c
 *
 * Created: 28/04/2025 16:41:35
 * Author : Ren? Gonz?lez
 */ 

/****************************************/// Encabezado (Libraries)#define F_CPU 16000000#include <avr/io.h>#include <avr/interrupt.h>#include <avr/eeprom.h>#include <stdlib.h>#include <util/delay.h>#include "ADC/ADClib.h"#include "PWM1/PWM.h"
#define NUM_CONFIGS 4
#define CONFIG_SIZE 8typedef struct {
	uint16_t servo1;
	uint16_t servo2;
	uint16_t servo3;
	uint16_t servo4;
} ServoConfig;
volatile uint8_t direccionEscribir = 0; //para las 4 posiciones a guardar. volatile int contador=0;uint16_t conversion1=0;//Lecturas de ADCuint16_t servo1=0;uint16_t conversion2=0;uint16_t servo2=0;uint16_t conversion3=0;uint16_t servo3=0;uint16_t conversion4=0;uint16_t servo4=0;volatile int modo=1; //Modo manual, guardado, adafuit.uint8_t direccionLeer = 0;char mensaje[5];//interrupccion RXvolatile uint8_t indice=0;//Caracteres de mensajevolatile int cambioAdafruit=0;/****************************************/// Function prototypesvoid setup();void initUart();void writeEEPROM(uint16_t addr, const void *data, uint8_t len);void Guardarconfiguracion();void Gconf_actual();void loadConfiguration(uint8_t config_num);/****************************************/// Main Functionint main(){		setup();	while (1)
	{
		switch(modo)
		{
			case 1:
				movservo1(servo1);
				movservo2(servo2);
				movservo3(servo3);
				movservo4(servo4);
				break;
			case 2:
				if (!(PINC & (1 << PINC1)))//PC1 Guardar
				{
					_delay_ms(50); 
					if (!(PINC & (1 << PINC1))) 
					{
						//Si si se apacho el de guardar, guardamos
						Guardarconfiguracion();
						// Esperamos hasta que se suelte el boton
						while(!(PINC & (1 << PINC1)));
						for(uint8_t i = 0; i <= direccionEscribir; i++) 
						{
							PORTB |= (1 << PORTB5);
							_delay_ms(100);
							PORTB &= ~(1 << PORTB5);
							_delay_ms(100);
						}
					}
				}
				else if (!(PINC & (1 << PINC0))) // Botón PC0 presionado (Cargar)
				{
					_delay_ms(50);
					if (!(PINC & (1 << PINC0)))
					{
						Gconf_actual();
						while(!(PINC & (1 << PINC0))); // Esperar a soltar
						for(uint8_t i = 0; i <= direccionLeer; i++)
						{
							PORTB |= (1 << PORTB5);
							_delay_ms(100);
							PORTB &= ~(1 << PORTB5);
							_delay_ms(100);
						}
					}
				}
				break;
			case 3:
				//Modo adafruit, recibir las posciciones Servo1, Servo2, Servo3, Motor DC.
				//Apagamos la conversion de ADC´s.
				if (cambioAdafruit==1)
				{
					cambioAdafruit=0;
					char Pwm=mensaje[0];
					uint8_t valor = atoi(&mensaje[1]);
					
					switch(Pwm)
					{
						case 'A':
							servo1=1200+(valor*14.12);
							movservo1(servo1);
							break;
						case 'B':
							servo2= 1200+(valor*14.12);
							movservo2(servo2);
							break;
						case 'C':
							servo3= 9.08+(valor*0.106);
							movservo3(servo3);
							break;
						case 'D':
							servo4=  9.08+(valor*0.106);
							movservo4(servo4);
							break;
						default:
							break;
					}
				}
				
				break;
		}
	}}/****************************************/// NON-Interrupt subroutinesvoid setup(){	cli();	DDRB |= (1 << DDB4)|(1 << DDB0);	DDRC=0;	PORTC=0; //Puerto c como entrada, estaran los ADC?s	PORTC |= (1 << PORTC2)|(1<<PORTC1)|(1<<PORTC0);// PUll up en pc2	PCICR |= (1<<PCIE1);	PCMSK1 |= (1<<PCINT10); //PINCHANGE PC2	initUart();	initADC();	initPWM();	initPWM2();	ADCSRA|=(1<<ADSC);	direccionEscribir =0;	sei();}void initUart()
{
	//PInes de comunicaci?n, PD0 y PD1  rx y tx
	DDRD |= (1<<DDD1);
	DDRD &= ~(1<<DDD0);
		
	// Configuramos el UCSR0A,Todos en 0 para este caso.
	UCSR0A=0;
	//Configuramos el UCSR0B, Habilitamos interrupci?nes al recibir , Habilitamos recepcion y transmisi?n.
	UCSR0B |= (1<<RXCIE0)| (1<<RXEN0)| (1<<TXEN0);
	// Modo asincrono.
	UCSR0C =0;
	UCSR0C |= (1<< UCSZ01) | (1<< UCSZ00); //Tama?o del caracter
	//Nos da 9600 de baudrate con una frecuencia de reloj de 16Mhz
	UBRR0= 103;
}
void writeEEPROM(uint16_t addr, const void *data, uint8_t len) 
{
	uint8_t *p = (uint8_t*)data;
	for(uint8_t i = 0; i < len; i++) 
	{
		// Esperar a que termine escritura anterior
		while(EECR & (1 << EEPE));
		
		// Configurar direcci?n y dato
		EEAR = addr + i;
		EEDR = p[i];
		
		// Habilitar escritura
		EECR |= (1 << EEMPE);
		EECR |= (1 << EEPE);
	}
}void Guardarconfiguracion() 
{
	ServoConfig config;
	// Obtenemos las posiciones actuales
	config.servo1 = servo1;
	config.servo2 = servo2;
	config.servo3 = servo3;
	config.servo4 = servo4;
	uint16_t eeprom_addr = direccionEscribir * sizeof(ServoConfig); //(Slot*4) Actualizamos la direccion a escribir
	writeEEPROM(eeprom_addr, &config, sizeof(ServoConfig));//Escribimos en la eeprom
	direccionEscribir = (direccionEscribir + 1) % NUM_CONFIGS;// Actualizar slot
}void Gconf_actual()
{
	loadConfiguration(direccionLeer);
	direccionLeer = (direccionLeer + 1) % NUM_CONFIGS; // Rotar entre 0-3
}
void loadConfiguration(uint8_t config_num)
{
	if(config_num >= NUM_CONFIGS) return;
	ServoConfig config;
	uint16_t eeprom_addr = config_num * sizeof(ServoConfig);
	eeprom_read_block(&config, (void*)eeprom_addr, sizeof(ServoConfig));
	
	servo1 = config.servo1;
	servo2 = config.servo2;
	servo3 = config.servo3;
	servo4 = config.servo4;
	
	// Mover servos 
	movservo1(servo1);
	movservo2(servo2);
	movservo3(servo3);
	movservo4(servo4);
}/**************************************/// Interrupt routinesISR(PCINT1_vect){	if (!(PINC & (1 << PORTC2)))
	{ 
		_delay_ms(100); // Anti-rebote (Preguntar a pedro)
		if (!(PINC & (1 << PORTC2))) 
		{
			if (modo==1)
			{
				modo=2;
				desactivar_ADC();
				PORTB |= (1 << PORTB0);
				PORTB &= ~(1 << PORTB4);
			}
			else if (modo==2)
			{
				modo=3;
				desactivar_ADC();
				PORTB |= (1 << PORTB4)|(1<< PORTB0);
			}
			else if (modo==3)
			{
				modo=1;
				PORTB |= (1 << PORTB4);
				PORTB &= ~(1 << PORTB0);
			} 
			
			if (modo == 1) // Si acaba de entrar en modo manual
			{
				contador = 0; // Reinicia el contador del ADC
				ADCSRA |= (1 << ADEN) | (1 << ADIE);
				ADMUX &= ~((1<<MUX2)|(1<<MUX1)|(1<<MUX0)); 
				ADMUX |= (1<<MUX2)|(1<<MUX1);
				ADCSRA |= (1<<ADSC); // Inicia una nueva conversión
			}
		}
	}
}ISR(ADC_vect){	switch (modo)	{		case 1:			contador++;			if (contador==1)			{				conversion1= ADCH;				ADMUX &= ~((1<<MUX2)|(1<<MUX1)|(1<<MUX0));				ADMUX|= (1<<MUX2)|(1<<MUX0); //La proxima lectura sera en el ADC 5				servo1=1200+(conversion1*14.12);				ADCSRA |=(1<<ADSC);			}			else if (contador==2)
			{
				conversion2=ADCH;
				ADMUX &= ~((1<<MUX2)|(1<<MUX1)|(1<<MUX0));
				ADMUX |= (1<<MUX2); //Para ADC 4
				servo2= 1200+(conversion2*14.12);
				ADCSRA |= (1<<ADSC);
			}			else if (contador==3)
			{
				conversion3=ADCH;
				ADMUX &= ~((1<<MUX2)|(1<<MUX1)|(1<<MUX0));
				ADMUX |= (1<<MUX1)|(1<<MUX0);//Para adc 3
				servo3 = 9.08+(conversion3*0.106);
				ADCSRA|= (1<<ADSC);
			}			else if(contador==4)			{				conversion4=ADCH;				ADMUX &= ~((1<<MUX2)|(1<<MUX1)|(1<<MUX0));				ADMUX |= (1<<MUX2)|(1<<MUX1); //Proxima lectura en el adc 6.				servo4= 9.08+(conversion4*0.106);				ADCSRA|= (1<<ADSC);				contador=0;			}			break;		default:			break;	}}ISR(USART_RX_vect){	char rx= UDR0;	if (rx != '\n' && indice<4)
	{
		mensaje[indice++]=rx;
	}	else
	{
		mensaje[indice]='\0';
		indice=0;
		cambioAdafruit=1;	}}