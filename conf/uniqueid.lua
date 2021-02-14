local conf = {
	collname = "wind_uniqueid",
	
	uniqueid_list = {
		{
			name = "userid",
			type = "inc_num",
			persistent = true,
			start_num = 100000
		},
		{
			name = "roomid",
			type = "random_num",
			persistent = false,
			length = 6
		}
	}
}

return conf