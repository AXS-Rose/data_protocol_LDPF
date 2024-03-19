function cc_discharge(voltlimit, discurrent, SOC_0, cell_captotal, test_number) 
	-- (voltaje descargado,corriente de descarga, número de identificación data)
	
	-- Creación buffer para guardar datos
	reset() 
	ExtBuffer = buffer.make(300000)
	
	-- Se aseguran que la celda esté conectada al keithley
	keithley_control()
	
	-- Definicion de archivo procedure
	procedure = "cc_discharge"
	
	FileNumber=file.open("/usb1/TestProcedure.csv",file.MODE_APPEND)
	print("Function: ",procedure,"voltlimit: ", voltlimit,"discurrent: ", discurrent, "SOC_0: ", SOC_0, "cell_captotal: ",cell_captotal, "test_number", test_number) 
	file.write(FileNumber, string.format("%s,%s,%s,%s,%s,%s\r\n",procedure,"voltlimit","discurrent","SOC_0","cell_captotal","test_number"))
	file.write(FileNumber, string.format("%s,%g,%g,%g,%g,%g\r\n",procedure,voltlimit,discurrent,SOC_0,cell_captotal,test_number))
	file.close(FileNumber)
	
	-- Definicion de archivo data
	FileNumber=file.open("/usb1/TestData.csv",file.MODE_APPEND)

	smu.measure.func = smu.FUNC_DC_CURRENT 	-- Se mide corriente
	smu.measure.sense = smu.SENSE_4WIRE 	-- Se cambia el sistema de medición a 4-wire para más precisión
	smu.source.func = smu.FUNC_DC_VOLTAGE 	-- Se controla el voltaje
	smu.source.offmode = smu.OFFMODE_HIGHZ 	-- Modo cuando la carga de desconecta para aislar el equipo
	smu.source.level = voltlimit-0.05 		-- Fijar inferior a voltlimit para asegurar descarga constante
	smu.source.range = 7					-- Asegura lectura de voltaje para valores menores a 7V
	smu.measure.terminals = smu.TERMINALS_FRONT
	smu.source.readback = smu.ON
	
	-- Definición de variables del proceso
	deltatime = 0
	capacity = 0
	captotal = 0
	aux = 1
	iteration=1
	iteration2=1
	SOC = SOC_0
	
	smu.source.output=smu.ON -- Se inicia la conexión con la carga
	display.changescreen(display.SCREEN_USER_SWIPE)
	
	while true do
		-- Definición de variables por ciclo
		smu.source.ilimit.level=-discurrent
		curr=smu.measure.read(ExtBuffer)
		volt=ExtBuffer.sourcevalues[iteration]
		time1=ExtBuffer.relativetimestamps[iteration]
		time2=ExtBuffer.timestamps[iteration2]
		hours = (ExtBuffer.relativetimestamps[iteration2]/3600)
		
		-- Detección de limite de voltaje
		if volt <= voltlimit then 
			iteration2=(iteration2+1)
			print('El voltaje de la celda es menor al voltaje minimo')
			print('Último voltaje detectado= ',volt)
			print('Última corriente detectada= ',curr)
			break 
		end
		
		-- Capacidad acumulada
		if aux >= 2 then
			deltatime = time1 - ExtBuffer.relativetimestamps[iteration-1]
			capacity = curr*deltatime/3.6 -- en mAh
			SOC = SOC + (capacity/cell_captotal)*100
			captotal = captotal + capacity
		end
		
		print("Iteration: ",iteration2,"voltage: ", volt,"current: ", curr, "time: ", time2, "deltatime: ",deltatime, "cap [mAh]", capacity, "cap total [mAh]", captotal, 'SOC', SOC, 'Test state', test_number) 
		file.write(FileNumber, string.format("%g,%g,%g,%g,%s,%g,%g\r\n",curr,volt,capacity,captotal,time2,test_number,SOC))
		display.settext(display.TEXT1,string.format("voltage= %.4fV",volt)) 
		
		display.settext(display.TEXT2,string.format("current= %.2fA,time = %.2fHrs2", curr, hours))
		iteration=(iteration+1)
		iteration2=(iteration2+1)
		aux=(aux+1)
		delay(1)
	end
	
	-- se desconecta la carga del equipo
	smu.source.output=smu.OFF
	
	-- se limpia el buffer
	ExtBuffer.clear()
	file.close(FileNumber)
	print('Fin función de descarga')
