#-------------------------------------------------------------------------------
#
#
#-------------------------------------------------------------------------------
#
# There are 3 sysroots involved in building the final product:
#
# - toolchain sysroot -- Built when the toolchain is built.  Contains
#                        all the files needed by the toolchain.
#
# - development sysroot -- Starts as a pristine copy of the toolchain
#                          sysroot.  Intermediate build products and
#                          libraries are installed here.
#
# - final sysroot -- final executables and libraries we really want
#                    are installed here plus any additional files
#                    required from the toolchain sysroot.  The final
#                    sysroot has all of its binaries stripped.

ROOTCONFDIR		= $(CONFDIR)/onie
SYSROOT_INIT_STAMP	= $(STAMPDIR)/sysroot-init
SYSROOT_CHECK_STAMP	= $(STAMPDIR)/sysroot-check
SYSROOT_COMPLETE_STAMP	= $(STAMPDIR)/sysroot-complete
SYSROOT			= $(SYSROOT_COMPLETE_STAMP)
DEV_SYSROOT_INIT_STAMP	= $(STAMPDIR)/dev-sysroot-init

#-------------------------------------------------------------------------------

# the target for SYSROOT_COMPLETE is defined in make/images.make.

PHONY += sysroot-init dev-sysroot-init

sysroot-init: $(SYSROOT_INIT_STAMP)
$(SYSROOT_INIT_STAMP): $(TREE_STAMP)
	$(Q) rm -f $@ && eval $(PROFILE_STAMP)
	$(Q) echo "==== Preparing a new sysroot directory ===="
	$(Q) rm -rf $(SYSROOTDIR)
	$(Q) mkdir -p -v $(SYSROOTDIR)
	$(Q) mkdir -p -v -m 0755 $(SYSROOTDIR)/dev
	$(Q) mkdir -p -v $(SYSROOTDIR)/{sys,proc,tmp,etc,lib,mnt}
	$(Q) mkdir -p -v $(SYSROOTDIR)/{var/log,usr/lib,usr/bin,usr/sbin,usr/share,lib,mnt}
	$(Q) touch $@

# Development sysroot, used for compiling and linking user space
# applications and libraries.
dev-sysroot-init: $(DEV_SYSROOT_INIT_STAMP)
$(DEV_SYSROOT_INIT_STAMP): $(TREE_STAMP) | $(XTOOLS_BUILD_STAMP)
	$(Q) rm -f $@ && eval $(PROFILE_STAMP)
	$(Q) echo "==== Preparing a new development sysroot ===="
	$(Q) rm -rf $(DEV_SYSROOT)
	$(Q) cp -a $$($(CROSSBIN)/$(CROSSPREFIX)gcc -print-sysroot) $(DEV_SYSROOT)
	$(Q) find $(DEV_SYSROOT) -print0 | xargs -0 chmod +w
	$(Q) touch $@

#---

USERSPACE_CLEAN += sysroot-clean
sysroot-clean:
	$(Q) rm -rf $(DEV_SYSROOT) $(SYSROOTDIR)
	$(Q) rm -f $(SYSROOT_INIT_STAMP) $(SYSROOT_CHECK_STAMP) $(SYSROOT_COMPLETE_STAMP)
	$(Q) rm -f $(DEV_SYSROOT_INIT_STAMP)
	$(Q) echo "=== Finished making $@ for $(PLATFORM)"

#
# Local Variables:
# mode: makefile-gmake
# End:
