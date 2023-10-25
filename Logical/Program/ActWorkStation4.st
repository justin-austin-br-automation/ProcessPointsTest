ACTION ActWorkStation4:
	WorkStation4.ReadInfo.Enable := TRUE;
	
	CASE WorkStation4.Step OF
		WAIT:
			IF WorkStation4.GetShuttle.Enable  AND WorkStation4.GetShuttle.TotalCount = 0 THEN
				WorkStation4.GetShuttle.Enable := FALSE;
			ELSIF NOT WorkStation4.GetShuttle.Enable THEN
				WorkStation4.GetShuttle.Enable := TRUE;
			ELSIF WorkStation4.GetShuttle.TotalCount <> 0 THEN
				WorkStation4.Timer.PT := T#2s;
				WorkStation4.Timer.IN := TRUE;
				WorkStation4.Step := PROCESS;
			END_IF
			
		PROCESS:
			WorkStation4.Command.Command := mcACPTRAK_BARRIER_ADD_TICKETS;
			WorkStation4.Command.AdvancedParameters.TicketCount := 1;
			
			IF WorkStation4.Timer.Q THEN
				WorkStation4.Timer.IN := FALSE;
				WorkStation4.Command.Execute := TRUE;
			ELSIF WorkStation4.Command.Done THEN
				WorkStation4.Command.Execute := FALSE;
				WorkStation4.Step := WAIT;
			END_IF
			
	END_CASE
	
	WorkStation4.Command();
	WorkStation4.ElasticMoveVel();
	WorkStation4.GetShuttle();
	WorkStation4.ReadInfo();
	WorkStation4.RoutedMoveVel();
	WorkStation4.Timer();
END_ACTION