end

function cccv_discharge(voltlimit, discurrent, curr_limit, SOC_0, cell_captotal, test_number) 
	-- (voltaje descargado,corriente de descarga, número de identificación data)
	
	-- Creación buffer para guardar datos
	reset() 
	ExtBuffer = buffer.make(300000)
	
	-- Se aseguran que la celda esté conectada al keithley
	keithley_control()
	
	-- Definicion de archivo procedure
	procedure = "cccv_discharge"
	
	FileNumber=file.open("/usb1/TestProcedure.csv",file.MODE_APPEND)
	print("Function: ",procedure, "voltlimit: ",voltlimit,"discurrent: ",discurrent,"curr_limit: ",curr_limit,"SOC_0: ",SOC_0,"cell_captotal: ",cell_captotal,"test_number: ",test_number) 
	file.write(FileNumber, string.format("%s,%s,%s,%s,%s,%s,%s\r\n",procedure,"voltlimit", "discurrent", "curr_limit", "SOC_0", "cell_captotal", "test_number"))
	file.write(FileNumber, string.format("%s,%g,%g,%g,%g,%g,%g\r\n",procedure,voltlimit, discurrent, curr_limit, SOC_0, cell_captotal, test_number))
	file.close(FileNumber)
	
	-- Definicion de archivo data
	FileNumber=file.open("/usb1/TestData.csv",file.MODE_APPEND)

	smu.measure.func = smu.FUNC_DC_CURRENT 	-- Se mide corriente
	smu.measure.sense = smu.SENSE_4WIRE 	-- Se cambia el sistema de medición a 4-wire para más precisión
	smu.source.func = smu.FUNC_DC_VOLTAGE 	-- Se controla el voltaje
	smu.source.offmode = smu.OFFMODE_HIGHZ 	-- Modo cuando la carga de desconecta para aislar el equipo
	smu.source.level = voltlimit-0.05 		-- Fijar inferior a voltlimit para asegurar descarga constante
	smu.source.range = 7					-- Asegura lectura de voltaje para valores menores a 7V
	smu.measure.terminals = smu.TERMINALS_FRONT
	smu.source.readback = smu.ON
	
	-- Definición de variables del proceso
	deltatime = 0
	capacity = 0
	captotal = 0
	aux = 1
	iteration=1
	iteration2=1
	SOC = SOC_0
	
	smu.source.output=smu.ON -- Se inicia la conexión con la carga
	display.changescreen(display.SCREEN_USER_SWIPE)
	
	while true do
		-- Definición de variables por ciclo
		smu.source.ilimit.level=-discurrent
		curr=smu.measure.read(ExtBuffer)
		volt=ExtBuffer.sourcevalues[iteration]
		time1=ExtBuffer.relativetimestamps[iteration]
		time2=ExtBuffer.timestamps[iteration2]
		hours = (ExtBuffer.relativetimestamps[iteration2]/3600)
		
		if curr > -curr_limit then 
			iteration2=(iteration2+1)
			print('La corriente de la celda es menor a la corriente minima')
			print('Último voltaje detectado= ',volt)
			print('Última corriente detectada= ',curr)
			break 
		end
		
		-- Capacidad acumulada
		if aux >= 2 then
			deltatime = time1 - ExtBuffer.relativetimestamps[iteration-1]
			capacity = curr*deltatime/3.6 -- en mAh
			SOC = SOC + (capacity/cell_captotal)*100
			captotal = captotal + capacity
		end
		
		print("Iteration: ",iteration2,"voltage: ", volt,"current: ", curr, "time: ", time2, "deltatime: ",deltatime, "cap [mAh]", capacity, "cap total [mAh]", captotal, 'SOC', SOC, 'Test state', test_number) 
		file.write(FileNumber, string.format("%g,%g,%g,%g,%s,%g,%g\r\n",curr,volt,capacity,captotal,time2,test_number,SOC))
		display.settext(display.TEXT1,string.format("voltage= %.4fV",volt)) 
		
		display.settext(display.TEXT2,string.format("current= %.2fA,time = %.2fHrs2", curr, hours))
		iteration=(iteration+1)
		iteration2=(iteration2+1)
		aux=(aux+1)
		delay(1)
	end
	
	-- se desconecta la carga del equipo
	smu.source.output=smu.OFF
	
	-- se limpia el buffer
	ExtBuffer.clear()
	file.close(FileNumber)
	print('Fin función de descarga')
