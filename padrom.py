import sys 		#argv
f = open(sys.argv[1],'rb')
inby = f.read()
f.close()
outby=[]
i = 0
while i < len(inby): 	#create bytes array
	outby.append(inby[i])
	i += 1
i = 0
romsize=(8*1024)-10 	#or 8 or 16
if(len(inby)>romsize):
	print("Binary too large! Quitting.")
	sys.exit()
while i < romsize-len(inby):
	outby.append(0xEA) # 6502 NOP
	i += 1
f = open("vectors.o",'rb')
vectors = f.read()
f.close()
i = 0
while i < len(vectors):
	outby.append(vectors[i])
	i += 1
f = open('out.pce','wb')
i = 0
while i < len(outby):
	f.write(bytes([outby[i]]))
	i += 1
print("out.pce written: ",len(outby),"bytes")
f.close()
