The I2C Address translator module sits between a master and slave devices 
on an I2C bus. It monitors communication, decodes an address bytes, and 
routes the transaction to the appropriate slave based on predefine address 
mapping. It also handles protocol level responsibilities such as Ack 
generation and START & STOP detection. 
