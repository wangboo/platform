#build netfrmd


cc = g++ 
#flags = -W -g -march=i486
flags = -W -g



TARGET=demo

all: $(TARGET)

OBJS = $(patsubst %.cpp,obj/%.o,$(wildcard *.cpp))

obj/%.o: %.h
obj/%.o: %.cpp
	$(cc) $(flags)  -c $< -o $@ 

$(TARGET): $(OBJS) $(PBOBJS)
	$(cc) -o $(TARGET) $(OBJS) $(PBOBJS) 

clean:
	-rm obj/*.o	
