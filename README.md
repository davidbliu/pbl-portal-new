# PBL Members Portal
```
  _____  ____  _        _____           _        _ 
 |  __ \|  _ \| |      |  __ \         | |      | |
 | |__) | |_) | |      | |__) |__  _ __| |_ __ _| |
 |  ___/|  _ <| |      |  ___/ _ \| '__| __/ _` | |
 | |    | |_) | |____  | |  | (_) | |  | || (_| | |
 |_|    |____/|______| |_|   \___/|_|   \__\__,_|_|
```

# Overview

3 core services, members, points, and tabling

# Documentation

## Google Authentication

See auth_controller. handles the auth/google_oauth2/callback route

# Design

## Tabling

### Tabling Manager

class methods 
- tabling_schedule
	- generate Hash. key is tabling day. values are tabling slots (ordered by time)
- generate_tabling_slots(assignments)
- generate_tabling_assignments(times, members)
	- times and members are arrays of times you want and member ids to include

### Tabling Slot

instance methods
- time
- day (0 through 6)
- hour (0 through 23)
- members
	- Array of Member objects
- member_ids
	- Array of member ids
- time_string?
	- returns a string for this slots time? (formatted to be displayed easily by frontend)