end

function charge(voltlimit, charcurrent, curr_limit, SOC_0, cell_captotal, test_number)

	-- Creación buffer para guardar datos
	reset() 
	ExtBuffer = buffer.make(300000)
	
	keithley_control()
	
	-- Definicion de archivo procedure
	procedure = "charge"
	
	FileNumber=file.open("/usb1/TestProcedure.csv",file.MODE_APPEND)
	print("Function: ",procedure, "voltlimit: ",voltlimit,"charcurrent: ",charcurrent,"curr_limit: ",curr_limit,"SOC_0: ",SOC_0,"cell_captotal: ",cell_captotal,"test_number: ",test_number) 
	file.write(FileNumber, string.format("%s,%s,%s,%s,%s,%s,%s\r\n",procedure,"voltlimit", "charcurrent", "curr_limit", "SOC_0", "cell_captotal", "test_number"))
	file.write(FileNumber, string.format("%s,%g,%g,%g,%g,%g,%g\r\n",procedure,voltlimit, charcurrent, curr_limit, SOC_0, cell_captotal, test_number))
	file.close(FileNumber)
	
	-- Definicion de archivo data
	FileNumber=file.open("/usb1/TestData.csv",file.MODE_APPEND)

	smu.measure.func=smu.FUNC_DC_CURRENT
	smu.measure.sense=smu.SENSE_4WIRE
	smu.source.func=smu.FUNC_DC_VOLTAGE
	smu.source.offmode=smu.OFFMODE_HIGHZ
	smu.source.level=voltlimit
	smu.measure.terminals=smu.TERMINALS_FRONT
	smu.source.readback=smu.ON
	smu.source.range = 7					-- Asegura lectura de voltaje para valores menores a 7V
	smu.source.ilimit.level=charcurrent
	
	smu.source.output=smu.ON
	
	display.changescreen(display.SCREEN_USER_SWIPE)
	
	SOC = SOC_0
	aux2=1
	deltatime = 0
	capacity = 0
	captotal_carga = 0
	iteration = 1
	iteration2=1
	
	while true do
		
		curr=smu.measure.read(ExtBuffer)
		volt=ExtBuffer.sourcevalues[iteration]
		time1=ExtBuffer.relativetimestamps[iteration]
		time2=ExtBuffer.timestamps[iteration2]
		hours = (ExtBuffer.relativetimestamps[iteration2]/3600)
		
		if curr <= curr_limit then
			iteration2=(iteration2+1)
			print('La corriente de la celda es menor a la corriente mínima de carga')
			print('Último voltaje detectado= ',volt)
			print('Última corriente detectada= ',curr)
			break
		end
	
		if aux2 >= 2 then
			deltatime = time1 - ExtBuffer.relativetimestamps[iteration-1]
			capacity = curr*deltatime/3.6 -- en mAh
			SOC = SOC + (capacity/cell_captotal)*100
			captotal_carga = captotal_carga + capacity
		end
		print("Iteration: ",iteration2,"voltage: ", volt,"current: ", curr, "time: ", time2, "deltatime: ",deltatime, "cap [mAh]", capacity, "cap total [mAh]", captotal_carga, 'SOC', SOC, 'Test state', test_number)
		file.write(FileNumber, string.format("%g,%g,%g,%g,%s,%g,%g\r\n", curr,volt,capacity,captotal_carga,time2,test_number,SOC))
		display.settext(display.TEXT1,string.format("voltage= %.4fV",volt))
		display.settext(display.TEXT2,string.format("current= %.2fA,time = %.2fHrs2", curr, hours))
		iteration=(iteration+1)
		iteration2=(iteration2+1)
		aux2=aux2+1
		delay(1)
	end
	
	smu.source.output=smu.OFF
	
	ExtBuffer.clear()
	file.close(FileNumber)
	print('Fin función de carga')
	print('Valor de captotal_carga = ',captotal_carga)
	return captotal_carga
