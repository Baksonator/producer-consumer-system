You can run the program in NASM, by runing the file primer7.asm. The program has 6 tasks working with a shared queue of data (numbers). 3 of the tasks work on adding numbers to the queue (the numbers they add are determined by their own counters). The other 3 work on removing those numbers from the queue and displaing them on the screen. In the implementation, the tasks that are adding numbers also display them, in order to show that the system works. The program ends when the producers generate all of their numbers. The number of tasks can be increased, manually, planning to enable dynamic task adding and removing when I find the time to refactor the code.
