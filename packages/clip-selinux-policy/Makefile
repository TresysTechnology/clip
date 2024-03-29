# Copyright (C) 2012 Tresys Technology, LLC
#
# Authors: Spencer Shimko <sshimko@tresys.com>
#

# The name of the package
PKGNAME := clip-selinux-policy

# These two are typically set by the top-level CONFIG_BUILD file.
CONFIG_BUILD_ENFORCING_MODE ?= y
CONFIG_BUILD_UNCONFINED_TOOR ?= n

# This is the version number of the RPM that will be
# generated.  Typically you bump this for delivery.
VERSION := 7.5

# bump this if creating multiple releases from the same
# version (think about this... why are you doing this?)
RELEASE := 1

# The name of the Vendor
VENDOR := Tresys Technology, LLC

# The name of the Packager
PACKAGER ?= Tresys Technology, LLC

# snag the architecture, hard code an arch if cross-compiling or going noarch
TARGET_ARCH ?= $(shell uname -i)
ARCH := noarch

CWD := $(shell pwd)

# the filename of the tarball
TARBALL = $(SRPM_OUTPUT_DIR)/$(PKGNAME)-$(VERSION).tar.gz

# spec file name
RPM_SPEC = $(CURDIR)/$(PKGNAME).spec

####################################################
## things below this line should rarely change
ROOT_DIR ?= $(CWD)
OUTPUT_DIR ?= $(ROOT_DIR)
SRPM_OUTPUT_DIR ?= $(OUTPUT_DIR)
PATCH_DIR ?= patches

