;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; RF Generator V0.1
;; Ningxi Liu
;; Module: RF_IO
;; 2014/11/22
;; V0.1 Modification:
;; 1) Added a 64 bit row decoder
;; 2) Added DFF for DIN<Wordsize-1:0>
;; 3) Deleted CLK buffer
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Load the file containing the basic schematic procedures
load("./skill/ece432Schematic.il")
/*====================================================================
 Define the procedure for creating schematic of a RF column with one bitcell selected in NROW bitcells
 This procedure has 5 parameters:
 - libName: the name of the library that you will put the cell schematic in;
 - cellName: the name of the cell you will create;
 - NROW: the number of rows;
 - Wordsize: the number of words;
 - addr_row: the number of row address;
=====================================================================*/
procedure(RF(libName cellName NROW Wordsize addr_row)

  ;; Define the local variables
  prog((cvid x y pin pinName i cnt BitcellName inst inputsignal)
    
 ;; Open the cell and its schematic view
    cvid = dbOpenCellViewByType(libName cellName "schematic" "schematic" "a")
	
	;; Clean the schematic view
    ece432DeleteObjectsSchematic(cvid)
	
	;; The coordinate of the origin point for the schematic
    x=0
    y=0
	
    ;; Create top level pins
	;; Create input pins
    foreach(pinName list("VDD" "VSS" "CLK" "DEC_EN" sprintf(nil "DIN<%L:0>" Wordsize-1) sprintf(nil "ADDR<%L:0>" addr_row-1) sprintf(nil "DBMOUT<%L:0>" Wordsize-1))
      pin=ece432SchematicCreatePin(cvid pinName "input" x:y "R0")
      y=y+0.5
    )

    foreach(pinName list(sprintf(nil "DOUT<%L:0>" Wordsize-1) sprintf(nil "DIN_DFF<%L:0>" Wordsize-1) "WL<0>")
	pin=ece432SchematicCreatePin(cvid pinName "output" x:y "R0")
	y=y+0.5
	)



;; Create Din out DFF
    x=0
    y=y-3
    for(i 1 Wordsize
	;; The coordinate of the origin point for the schematic
    x=x+3
         inst = ece432SchematicCreateInst(
	           	   ;; Cell view id
			   cvid 
			   
			   ;; Name of the library containing the bitcell
			   libName
			   
	           	   ;; The cell name  
              		   "DFF_Data"  
			   
			   ;; Cell view type, always be "symbol" here
			   "symbol" 
			   
			   ;; Instance name
	           sprintf(nil "DFF_DIN_%L" i) 
			   
			   ;; The following list defines the connections of the left side pins 
			   ;; in the symbol view; For our bitcell, 'VDD' 'VSS' 'BL' are pins on the left.
			   ;; The inverter pin 'WL' is connected with the net WL.
			   ;; If there are multiple pins on the left side, you can use the below way to define.
			   ;;    list(list("in1" in1net)
			   ;;         list("in2" in2net))
			   ;; If there is no pin on the left side, this parameter should be 'nil'.
	           list(list("VDD" "VDD")
			list("VSS" "VSS")
			list("DIN" sprintf(nil "DIN<%L>" i-1) )
			list("CLK" "CLK") ) 
			   
			   ;; The following list defines the connections of the right side pins 
			   
	  		   list(list("DOUT" sprintf(nil "DIN_DFF<%L>" i-1) ))  
			   
			   ;; The following list defines the connections of the top side pins 
			   
      		   nil
			   
			   ;; The following list defines the connections of the bottom side pins 
			   ;; in the symbol view; For our bitcell, this parameter should be 'nil'.
	           nil
			   
			   ;; Location of the instance
                   x:y 
			   
			   ;; Rotation of the instance, such as "R0", "R90", "R180", "R270", "MX", "MY", ...
		   "R0"
			 );; end inst
);; end for data in DFF

    ;; Create Data out DFF
    x=0
    y=y-3
    for(i 1 Wordsize
	;; The coordinate of the origin point for the schematic
    x=x+3
	
	;; Loop for replicating Bank_Mux_DFF with WordSize times
   
      inst = ece432SchematicCreateInst(
	           	   ;; Cell view id
			   cvid 
			   
			   ;; Name of the library containing the bitcell
			   libName
			   
	           	   ;; The cell name  
              		   "DFF_Data"  
			   
			   ;; Cell view type, always be "symbol" here
			   "symbol" 
			   
			   ;; Instance name
	           sprintf(nil "DFF_DOUT_%L" i) 
			   
			   ;; The following list defines the connections of the left side pins 
			   ;; in the symbol view; For our bitcell, 'VDD' 'VSS' 'BL' are pins on the left.
			   ;; The inverter pin 'WL' is connected with the net WL.
			   ;; If there are multiple pins on the left side, you can use the below way to define.
			   ;;    list(list("in1" in1net)
			   ;;         list("in2" in2net))
			   ;; If there is no pin on the left side, this parameter should be 'nil'.
	           list(list("VDD" "VDD")
			list("VSS" "VSS")
			list("DIN" sprintf(nil "DBMOUT<%L>" i-1) )
			list("CLK" "CLK") ) 
			   
			   ;; The following list defines the connections of the right side pins 
			   
	  		   list(list("DOUT" sprintf(nil "DOUT<%L>" i-1) ))  
			   
			   ;; The following list defines the connections of the top side pins 
			   
      		   nil
			   
			   ;; The following list defines the connections of the bottom side pins 
			   ;; in the symbol view; For our bitcell, this parameter should be 'nil'.
	           nil
			   
			   ;; Location of the instance
                   x:y 
			   
			   ;; Rotation of the instance, such as "R0", "R90", "R180", "R270", "MX", "MY", ...
		   "R0"
			 );; end inst 
);; end for data out DFF

 ;; Create row address DFF
x=0
y=y-3
    for(i 1 addr_row
	;; The coordinate of the origin point for the schematic
    x=x+3  
      inst = ece432SchematicCreateInst(
	           	   ;; Cell view id
			   cvid 
			   
			   ;; Name of the library containing the bitcell
			   libName
			   
	           	   ;; The cell name  
              		   "DFF_Addr"  
			   
			   ;; Cell view type, always be "symbol" here
			   "symbol" 
			   
			   ;; Instance name
	           sprintf(nil "DFF_Addr_%L" i) 
			   
			   ;; The following list defines the connections of the left side pins 
			   ;; in the symbol view; For our bitcell, 'VDD' 'VSS' 'BL' are pins on the left.
			   ;; The inverter pin 'WL' is connected with the net WL.
			   ;; If there are multiple pins on the left side, you can use the below way to define.
			   ;;    list(list("in1" in1net)
			   ;;         list("in2" in2net))
			   ;; If there is no pin on the left side, this parameter should be 'nil'.
	           list(list("VDD" "VDD")
			list("VSS" "VSS")
			list("DIN" sprintf(nil "ADDR<%L>" i-1) )
			list("CLK" "CLK") ) 
			   
			   ;; The following list defines the connections of the right side pins 
			   
	  		   list(list("DOUT" sprintf(nil "ADDR_DFF<%L>" i-1) ))  
			   
			   ;; The following list defines the connections of the top side pins 
			   
      		   nil
			   
			   ;; The following list defines the connections of the bottom side pins 
			   ;; in the symbol view; For our bitcell, this parameter should be 'nil'.
	           nil
			   
			   ;; Location of the instance
                   x:y 
			   
			   ;; Rotation of the instance, such as "R0", "R90", "R180", "R270", "MX", "MY", ...
		   "R0"
			 );; end inst 
);; end for address DFF

 ;; Create row decoder
x=3
y=y-3
       inst = ece432SchematicCreateInst(
	           	   ;; Cell view id
			   cvid 
			   
			   ;; Name of the library containing the bitcell
			   libName
			   
	           	   ;; The cell name  
              		   "decoder_64b"  
			   
			   ;; Cell view type, always be "symbol" here
			   "symbol" 
			   
			   ;; Instance name
	                   "ROW_DECODER" 
			   
			   ;; The following list defines the connections of the left side pins 
			   ;; in the symbol view; For our bitcell, 'VDD' 'VSS' 'BL' are pins on the left.
			   ;; The inverter pin 'WL' is connected with the net WL.
			   ;; If there are multiple pins on the left side, you can use the below way to define.
			   ;;    list(list("in1" in1net)
			   ;;         list("in2" in2net))
			   ;; If there is no pin on the left side, this parameter should be 'nil'.
	           list(list("VDD" "VDD")
			list("VSS" "VSS")
			list("VSS_G" "VSS")
			list("ADR<5:0>" sprintf(nil "ADDR_DFF<%L:0>" addr_row-1) )
			list("ENABLE" "DEC_EN") ) 
			   
			   ;; The following list defines the connections of the right side pins 
			   
	  		   list(list("ROW<63:0>" sprintf(nil "WL<%L:0>" NROW-1) ))  
			   
			   ;; The following list defines the connections of the top side pins 
			   
      		   nil
			   
			   ;; The following list defines the connections of the bottom side pins 
			   ;; in the symbol view; For our bitcell, this parameter should be 'nil'.
	           nil
			   
			   ;; Location of the instance
                   x:y 
			   
			   ;; Rotation of the instance, such as "R0", "R90", "R180", "R270", "MX", "MY", ...
		   "R0"
			 );; end inst 

	;; Check, save and close the cell view
	schCheck(cvid)  ;; check the schematic connectivity
    dbSave(cvid)
    dbClose(cvid)
	
    return(t)
	
  );; end prog
  
);; end procedure


/*====================================================================
 'let' is the main entrance of the skill program.
 We will build schematic for a 6-bit inverter chain as an example.
====================================================================*/
let((Wordsize NROW addr_row libName cellName)  ;; N, libName and cellName are variables

  ;; The number of inverters
  NROW=64
  addr_row=6
  Wordsize = 16
  ;; The name of the library we will put the new cell in
  libName="Register_File"
printf("for debug1")
  
  ;; Define the cell name
  sprintf(cellName "RF_IO_%Lb" Wordsize)
printf("for debug2")
  ;; Call the procedure to create the inverter chain schematic
  RF(libName cellName NROW Wordsize addr_row)
  
  printf("=== Cell %L Schematic has been created! ===\n", cellName)

) ;;end let