end

function resting(voltlimit, contador_rest, SOC_0, cell_captotal, test_number)

	-- Creación buffer para guardar datos
	reset() 
	ExtBuffer = buffer.make(300000)
	
	keithley_control()
	
	-- Definicion de archivo procedure
	procedure = "resting"
	
	FileNumber=file.open("/usb1/TestProcedure.csv",file.MODE_APPEND)
	print("Function: ",procedure, "voltlimit: ",voltlimit,"contador_rest: ",contador_rest, "SOC_0: ",SOC_0, "cell_captotal: ",cell_captotal, "test_number: ",test_number) 
	file.write(FileNumber, string.format("%s,%s,%s,%s,%s,%s\r\n",procedure,"voltlimit","contador_rest", "SOC_0", "cell_captotal", "test_number"))
	file.write(FileNumber, string.format("%s,%g,%g,%g,%g,%g\r\n",procedure,voltlimit, contador_rest, SOC_0, cell_captotal, test_number))
	file.close(FileNumber)
	
	-- Definicion de archivo data
	FileNumber=file.open("/usb1/TestData.csv",file.MODE_APPEND)

	smu.measure.func=smu.FUNC_DC_CURRENT
	smu.measure.sense=smu.SENSE_4WIRE
	smu.source.func=smu.FUNC_DC_VOLTAGE
	smu.source.offmode=smu.OFFMODE_HIGHZ
	smu.source.level=voltlimit
	smu.measure.terminals=smu.TERMINALS_FRONT
	smu.source.readback=smu.ON
	smu.source.range = 7
	
	SOC = SOC_0
	deltatime = 0
	capacity = 0
	captotal = 0
	aux = 1
	iteration=1
	iteration2=1
	contador = 1
	ncontador = contador_rest
	
	smu.source.output=smu.ON
	display.changescreen(display.SCREEN_USER_SWIPE)
	
	while true do
		smu.source.ilimit.level=-0.0001
		curr=smu.measure.read(ExtBuffer)
		volt=ExtBuffer.sourcevalues[iteration]
		time1=ExtBuffer.relativetimestamps[iteration]
		time2=ExtBuffer.timestamps[iteration2]
		hours = (ExtBuffer.relativetimestamps[iteration2]/3600)
		
		if contador > ncontador then 
			iteration2=(iteration2+1)
			print('Se han realizado todas las iteraciones de descanso')
			print('Último voltaje detectado= ',volt)
			print('Última corriente detectada= ',curr)
			break 
		end
		
		if aux >= 2 then
			deltatime = time1 - ExtBuffer.relativetimestamps[iteration-1]
			capacity = curr*deltatime/3.6 -- en mAh (Asumo error en fuente de corriente)
			SOC = SOC + (capacity/cell_captotal)*100
			captotal = captotal + capacity
		end
		
		print("Iteration: ",iteration2,"voltage: ", volt,"current: ", curr, "time: ", time2, "deltatime: ",deltatime, "cap [mAh]", capacity, "cap total [mAh]", captotal, 'SOC', SOC, 'Test state', test_number)
		file.write(FileNumber, string.format("%g,%g,%g,%g,%s,%g,%g\r\n", curr,volt,capacity,captotal,time2,test_number,SOC))
		display.settext(display.TEXT1,string.format("voltage= %.4fV",volt)) 
		display.settext(display.TEXT2,string.format("current= %.2fA,time = %.2fHrs2", curr, hours))
		iteration=(iteration+1)
		iteration2=(iteration2+1)
		delay(1)
		aux=(aux+1)
		contador=contador+1
	end
	smu.source.output=smu.OFF
	
	ExtBuffer.clear()
	file.close(FileNumber)
	print('Fin función de descanso')
end

