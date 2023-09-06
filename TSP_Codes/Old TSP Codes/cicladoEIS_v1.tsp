function cicladoEIS_v1(ciclos_macro, ciclos_micro)
	-- ciclado de la celda con pruebas de EIS y Voc entre descargas
	
	-- Creación buffer para guardar datos
	reset() 
	ExtBuffer = buffer.make(300000)
	
	-- Definicion de archivo data
	FileNumber=file.open("/usb1/TestData.csv",file.MODE_WRITE)
	file.write(FileNumber, "Current, Voltage, Capacity, Cumulative_capacity, Seconds, Test_State, SOC\r\n")
	
	-- Declaramos los pineas ocmo input y output
	-- Se usa el pin 1 como output y el 2 como input
	digio.line[1].mode = digio.MODE_DIGITAL_OUT
	digio.line[2].mode = digio.MODE_DIGITAL_IN
	digio.line[3].mode = digio.MODE_DIGITAL_OUT
	digio.line[4].mode = digio.MODE_DIGITAL_OUT

	-- El keithley toma control de la prueba
	keithley_control() 
	
	-- INICIO DEL EXPERIMENTO
	print('keithley comienza tomando el control')
	delay(10)
	print('keithley esta realizando las pruebas iniciales')
	discharge(2.5, 1.25, 1, -1) -- (voltaje descargado,corriente de descarga, número de identificación data, SOC en data)
	resting(2.5, 300, 2, -1) -- esta es una descarga a 0A (voltaje limite descarga,segundos de descanso,número de identificación data, SOC en data)
	print('keithley termino las pruebas iniciales')
	
	for j = 1, ciclos_macro do
	
		print('keithley tomando el control')
		delay(10)
		print('keithley esta realizando las pruebas')
		captotal_carga = charge(4.2, 1.25, 0.05, 3, -1) -- (voltaje carga,corriente carga,corriente de corte CV, número de identificación data, SOC en data)
		resting(2.5, 300, 2, -1) -- esta es una descarga a 0A (voltaje limite descarga,segundos de descanso,número de identificación data)
		
		-- Definición de variables iniciales de la celda
		SOC = 100
		iteration2 = 1
		porcen_desc = 0.05
		contador_rest = 240
		
		cap_parcial=captotal_carga*porcen_desc
		ciclos_parciales = 1
		nciclos_parciales = 1/porcen_desc
		
		print('keithley termino las pruebas')
		
		-- PRUEBA EIS INICIAL
		print("EIS tomando control")
		EIS_control()
		print("Señal enviada, EIS tomo control")
		-- Se espera a que el EIS mande una señal High indicando el término de su experimento
		keithley_listen()
		print('EIS termino la prueba inicial')
		
		-- CICLADO DESCARGA + EIS + Voc + VBor
		while true do
			if ciclos_parciales > nciclos_parciales then
				break
			end
			
			-- PRUEBA KEITHLEY MICRO
			print('el keithley esta haciendo pruebas dentro del ciclo micro')
			capacity_discharge(2.5, 1.25, 200, 4, SOC) --(voltaje descarga, corriente de descarga, capacidad descargada, número de identificación data, SOC en data)
			SOC = SOC - (porcen_desc*100)
			vocbor_measure(2.5, 5, SOC) -- esta es una descarga a 0A (voltaje descarga, número de identificación data, SOC en data)
			resting(2.5, 180, 2, SOC) -- esta es una descarga a 0A (voltaje limite descarga,segundos de descanso,número de identificación data, SOC en data)
			vocbor_measure(2.5, 6, SOC)-- esta es una descarga a 0A (voltaje descarga, número de identificación data, SOC en data)
			print('el keithley dejo de hacer pruebas dentro del ciclo micro')
			
			-- PRUEBA EIS MICRO
			print("EIS tomando control")
			EIS_control()
			print("Señal enviada, EIS tomo control")
			-- Se espera a que el EIS mande una señal High indicando el término de su experimento
			keithley_listen()
			print('EIS termino la prueba')
			
			print('Keithley esta tomando control')
			keithley_control()
			print('keithley tomo control')
			
			ciclos_parciales = ciclos_parciales + 1
		end
		captotal_carga = charge(4.2, 1.25, 0.05, 3, -1) -- (voltaje carga,corriente carga,corriente de corte CV, número de identificación data)
	end
	smu.source.output=smu.OFF
	ExtBuffer.clear()
	file.close(FileNumber)
end