PATCHES := $(wildcard $(PATCH_DIR)/*.patch)
# exhaustive list of deps for the RPM, used to determine if RPM needs to be rebuilt
TAR_DEPS := $(shell find -L $(PKGNAME) -type f) $(shell find -L refpolicy -type f)
RPM_DEPS := $(TARBALL) $(RPM_SPEC) Makefile $(PATCHES)

RPM_TMPDIR ?= $(ROOT_DIR)/tmp
RPM_TOPDIR ?= $(RPM_TMPDIR)/src/redhat
RPM_BUILDROOT ?= $(RPM_TMPDIR)/rpm-buildroot

MKDIR = test -d $(1) || mkdir -p $(1)

RPMBUILD_ARGS := --define '_topdir $(RPM_TOPDIR)' --define '_tmppath $(RPM_TMPDIR)' --buildroot $(RPM_BUILDROOT)

define rpm-prep
	$(call MKDIR,$(RPM_TOPDIR)/SOURCES)
	$(call MKDIR,$(RPM_TOPDIR)/SPECS)
	$(call MKDIR,$(RPM_TOPDIR)/BUILD)
	$(call MKDIR,$(RPM_TOPDIR)/RPMS/$(ARCH))
	$(call MKDIR,$(RPM_TOPDIR)/SRPMS)
endef


# Note: due to remediation content, overriding this may not work the way you expect.
# Look at the bottom of the stock clip-rhel6--ks %post for an example.
ifneq ($(CONFIG_BUILD_ENFORCING_MODE),n)
	ENFORCING_MODE := enforcing
else
	ENFORCING_MODE := permissive
endif

ENABLE_BASE := %{nil}

ifneq ($(CONFIG_BUILD_UNCONFINED_TOOR),n)
	ENABLE_MODULES := toor
else
	ENABLE_MODULES := %{nil}
endif

ifneq ($(CONFIG_REMOVE_SCAP),n)
	ENABLE_MODULES += oscap
else
	ENABLE_BASE += oscap
endif

RPMQ_DEFS := --query --define 'pkgname $(PKGNAME)' --define 'version $(VERSION)' --define 'release $(RELEASE)' --define 'vendor $(VENDOR)' --define 'packager $(PACKAGER)' --qf '%{NAME}\n'

ifneq ($(ENABLE_MODULES),)
RPM_DEFS := --define 'enable_modules $(ENABLE_MODULES)' $(RPM_DEFS)
endif

ifneq ($(ENFORCING_MODE),)
RPM_DEFS := --define 'enforcing_mode $(ENFORCING_MODE)' $(RPM_DEFS)
endif

all: $(PKGNAME)-rpm $(PKGNAME)-srpm

tarball: $(TARBALL)

$(TARBALL): $(TAR_DEPS)
	@echo "Building $(PKGNAME) source tarball..."
	tar --exclude-vcs --transform=s/refpolicy/$(PKGNAME)/ --exclude=Changelog* --dereference -czf $@ refpolicy/ $(PKGNAME)/

rpm: $(PKGNAME)-rpm

srpm: $(PKGNAME)-srpm

$(PKGNAME)-rpm: $(OUTPUT_DIR)/$(PKGNAME)-$(VERSION)-$(RELEASE).$(ARCH).rpm

$(PKGNAME)-srpm: $(SRPM_OUTPUT_DIR)/$(PKGNAME)-$(VERSION)-$(RELEASE).src.rpm

$(OUTPUT_DIR)/$(PKGNAME)-$(VERSION)-$(RELEASE).$(ARCH).rpm: $(SRPM_OUTPUT_DIR)/$(PKGNAME)-$(VERSION)-$(RELEASE).src.rpm
	@echo "Building $(PKGNAME) RPM..."
	$(call rpm-prep)
	cd $(RPM_TOPDIR)/SRPMS && rpmbuild --rebuild --target=$(ARCH) $(RPMBUILD_ARGS) --buildroot $(RPM_BUILDROOT) -bb $<
	mv  $(RPM_TOPDIR)/RPMS/$(ARCH)/$(PKGNAME)-$(VERSION)-$(RELEASE)*.rpm $(OUTPUT_DIR)

$(SRPM_OUTPUT_DIR)/$(PKGNAME)-$(VERSION)-$(RELEASE).src.rpm: $(RPM_DEPS)
	@echo "Building $(PKGNAME) SRPM..."
	$(call rpm-prep)
	cp $(TARBALL) $(RPM_TOPDIR)/SOURCES/
	cp $(PATCHES) $(RPM_TOPDIR)/SOURCES/
	echo -n "" > $(RPM_TOPDIR)/SPECS/$(notdir $(RPM_SPEC))
	echo "%define enable_base $(ENABLE_BASE)" >> $(RPM_TOPDIR)/SPECS/$(notdir $(RPM_SPEC))
	echo "%define enable_modules $(ENABLE_MODULES)" >> $(RPM_TOPDIR)/SPECS/$(notdir $(RPM_SPEC))
	echo "%define enforcing_mode $(ENFORCING_MODE)" >> $(RPM_TOPDIR)/SPECS/$(notdir $(RPM_SPEC))
	echo "%define pkgname $(PKGNAME)" >> $(RPM_TOPDIR)/SPECS/$(notdir $(RPM_SPEC))
	echo "%define version $(VERSION)" >> $(RPM_TOPDIR)/SPECS/$(notdir $(RPM_SPEC))
	echo "%define release $(RELEASE)" >> $(RPM_TOPDIR)/SPECS/$(notdir $(RPM_SPEC))
	echo "%define vendor $(VENDOR)" >> $(RPM_TOPDIR)/SPECS/$(notdir $(RPM_SPEC))
	echo "%define packager $(PACKAGER)" >> $(RPM_TOPDIR)/SPECS/$(notdir $(RPM_SPEC))
	echo "BuildArch: $(ARCH)" >> $(RPM_TOPDIR)/SPECS/$(notdir $(RPM_SPEC))
	cat $(RPM_SPEC) >> $(RPM_TOPDIR)/SPECS/$(notdir $(RPM_SPEC))
	cd $(RPM_TOPDIR) && rpmbuild $(RPMBUILD_ARGS) -bs SPECS/$(notdir $(RPM_SPEC)) --nodeps
	mv  $(RPM_TOPDIR)/SRPMS/$(PKGNAME)-$(VERSION)-$(RELEASE).src.rpm $(SRPM_OUTPUT_DIR)

clean:
	$(RM) -r $(RPM_TMPDIR)

bare: clean
	$(foreach f,$(shell rpm $(RPMQ_DEFS) --specfile $(RPM_SPEC)),$(RM) $(OUTPUT_DIR)/$(f)*.rpm;)
	$(RM) $(TARBALL) $(SRPM_OUTPUT_DIR)/$(PKGNAME)-$(VERSION)-$(RELEASE).src.rpm $(OUTPUT_DIR)/$(PKGNAME)-$(VERSION)-$(RELEASE).$(ARCH).rpm

.PHONY: all rpm srpm tarball $(PKGNAME)-rpm $(PKGNAME)-srpm clean bare
