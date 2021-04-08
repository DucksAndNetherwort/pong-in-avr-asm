# pong in AVR assembly



## TLDR: 

Don't bother programming in ASM unless you need to do something very specific that's harder or worse in C++.  



## What I actually intended by doing this:  

This was a foray into the dark art of AVR ASM, because of the AVR hacking and reverse engineering course on hackaday by Uri Shaked, using wokwi.com for simulation.  
Well, I really did this for the certificate.  



## How on earth did I manage it?  

Well, thanks for asking, kind stranger!  

First, I wrote it all in C++. Which was a good thing, seeing as it was very hard, confusing, and infuriating. No way I could have done this in AVR right off the bat.  

For example, `imgBuffer[((pen[0] >> 3) + (pen[1] << 1))] |= (0x80 >> (pen[0] & 0x07));` becomes 21 lines of ASM.  

Writing the image data out to the display was also quite a pain. Fortunately AVR has hardware spi! Bit-banging that would have been *painful*.  

The image data is stored in a single 16-byte array. Easy for C++, but not for ASM. (pointers can be such a nuisance!) The bytes are shifted out one by one,  
with the row being incremented after every second byte. For writing to the image buffer, well, take a gander: `imgBuffer[((pen[0] >> 3) + (pen[1] << 1))] |= (0x80 >> (pen[0] & 0x07));` . pen[0] is the x position, pen[1] is y.  

