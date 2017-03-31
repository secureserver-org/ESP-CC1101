-- ESP-CC1101 https://github.com/sam210723/ESP-CC1101
-- init.lua

-- Configure UART for 9600 baud (NodeMCU default = 115200)
uart.setup(0, 9600, 8, 0, 1, 1) -- id, baud, databits, parity, stopbits, echo
tmr.delay(250 * 1000) -- Wait 250ms for UART

print("\nNODEMCU_READY") -- Notify Arduino of successful boot
dofile("main.lua")