function vocbor_measure(voltlimit, SOC, test_number)

	-- Creación buffer para guardar datos
	reset() 
	ExtBuffer = buffer.make(300000)

	keithley_control()

	-- Definicion de archivo procedure
	procedure = "vocbor_measure"
	
	FileNumber=file.open("/usb1/TestProcedure.csv",file.MODE_APPEND)
	print("Function: ",procedure,"voltlimit: ",voltlimit,"SOC: ",SOC,"test_number: ", test_number) 
	file.write(FileNumber, string.format("%s,%s,%s,%s\r\n",procedure,"voltlimit","SOC","test_number"))
	file.write(FileNumber, string.format("%s,%g,%g,%g\r\n",procedure,voltlimit, SOC, test_number))
	file.close(FileNumber)

	-- Definicion de archivo data
	FileNumber=file.open("/usb1/TestData.csv",file.MODE_APPEND)
	
	smu.measure.func=smu.FUNC_DC_CURRENT
	smu.measure.sense=smu.SENSE_4WIRE
	smu.source.func=smu.FUNC_DC_VOLTAGE
	smu.source.offmode=smu.OFFMODE_HIGHZ
	smu.source.level=(voltlimit - 0.05) -- Fijar inferior a voltlimit
	smu.measure.terminals=smu.TERMINALS_FRONT
	smu.source.readback=smu.ON
	smu.source.range = 7
	
	deltatime = 0
	capacity = 0
	captotal = 0
	voltlimit=voltlimit -- Debe ser mayor que smu.source.level
	aux = 1
	iteration=1
	iteration2=1
	contador = 1
	ncontador = 1
	
	smu.source.output=smu.ON
	display.changescreen(display.SCREEN_USER_SWIPE)
	
	while true do
		smu.source.ilimit.level=-0.0001
		curr=smu.measure.read(ExtBuffer)
		volt=ExtBuffer.sourcevalues[iteration]
		time1=ExtBuffer.relativetimestamps[iteration]
		time2=ExtBuffer.timestamps[iteration2]
		hours = (ExtBuffer.relativetimestamps[iteration2]/3600)
		
		if contador > ncontador then 
			iteration2=(iteration2+1)
			print('Se han realizado todas las iteraciones de medición voc_bor')
			print('Último voltaje detectado= ',volt)
			print('Última corriente detectada= ',curr)
			break 
		end
		
		if aux >= 2 then
			deltatime = time1 - ExtBuffer.relativetimestamps[iteration-1]
			capacity = curr*deltatime/3.6 -- en mAh (Asumo error en fuente de corriente)
			captotal = captotal + capacity
		end
		print("Iteration: ",iteration2,"voltage: ", volt,"current: ", curr, "time: ", time2, "deltatime: ",deltatime, "cap [mAh]", capacity, "cap total [mAh]", captotal, 'SOC', SOC, 'Test state', test_number)
		file.write(FileNumber, string.format("%g,%g,%g,%g,%s,%g,%g\r\n", curr,volt,capacity,captotal,time2,test_number,SOC))
		display.settext(display.TEXT1,string.format("voltage= %.4fV",volt)) 
		display.settext(display.TEXT2,string.format("current= %.2fA,time = %.2fHrs2", curr, hours))
		iteration=(iteration+1)
		iteration2=(iteration2+1)
		delay(1)
		aux=(aux+1)
		contador=contador+1
	end
	smu.source.output=smu.OFF
	
	ExtBuffer.clear()
	file.close(FileNumber)
	print('Fin función de medición voc_bor')
end

