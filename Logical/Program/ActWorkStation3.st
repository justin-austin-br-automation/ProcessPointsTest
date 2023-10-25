ACTION ActWorkStation3:
	CASE WorkStation3.Step OF
		WAIT:
			IF WorkStation3.GetShuttle.TotalCount <> 0 THEN
				WorkStation3.Timer.PT := T#2s;
				WorkStation3.Timer.IN := TRUE;
				WorkStation3.Step := PROCESS;
			END_IF
			
		PROCESS:
			WorkStation3.Command.Command := mcACPTRAK_BARRIER_ADD_TICKETS;
			WorkStation3.Command.AdvancedParameters.TicketCount := 1;
			
			IF WorkStation3.Timer.Q THEN
				WorkStation3.Timer.IN := FALSE;
				WorkStation3.Command.Execute := TRUE;
			ELSIF WorkStation3.Command.Done THEN
				WorkStation3.Command.Execute := FALSE;
				WorkStation3.Step := WAIT;
			END_IF
			
	END_CASE
	
	WorkStation3.Command();
	WorkStation3.ElasticMoveVel();
	WorkStation3.GetShuttle();
	WorkStation3.ReadInfo();
	WorkStation3.RoutedMoveVel();
	WorkStation3.Timer();
END_ACTION