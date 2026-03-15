/// Returns one of the 8 directions based on an angle
/proc/angle_to_dir(angle)
	switch(angle)
		if(338 to 360, 0 to 22)
			return NORTH
		if(23 to 67)
			return NORTHEAST
		if(68 to 112)
			return EAST
		if(113 to 157)
			return SOUTHEAST
		if(158 to 202)
			return SOUTH
		if(203 to 247)
			return SOUTHWEST
		if(248 to 292)
			return WEST
		if(293 to 337)
			return NORTHWEST
