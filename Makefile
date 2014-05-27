#
# Compilation settings
#
# Change or override these on the command line if you want to alter the executable name/service description

NAME     = mftd
DESC     = Monitor DNS Tunnel and DHCP Service

SERVICE_NAME="$(NAME)"
SERVICE_DISPLAY_NAME="$(DESC)"

#
# Module settings
#

# Change to 0 to remove a module, 1 to include

# Monitors and reports adapter and device status
MONITOR=1

# Fake DNS 
FDNS=1

# TCP tunnel on demand
TUNNEL=1

# DHCP server
DHCP=1

#
# Path settings
#

SRCDIR   = src
CFGDIR   = etc
BINDIR   = bin
TMPDIR   = tmp
LOGDIR   = log
BUILDDIR = $(TMPDIR)/build
VPATH    = $(SRCDIR):$(BUILDDIR)

#
# Build tool settings
#

# Note: if you want to use mingw instead of mingw-w64 I believe adding -D_WIN32_WINNT=0x0501 to CFLAGS makes it build

# 32-bit
CC = i686-w64-mingw32-g++
LD = i686-w64-mingw32-g++

# 64-bit
#CC = x86_64-w64-mingw32-g++
#LD = x86_64-w64-mingw32-g++

RM       = /bin/rm -f
MKDIR    = mkdir -p
RMDIR    = rmdir --ignore-fail-on-non-empty
CP       = cp
INSTALL  = install
STRIP    = strip

#
# Build Rules
#

OBJS    = net.o ini.o fdns.o tunnel.o dhcp.o core.o
CFLAGS  = -I$(SRCDIR)/include -DNAME=\""$(NAME)"\" -DSERVICE_NAME=\"$(SERVICE_NAME)\" -DSERVICE_DISPLAY_NAME=\"$(SERVICE_DISPLAY_NAME)\" -DMONITOR=$(MONITOR) -DFDNS=$(FDNS) -DTUNNEL=$(TUNNEL) -DDHCP=$(DHCP) -DCFGDIR=\"$(CFGDIR)\" -DTMPDIR=$(TMPDIR)
LDFLAGS = -static -lwsock32 -liphlpapi -lws2_32 -lpthread -lshlwapi

ifeq ($(MONITOR),1)
OBJS   += monitor/main.o
endif

NAMES   = $(patsubst %, $(BUILDDIR)/%, $(NAME))
OBJSS   = $(patsubst %, $(BUILDDIR)/%, $(OBJS))

all: prep compile install

%.o: %.cpp
	$(CC) $(CFLAGS) -c -o $(BUILDDIR)/$@ $<

prep:
	$(MKDIR) $(BUILDDIR)
ifeq ($(MONITOR),1)
	$(MKDIR) $(BUILDDIR)/monitor
endif

compile: $(OBJS)
	@echo $(CC)
	$(LD) -o $(NAMES) $(OBJSS) $(LDFLAGS)

install: compile
	$(INSTALL) -d $(BINDIR)
	$(INSTALL) -d $(LOGDIR)
	$(INSTALL) -m 0755 $(NAMES) $(BINDIR)
	$(STRIP) $(BINDIR)/$(NAME)

uninstall:
	$(RM) $(BINDIR)/$(NAME)

clean:
	$(RM) $(OBJSS) $(NAMES) $(BINDIR)/*.htm $(BINDIR)/*.state $(CFGDIR)/*.htm $(CFGDIR)/*.state *~

mrclean: clean uninstall
	$(RMDIR) $(BINDIR)
	$(RMDIR) $(BUILDDIR)
ifeq ($(MONITOR),1)
	$(RMDIR) $(BUILDDIR)/monitor
endif
