/*
 * PWM.c
 *
 * Created: 5/04/2025 17:32:50
 *  Author: Barbaritos
 */ 
#include "PWM.h"void initPWM(){	DDRB |= (1<<DDB1);	TCCR1A = 0;	TCCR1A |= (1<< COM1A1)|(1<<WGM11); //PWM No invertido,	TCCR1B=0;	TCCR1B |= (1 << WGM13) | (1 << WGM12) |(1<<CS11);	ICR1 = 255;}void funciondutycycle(uint8_t duty){	OCR1A = duty;}