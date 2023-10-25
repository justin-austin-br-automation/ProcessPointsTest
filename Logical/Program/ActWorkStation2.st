ACTION ActWorkStation2:
	WorkStation2.ReadInfo.Enable := TRUE;
	
	CASE WorkStation2.Step OF
		WAIT:
			IF WorkStation2.GetShuttle.Enable  AND WorkStation2.GetShuttle.TotalCount = 0 THEN
				WorkStation2.GetShuttle.Enable := FALSE;
			ELSIF NOT WorkStation2.GetShuttle.Enable THEN
				WorkStation2.GetShuttle.Enable := TRUE;
			ELSIF WorkStation2.GetShuttle.TotalCount <> 0 THEN
				WorkStation2.Timer.PT := T#2s;
				WorkStation2.Timer.IN := TRUE;
				WorkStation2.Step := PROCESS;
			END_IF
			
		PROCESS:
			WorkStation2.Command.Command := mcACPTRAK_BARRIER_ADD_TICKETS;
			WorkStation2.Command.AdvancedParameters.TicketCount := 1;
			
			IF WorkStation2.Timer.Q THEN
				WorkStation2.Timer.IN := FALSE;
				WorkStation2.Command.Execute := TRUE;
			ELSIF WorkStation2.Command.Done THEN
				WorkStation2.Command.Execute := FALSE;
				WorkStation2.Step := WAIT;
			END_IF
			
	END_CASE
	
	WorkStation2.Command();
	WorkStation2.ElasticMoveVel();
	WorkStation2.GetShuttle();
	WorkStation2.ReadInfo();
	WorkStation2.RoutedMoveVel();
	WorkStation2.Timer();
END_ACTION