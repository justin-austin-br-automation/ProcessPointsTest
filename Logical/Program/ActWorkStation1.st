ACTION ActWorkStation1:
	CASE WorkStation1.Step OF
		WAIT:
			IF WorkStation1.GetShuttle.TotalCount <> 0 THEN
				WorkStation1.Timer.PT := T#2s;
				WorkStation1.Timer.IN := TRUE;
				WorkStation1.Step := PROCESS;
			END_IF
			
		PROCESS:
			WorkStation1.Command.Command := mcACPTRAK_BARRIER_ADD_TICKETS;
			WorkStation1.Command.AdvancedParameters.TicketCount := 1;
			
			IF WorkStation1.Timer.Q THEN
				WorkStation1.Timer.IN := FALSE;
				WorkStation1.Command.Execute := TRUE;
			ELSIF WorkStation1.Command.Done THEN
				WorkStation1.Command.Execute := FALSE;
				WorkStation1.Step := WAIT;
			END_IF
			
	END_CASE
	
	WorkStation1.Command();
	WorkStation1.ElasticMoveVel();
	WorkStation1.GetShuttle();
	WorkStation1.ReadInfo();
	WorkStation1.RoutedMoveVel();
	WorkStation1.Timer();
END_ACTION