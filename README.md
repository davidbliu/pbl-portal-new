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

The 'portal' refers to this web application which provides three main services: member database, points, and tabling. 

Recent additions to the portal are __PBL Links__ and __Deliberations__.

# Installation

Installation steps are provided in install.sh (for Ubuntu 14.04) and mac_install.sh (for mac). You can run these scripts like "sudo sh install.sh"


# Design

## Member Database

### Member (Model)

see app/moodels/members.rb for more details

class methods
- member_hash
	- keys are ids. values are Member objects
- current_members_dict
	- same as members_hash except only contains current members
- current_members
	- Array of current members (cm, chair, exec. gm not included)
- current_officers
- current_execs


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
