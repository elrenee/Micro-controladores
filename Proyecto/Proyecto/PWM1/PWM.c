/*
 * PWM.c
 *
 * Created: 5/04/2025 17:32:50
 *  Author: Barbaritos
 */ 
#include "PWM.h"void initPWM(){	DDRB |= (1<<DDB1)|(1<<DDB2);	TCCR1A = 0;	TCCR1A |= (1<< COM1A1)|(1<<COM1B1)|(1<<WGM11); //PWM No invertido,compare match A y B	TCCR1B=0;	TCCR1B |= (1 << WGM13) | (1 << WGM12) |(1<<CS11);	ICR1 = 40000;}void initPWM2(){	DDRB |= (1<<DDB3);	DDRD |= (1<<DDD3);	TCCR2A|= (1<<COM2A1)|(1<<COM2B1)|(1<<WGM21)|(1<<WGM20);//Modo fast, tope 255, no invertido	TCCR2B &= ~(1<<WGM22);	TCCR2B |= (1<<CS22) | (1 << CS21) | (1 << CS20); //Prescaler a 1024, para 16.8ms	}void movservo1(uint16_t posicion){	OCR1A=posicion;}void movservo2(uint16_t posicion2){	OCR1B= posicion2;}void movservo3(uint16_t posicion3){	OCR2A= posicion3;}void movservo4(uint16_t posicion4){	OCR2B= posicion4;}