function cc_capacity_load(voltlimit, current, load_cap, SOC_0, cell_captotal, currlimit, test_number)
	
	reset()
	
	-- Creación buffer para guardar datos
	ExtBuffer = buffer.make(300000)
	
	keithley_control()
	
	-- Definicion de archivo procedure
	procedure = "cc_capacity_load"
	
	FileNumber=file.open("/usb1/TestProcedure.csv",file.MODE_APPEND)
	print("Function: ",procedure,"voltlimit: ",voltlimit,"current: ",current,"load_cap: ",load_cap,"SOC_0: ",SOC_0,"cell_captotal: ",cell_captotal,"currlimit: ",currlimit,"test_number: ",test_number) 
	file.write(FileNumber, string.format("%s,%s,%s,%s,%s,%s,%s,%s\r\n",procedure,"voltlimit","current","load_cap","SOC_0","cell_captotal","currlimit","test_number"))
	file.write(FileNumber, string.format("%s,%g,%g,%g,%g,%g,%g,%g\r\n",procedure,voltlimit,current,load_cap,SOC_0,cell_captotal,currlimit,test_number))
	file.close(FileNumber)
	
	-- Definicion de archivo data
	FileNumber=file.open("/usb1/TestData.csv",file.MODE_APPEND)
	
	smu.measure.func=smu.FUNC_DC_CURRENT
	smu.measure.sense=smu.SENSE_4WIRE
	smu.source.func=smu.FUNC_DC_VOLTAGE
	smu.source.offmode=smu.OFFMODE_HIGHZ
	smu.source.level=voltlimit
	smu.measure.terminals=smu.TERMINALS_FRONT
	smu.source.readback=smu.ON
	smu.source.range = 7
	
	SOC = SOC_0
	deltatime = 0
	capacity = 0
	captotal = 0
	aux = 1
	
	smu.source.output=smu.ON
	
	display.changescreen(display.SCREEN_USER_SWIPE)
	
	iteration=1
	iteration2=1
	while true do
		smu.source.ilimit.level=current
		curr=smu.measure.read(ExtBuffer)
		volt=ExtBuffer.sourcevalues[iteration]
		time1=ExtBuffer.relativetimestamps[iteration]
		time2=ExtBuffer.timestamps[iteration2]
		hours = (ExtBuffer.relativetimestamps[iteration2]/3600)
		
		-- Limites de voltaje por seguridad
		if current > 0 then-- Caso carga
			if volt >= voltlimit then 
				if curr <= currlimit then
					iteration2=(iteration2+1)
					print('La corriente de la celda es menor a la corriente mínima de carga')
					print('Último voltaje detectado= ',volt)
					print('Última corriente detectada= ',curr)
					break
				end 
			end
		elseif current < 0 then -- Caso descarga
			if curr > -currlimit then 
				iteration2=(iteration2+1)
				print('La corriente de la celda es menor a la corriente minima')
				print('Último voltaje detectado= ',volt)
				print('Última corriente detectada= ',curr)
				break 
			end
		else -- Si la corriente es nula, decir que el valor es invalido
			print('Valor inválido de corriente')
			print('Último voltaje detectado= ',volt)
			print('Última corriente detectada= ',curr)
			break
		end
		
		-- Detección de capacidad carga/descarga
		if current > 0 then -- Caso carga
			if captotal >= load_cap then 
				iteration2 = iteration2 + 1
				print('se cargo la capacidad pedida')
				print('Último voltaje detectado= ',volt)
				print('Última corriente detectada= ',curr)
				break
			end
		elseif current < 0 then -- Caso descarga
			if captotal <= -load_cap then 
				iteration2 = iteration2 + 1
				print('se descargo la capacidad pedida')
				print('Último voltaje detectado= ',volt)
				print('Última corriente detectada= ',curr)
				break
			end
		else -- Si la corriente es nula, decir que el valor es invalido
			print('Valor inválido de corriente')
			print('Último voltaje detectado= ',volt)
			print('Última corriente detectada= ',curr)
			break
		end
		
		if aux >= 2 then
			deltatime = time1 - ExtBuffer.relativetimestamps[iteration-1]
			capacity = curr*deltatime/3.6 -- en mAh
			SOC = SOC + (capacity/cell_captotal)*100
			captotal = captotal + capacity
		end
		print("Iteration: ",iteration2,"voltage: ", volt,"current: ", curr, "time: ", time2, "deltatime: ",deltatime, "cap [mAh]", capacity, "cap total [mAh]", captotal, 'SOC', SOC, 'Test state', test_number)
		file.write(FileNumber, string.format("%g,%g,%g,%g,%s,%g,%g\r\n", curr,volt,capacity,captotal,time2,test_number,SOC))
		display.settext(display.TEXT1,string.format("voltage= %.4fV",volt)) 
		display.settext(display.TEXT2,string.format("current= %.2fA,time = %.2fHrs2", curr, hours))
		iteration=(iteration+1)
		iteration2=(iteration2+1)
		delay(1)
		aux=(aux+1)
	end
	
	smu.source.output=smu.OFF
	
	ExtBuffer.clear()
	file.close(FileNumber)
	print('Fin función cc_capacity_load')
	print('Último valor de SOC = ',SOC)
	
	return SOC
