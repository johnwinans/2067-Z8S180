Send zero to the CPU on any/every memory read operation.
This will result in the CPU executing NOP instructions from
memory address 0, 1, 2,... and we should see the address bus 
counting accordingly.
