veggies = []
with open("photos.txt", "r") as veggiefile:
	for line in veggiefile:
		veggies.append(line[:len(line)-2])
print veggies