end

function custom_profile(SOC_0,cell_captotal,upper_voltlimit,lower_voltlimit,test_number)
	
	reset()
	
	-- Definicion de archivo procedure
	procedure = "custom_profile"
	
	FileNumber=file.open("/usb1/TestProcedure.csv",file.MODE_APPEND)
	print("Function: ",procedure,"SOC_0: ",SOC_0,"cell_captotal: ",cell_captotal,"upper_voltlimit: ",upper_voltlimit,"lower_voltlimit: ",lower_voltlimit,"test_number: ",test_number) 
	file.write(FileNumber, string.format("%s,%s,%s,%s,%s,%s\r\n",procedure,"SOC_0","cell_captotal","upper_voltlimit","lower_voltlimit","test_number"))
	file.write(FileNumber, string.format("%s,%g,%g,%g,%g,%g\r\n",procedure,SOC_0,cell_captotal,upper_voltlimit,lower_voltlimit,test_number))
	file.close(FileNumber)
	
	-- Creación buffer para guardar datos
	csv_buffer = buffer.make(300000, buffer.STYLE_WRITABLE)
	buffer.write.format(csv_buffer, buffer.UNIT_AMP, buffer.DIGITS_8_5)
	
	-- Se abre el archivo para guardar data
	FileNumber=file.open("/usb1/csv_test.csv",file.MODE_READ)
	
	contador = 0
	while true do
		
		var = file.read(FileNumber, file.READ_LINE)

		if var == nil then
			print("var nil")
			break
		end
		
		numvar = var + 0
		print(numvar)
		
		buffer.write.reading(csv_buffer, numvar)
		contador = (contador+1)
	end
	file.close(FileNumber)
	
	ExtBuffer = buffer.make(300000)
	
	keithley_control()
	
	-- Definicion de archivo data
	FileNumber=file.open("/usb1/TestData.csv",file.MODE_APPEND)

	smu.measure.func = smu.FUNC_DC_CURRENT -- Se mide corriente
	smu.measure.sense = smu.SENSE_4WIRE -- Se cambia el sistema de medición a 4-wire para más precisión
	smu.source.func = smu.FUNC_DC_VOLTAGE -- Se alimenta voltaje
	smu.source.offmode = smu.OFFMODE_HIGHZ -- Modo cuando la carga de desconecta para aislar el equipo
	smu.measure.terminals = smu.TERMINALS_FRONT
	smu.source.readback = smu.ON
	
	-- definición de variables del proceso
	deltatime = 0
	capacity = 0
	captotal = 0
	aux = 1
	iteration=1
	iteration2=1
	SOC = SOC_0
	
	--smu.source.range=7
	smu.source.autorange = smu.ON
	smu.measure.autorange = smu.ON
	--smu.measure.range = 4
	smu.source.output=smu.ON -- Se inicia la conexión con la carga
	display.changescreen(display.SCREEN_USER_SWIPE)
	
	while true do
		
		-- definición de variables por ciclo
		smu.source.ilimit.level=csv_buffer[iteration]
		
		-- detección de carga/descarga
		if csv_buffer[iteration] <= 0 then 
			smu.source.level = (lower_voltlimit-0.05) -- Caso descarga
		else
			smu.source.level = upper_voltlimit -- Caso carga
		end
		
		curr=smu.measure.read(ExtBuffer)
		volt=ExtBuffer.sourcevalues[iteration]
		time1=ExtBuffer.relativetimestamps[iteration]
		time2=ExtBuffer.timestamps[iteration2]
		hours = (ExtBuffer.relativetimestamps[iteration2]/3600)
		
		-- detección de limite de voltaje inferior
		if volt <= lower_voltlimit then 
			iteration2=(iteration2+1)
			print('El voltaje de la celda es menor al voltaje mínimo de descarga')
			print('Último voltaje detectado= ',volt)
			print('Última corriente detectada= ',curr)
			break 
		end
	
		
		-- capacidad acumulada
		if aux >= 2 then
			deltatime = time1 - ExtBuffer.relativetimestamps[iteration-1]
			capacity = curr*deltatime/3.6 -- en mAh (Asumo error en fuente de corriente)
			SOC = SOC + (capacity/cell_captotal)*100
			captotal = captotal + capacity
		end
		
		print("Iteration: ",iteration2,"voltage: ", volt,"current: ", curr, "time: ", time2, "deltatime: ",deltatime, "cap [mAh]", capacity, "cap total [mAh]", captotal, 'SOC', SOC, 'Test state', test_number) 
		file.write(FileNumber, string.format("%g,%g,%g,%g,%s,%g,%g\r\n",curr,volt,capacity,captotal,time2,test_number,SOC))
		display.settext(display.TEXT1,string.format("voltage= %.4fV",volt)) 
		display.settext(display.TEXT2,string.format("current= %.2fA,time = %.2fHrs2", curr, hours))
		iteration=(iteration+1)
		
		if iteration > contador then
			print('El perfil ya no tiene más valores de corriente')
			print('Último voltaje detectado= ',volt)
			print('Última corriente detectada= ',curr)
			break
		end
		
		iteration2=(iteration2+1)
		delay(1)
		aux=(aux+1)
	end
	
	-- se desconecta la carga del equipo
	smu.source.output=smu.OFF
	
	-- se limpia el buffer
	ExtBuffer.clear()
	file.close(FileNumber)
	
	print('Fin función custom_load')
