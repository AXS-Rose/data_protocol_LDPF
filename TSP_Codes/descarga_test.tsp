
reset()
defbuffer1.clear()
defbuffer2.clear()
-- Crear buffer nuevo

--------------------------------------------------
-------------- Abrir Archivo TXT -----------------
--------------------------------------------------

FileNumber=file.open("/usb1/TestData.csv",file.MODE_WRITE)--Tiene que haber un archivo llamado "TestData" en el USB
file.write(FileNumber, "Current, Voltage, Seconds\r\n")--Filenumber es un identificador del archivo donde se escribe

--------------------------------------------------
------------------ Variables ---------------------
--------------------------------------------------

iteration2 = 1

--------------------------------------------------
------------------ DESCARGA ----------------------
--------------------------------------------------

smu.measure.func=smu.FUNC_DC_CURRENT

smu.measure.sense=smu.SENSE_4WIRE

smu.source.func=smu.FUNC_DC_VOLTAGE
smu.source.offmode=smu.OFFMODE_HIGHZ
smu.source.level=2.75 -- Fijar inferior a voltlimit
smu.measure.terminals=smu.TERMINALS_FRONT

smu.source.readback=smu.ON

deltatime = 0
capacity = 0
captotal = 0
voltlimit=2.8 -- Debe ser mayor que smu.source.level
aux = 1

smu.source.output=smu.ON

display.changescreen(display.SCREEN_USER_SWIPE)

iteration=1

while true do
	
	smu.source.ilimit.level=2.5 -- Corriente de descarga
	curr=smu.measure.read(defbuffer1)
	volt=defbuffer1.sourcevalues[iteration]
	curr2=smu.measure.read(defbuffer2)
	volt2=defbuffer2.sourcevalues[iteration]
	time1=defbuffer1.relativetimestamps[iteration]
	time2=defbuffer2.timestamps[iteration2] --Aquí se define el tiempo en base a 2 buffer por alguna razon
	hours = (defbuffer2.relativetimestamps[iteration2]/3600)
	
	if volt <= voltlimit then -- Si el voltaje de la celda baja del límite, se termina el ciclo y solo avanza el iterador2
		iteration2=(iteration2+1)
		break 
	end
	
	if aux >= 2 then --Obtener la capacidad descargada
		deltatime = time1 - defbuffer1.relativetimestamps[iteration-1]
		capacity = curr*deltatime/3.6 -- en mAh Esto no debería multiplicarse por 3.6?
		captotal = captotal + capacity
	end
	print("Iteration: ",iteration2,"voltage: ", volt,"current: ", curr, "time: ", time2, "deltatime: ",deltatime, "cap [mAh]", capacity, "cap total [mAh]", captotal) 
	display.settext(display.TEXT1,string.format("voltage= %.4fV",volt)) 
	display.settext(display.TEXT2,string.format("current= %.2fA,time = %.2fHrs2", curr, hours))
	iteration=(iteration+1)
	iteration2=(iteration2+1)
	delay(1)
	aux=(aux+1)
end

smu.source.output=smu.OFF

--------------------------------------------------
------------- Guardar Datos en TXT ---------------
--------------------------------------------------

print("nIteration:\tCurrent:\tVoltage:\tTime:\r\n")
for i=1, defbuffer1.n do -- cambiar a un buffer nuevo
	print(i, defbuffer1[i], defbuffer1.sourcevalues[i], defbuffer2.timestamps[i+iteration2-iteration-1])
	file.write(FileNumber, string.format("%g,%g,%s\r\n", defbuffer1.readings[i],defbuffer1.sourcevalues[i],defbuffer2.timestamps[i+iteration2-iteration-1]))
end

defbuffer1.clear()

file.close(FileNumber)