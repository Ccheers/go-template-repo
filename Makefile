user	:=	$(shell whoami)
rev 	:= 	$(shell git rev-parse --short HEAD)

# GOBIN > GOPATH > INSTALLDIR
GOBIN	:=	$(shell echo ${GOBIN} | cut -d':' -f1)
GOPATH	:=	$(shell echo $(GOPATH) | cut -d':' -f1)
BIN		:= 	""

TOOLS_SHELL="./hack/tools.sh"
# golangci-lint
LINTER := bin/golangci-lint

# check GOBIN
ifneq ($(GOBIN),)
	BIN=$(GOBIN)
else
	# check GOPATH
	ifneq ($(GOPATH),)
		BIN=$(GOPATH)/bin
	endif
endif

$(LINTER): 
	curl -SL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s latest

all:
	@cd cmd/code-policeman && go build && cd - &> /dev/null

.PHONY: install
install: all
ifeq ($(user),root)
#root, install for all user
	@cp ./cmd/code-policeman/code-policeman /usr/bin
else
#!root, install for current user
	$(shell if [ -z $(BIN) ]; then read -p "Please select installdir: " REPLY; mkdir -p $${REPLY};\
	cp ./cmd/code-policeman/code-policeman $${REPLY}/;else mkdir -p $(BIN);\
	cp ./cmd/code-policeman/code-policeman $(BIN); fi)
endif
	@echo "install finished"

.PHONY: uninstall
uninstall:
	$(shell for i in `which -a code-policeman | grep -v '/usr/bin/code-policeman' 2>/dev/null | sort | uniq`; do read -p "Press to remove $${i} (y/n): " REPLY; if [ $${REPLY} = "y" ]; then rm -f $${i}; fi; done)
	@echo "uninstall finished"

.PHONY: clean
clean:
	@${TOOLS_SHELL} tidy
	@echo "clean finished"

.PHONY: fix
fix: $(LINTER)
	@${TOOLS_SHELL} fix
	@echo "lint fix finished"

.PHONY: test
test:
	@${TOOLS_SHELL} test
	@echo "go test finished"

.PHONY: test-coverage
test-coverage:
	@${TOOLS_SHELL} test_coverage
	@echo "go test with coverage finished"	

.PHONY: lint
lint: $(LINTER)
	@${TOOLS_SHELL} lint
	@echo "lint check finished"

