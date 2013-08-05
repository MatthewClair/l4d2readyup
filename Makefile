CC=spcomp
OBJECTS=readyup.smx pause.smx playermanagement.smx readyup_test.smx blocktrolls.smx

.PHONY : all
all: $(OBJECTS)

%.smx: %.sp
	$(CC) -o=$@ $<

.PHONY : clean
clean:
	-rm $(OBJECTS)
