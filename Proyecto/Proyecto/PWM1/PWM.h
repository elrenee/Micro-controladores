/*
 * PWM.h
 *
 * Created: 28/04/2025 17:31:56
 *  Author: Barbaritos
 */ 


#ifndef PWM_H_
#define PWM_H_


#include <avr/io.h>void initPWM();void initPWM2();void movservo1(uint16_t posicion);void movservo2(uint16_t servo2);void movservo3(uint16_t posicion3);void movservo4(uint16_t posicion4);


#endif /* PWM_H_ */