end

function keithley_control() 
	-- Función para cambiar pins que dan el control de la prueba al keithley
	 
	-- Declaramos los pineas como input y output
	-- Se usa el pin 1 como output y el 2 como input
	digio.line[1].mode = digio.MODE_DIGITAL_OUT
	digio.line[2].mode = digio.MODE_DIGITAL_IN
	digio.line[3].mode = digio.MODE_DIGITAL_OUT
	digio.line[4].mode = digio.MODE_DIGITAL_OUT 
	
	-- Se setean los pins para darlo control al keithley
	digio.line[1].state = 1 -- (KEITHLEY TOMA CONTROL) Se configura el out = 1 para que la acción la ejecute el keithley
	delay(2)
	digio.line[4].state = 1 -- (SE CONECTA LA CELDA AL KEITHLEY )Enviamos un 0 porque no queremos desactivar el Normally Open aún
	delay(2)
	digio.line[3].state = 0 -- (SE DEJA DE ENVIAR LA SEÑAL PARA CONECTAR LA CELDA AL EIS) Enviamos un 1 para activar fuente y Normally Open del Rele	
end

function EIS_control(SOC_0,cell_captotal,test_number) 
	-- Función para cambiar pins que dan el control de la prueba al EIS

	-- Declaramos los pineas como input y output
	-- Se usa el pin 1 como output y el 2 como input
	digio.line[1].mode = digio.MODE_DIGITAL_OUT
	digio.line[2].mode = digio.MODE_DIGITAL_IN
	digio.line[3].mode = digio.MODE_DIGITAL_OUT
	digio.line[4].mode = digio.MODE_DIGITAL_OUT 
	
	-- Se setean los pins para darle control al EIS
	digio.line[3].state = 1 -- (CELDA CONECTADA AL EIS) Enviamos un 1 para activar fuente y Normally Open del Rele
	delay(2)
	digio.line[4].state = 0 -- Enviamos un 0 porque no queremos desactivar el Normally Open aún
	delay(2)
	digio.line[1].state = 0 -- (KEITHLEY DEJA DE OPERAR)Enviamos un 0 para darle la acción al EIS y no al keithley
	
	-- Definicion de archivo procedure
	procedure = "EIS"
	
	FileNumber=file.open("/usb1/TestProcedure.csv",file.MODE_APPEND)
	print("Function: ",procedure,"SOC_0: ",SOC_0,"cell_captotal: ",cell_captotal,"test_number: ",test_number) 
	file.write(FileNumber, string.format("%s,%s,%s,%s\r\n",procedure,"SOC_0","cell_captotal","test_number"))
	file.write(FileNumber, string.format("%s,%g,%g,%g\r\n",procedure,SOC_0,cell_captotal,test_number))
	file.close(FileNumber)
	
	
	print("Señal enviada, EIS tomo control")
	while digio.line[2].state != digio.STATE_HIGH do
		print(digio.line[2].state)
		delay(1)
	end
end