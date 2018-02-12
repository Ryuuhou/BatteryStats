GetFormattedTime(mseconds)

{
	local var, t
	if mseconds < 0
	{
		return "00:00:00"
	}
	var := Floor(mseconds/3600000)
	mseconds := mseconds - var*3600000
	if (var<10) 
		t := "0" . var . ":"
	else 
		t := var . ":"
	
	var := Floor(mseconds/60000)
	mseconds := mseconds - var*60000
	if (var<10) 
		t := t . "0" . var . ":"
	else 
		t := t . var . ":"
	var := Floor(mseconds/1000)
	if (var<10) 
		t := t . "0" . var
	else 
		t := t . var
	return t
}