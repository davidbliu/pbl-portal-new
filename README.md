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

The 'portal' refers to this web application which provides three main services: member database, points, and tabling. This README is meant to be a developers guide to getting started with the portal

# Installation

See the installation instructions on Piazza (TODO duplicate them here)

# Frontend Documentation

We expect only these models/methods to be exposed to the frontend. Here is documentation for the methods that you need to develop a frontend for the portal

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