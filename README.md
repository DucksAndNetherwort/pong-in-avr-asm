# Pong in AVR assembly

Programmer: Ducks

Writer: Ducks

Playtester: Ducks

Some help/pointers from: the wokwi discord, and Julian

'Most everything else: Ducks

You can run this on [Wokwi](https://wokwi.com/arduino/projects/290171034574782984).

## Abstract 

I did this whole thing because of the [AVR: Architecture, Assembly & Reverse Engineering](https://hackaday.io/course/176685-avr-architecture-assembly-reverse-engineering) course on Hackaday.

There was also a fair bit of confusion to be found in sending the rendered image to the display. Pong can also be rather complex, while being simple in other ways.

The goal of the course was to learn AVR assembly by implementing Pong in pure assembly.

## Introduction 

This report is about the writing of a pong game in C++, and the porting of it to AVR ASM.

## Materials Used

Hardware: 

- a computer that runs the latest version of Google Chrome
- a mouse
- a second display is highly reccomended. (I sometimes used an Oculus Quest 2 running ImmersedVR when 3 displays were helpful.)

Software/resources:

- Latest version of Google Chrome
- [Wokwi online arduino simulator](https://wokwi.com)
- an AVR instruction set manual: http://ww1.microchip.com/downloads/en/DeviceDoc/AVR-Instruction-Set-Manual-DS40002198A.pdf
- ImmersedVR, when I used my Quest
- The atmega328p datasheet

## Procedure

First I got the display write function working, the job of which was to output the contents of the image buffer to the display.

Then, I tried to get the render function working. Due to a lot of errors and confusion, I rewrote the display write function to be simpler, though that wasn't the problem.

Once I got it to render pixels, I started on making it render the full gamestate. much confusion later, I had two paddles and a ball on the display.

 After that, I got player inputs working. Relatively simple, but there was still a fair bit of logic to keep the paddle within the screen.

I tried to think of a way to make a basic AI to control the computer paddle, but then I just rolled it together with the render function.

Then I started work on the ball. In the end, just a pair of booleans were used to store the ball's current trajectory. Rather a bit of logic was used to do the physics,  
though it is pretty simple. Just a bunch of if statements using the current x/y position, and sometimes the player paddle position.

It also has a form of score system, though I can't remember exactly how it works.

With all the necessary features in all their separate functions, I did some fairly simple code for the main loop, which is mostly function calls.

Everything was then converted to AVR ASM, which was a gigantic pain in the backside. And a headache.

## Results

Well, the main results of this were a playable game of pong, and an understanding of ASM.

I also gained an understanding of the AVR architecture, which should help in understanding other architectures as well.

## Conclusion

Great for learning AVR ASM, and hugely interesting. Just don't do it looking for a calming activity.

Pong also has some complex logic, especially with the tweaks I used.

It was also found that image rendering can be a royal pain in the backside.

## References

* http://ww1.microchip.com/downloads/en/DeviceDoc/AVR-Instruction-Set-Manual-DS40002198A.pdf The instruction set manual
* https://ww1.microchip.com/downloads/en/DeviceDoc/Atmel-7810-Automotive-Microcontrollers-ATmega328P_Datasheet.pdf atmega328p datasheet
* https://www.wokwi.com wokwi simulator
* https://immersed.com/ immersed
* https://www.geeksforgeeks.org/operators-c-c/ C++ operator guide
