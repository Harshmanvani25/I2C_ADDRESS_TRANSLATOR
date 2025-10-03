# I2C Address Translator  

**Designer:** Harsh Manvani  
**Date:** October, 2025  

---

## Architecture Overview  
- The I2C Address Translator module sits between a master and slave devices on an I2C bus.  
- It monitors communication, decodes an address byte, and routes the transaction to the appropriate slave based on predefined address mapping.  
- It also handles protocol-level responsibilities such as **ACK generation**, **START detection**, and **STOP detection**.  

---

## Block Diagram  
*(Insert block diagram here if available)*  

---

## FSM Logic Explanation  

| **State**    | **Description** |
|--------------|-----------------|
| **IDLE**     | Waits for START condition |
| **ADDR**     | Samples 8-bit address from SDA |
| **TRANS**    | Decodes address and selects slave |
| **ACK**      | Drives SDA low to acknowledge address |
| **WAIT**     | Waits for next clock edge |
| **DATA**     | Samples 8-bit data byte |
| **DATA_DONE**| ACKs data byte and waits for STOP |
| **STOP**     | Detects STOP condition and resets FSM |

---

## Address Translation Implementation  
- After receiving the 8-bit address, the translator extracts the **7-bit address** from the first byte and compares it with known slave addresses:  

```verilog
case (addr_byte[7:1])
  7'h48: slave_select = 0;
  7'h49: slave_select = 1;
  default: slave_select = 1'bz;
endcase
```
---

## Design Challenges Faced  
- **SDA conflict during ACK:** Both master and translator attempted to drive SDA, leading to simulation errors.  
- **STOP condition not detected:** Incorrect SDA timing prevented proper STOP detection.  
- **DATA_DONE state:** Added for future multi-byte support, though multi-byte handling is not yet implemented.  

---

## Project Assumptions  
- The **master** is unaware that both slaves share the same physical address.  
- The **translator** uses different virtual addresses to properly route data to the correct slave.  
