# pong in AVR assembly

Programmer: Ducks

Writer: Ducks

Playtester: Ducks

Some help/pointers from: the wokwi discord, and Julian

'Most everything else: Ducks

You can run this on [Wokwi](https://wokwi.com/arduino/projects/290171034574782984).

## Abstract: 

I did this whole thing because of the [AVR: Architecture, Assembly & Reverse Engineering](https://hackaday.io/course/176685-avr-architecture-assembly-reverse-engineering) course on Hackaday. 'Twas found that rendering can be a royal pain in the backside.

There was also a fair bit of confusion to be found in sending the rendered image to the display. Pong can also be rather complex, while being simple in other ways.

This (and the course that resulted in it) was rather interesting, and I picked up rather a few helpful tricks. Sometimes ASM is the best way to do something!

## Introduction: 

This report is about the writing of a pong game in C++, and the porting of it to AVR ASM.

## Materials used:

Hardware: 

- a laptop
- a mouse
- an external display
- even an Oculus Quest 2 with ImmersedVR, once or twice, when I needed 3 displays

Software/resources:

- Google Chrome
- Wokwi.com
-  (put instruction set manual here) 
- ImmersedVR, when I used my Quest
- The atmega328p datasheet

## Procedure:

(Note: none of this was written as I did it, everything is recalled from memory)

First I got the display write function working, the job of which was to output the contents of the image buffer to the display. (past tense because I rewrite it later on)

Then, I tried to get the render function working. Due to a lot of errors and confusion, I rewrote the display write function to be simpler, though that wasn't the problem.

Once I got it to render pixels, I started on making it render the full gamestate. much confusion later, I had two paddles and a ball on the display.

 After that, I got player inputs working. Relatively simple, but there was still a fair bit of logic to keep the paddle within the screen.

I tried to think of a way to make a basic AI to control the computer paddle, but then I just rolled it together with the render function.

Then I started work on the ball. In the end, just a pair of booleans were used to store the ball's current trajectory. Rather a bit of logic was used to do the physics,  
though it is pretty simple. Just a bunch of if statements using the current x/y position, and sometimes the player paddle position.

It also has a form of score system, but I can't remember exactly how it works.

With all the necessary features in all their separate functions, I did some fairly simple code for the main loop, which is mostly function calls.