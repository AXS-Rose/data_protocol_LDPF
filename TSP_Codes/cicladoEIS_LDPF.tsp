function cicladoEIS(ciclos_macro, lower_voltlimit, upper_voltlimit, cell_captotal, discurrent, charcurrent, currlimit, porcen_desc)
	-- ciclado de la celda con pruebas de EIS y Voc entre descargas
	
	-- Creación buffer para guardar datos
	reset() 
	ExtBuffer = buffer.make(300000)
	
	-- El keithley toma control de la prueba
	keithley_control() 
	
	FileNumber=file.open("/usb1/TestData.csv",file.MODE_APPEND)
	file.write(FileNumber, "Current, Voltage, Capacity, Cumulative_capacity, Seconds, Test_State, SOC\r\n")
	file.close(FileNumber)
	
	-- INICIO DEL EXPERIMENTO
	print('keithley comienza tomando el control')
	delay(10)
	print('keithley esta realizando las pruebas iniciales')
	cc_discharge(lower_voltlimit, discurrent, -1, cell_captotal, 1) 
	resting(lower_voltlimit, 120, 0, cell_captotal, 2)
	print('keithley termino las pruebas iniciales')
	
	for j = 1, ciclos_macro do
	
		print('keithley tomando el control')
		delay(10)
		print('keithley esta realizando las pruebas')
		captotal_carga = charge(upper_voltlimit, charcurrent, currlimit, 0, cell_captotal, 3)
		resting(lower_voltlimit, 600, 100, cell_captotal, 2)
		
		-- Definición de variables iniciales de la celda
		SOC = 100
		iteration2 = 1
		contador_rest = 240
		
		cap_parcial=captotal_carga*porcen_desc
		ciclos_parciales = 1
		nciclos_parciales = 1/porcen_desc
		
		print('keithley termino las pruebas')
		
		-- PRUEBA EIS INICIAL
		print("EIS tomando control")
		EIS_control()
		print('EIS termino la prueba inicial')
		
		-- CICLADO DESCARGA + EIS + Voc + VBor
		while true do
			if ciclos_parciales > nciclos_parciales then
				break
			end
			
			-- PRUEBA KEITHLEY MICRO
			print('el keithley esta haciendo pruebas dentro del ciclo micro')
			SOC = cc_capacity_load(lower_voltlimit, discurrent, cap_parcial, SOC, cell_captotal, currlimit, 4)
			vocbor_measure(lower_voltlimit, SOC, 5)
			resting(lower_voltlimit, contador_rest, SOC, cell_captotal, 2)
			vocbor_measure(lower_voltlimit, SOC, 6)
			print('el keithley dejo de hacer pruebas dentro del ciclo micro')
			
			-- PRUEBA EIS MICRO
			print("EIS tomando control")
			EIS_control()
			print('EIS termino la prueba')
			
			print('Keithley esta tomando control')
			keithley_control()
			print('keithley tomo control')
			
			ciclos_parciales = ciclos_parciales + 1
		end
		charge(upper_voltlimit, charcurrent, currlimit, 0, cell_captotal, 3)
	end
	smu.source.output=smu.OFF
	ExtBuffer.clear()
	file.close(FileNumber)
end