CC=spcomp
OBJECTS=readyup.smx pause.smx playermanagement.smx readyup_test.smx

all: $(OBJECTS)

%.smx: %.sp
	$(CC) -o=$@ $<

.PHONY : clean
clean:
	-rm $(OBJECTS)
