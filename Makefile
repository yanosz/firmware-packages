ifndef LEDE_MIRROR
  LEDE_MIRROR:=https://downloads.lede-project.org/releases/
endif

ifndef LEDE_SDK
  LEDE_SDK:=17.01.3/targets/x86/64/lede-sdk-17.01.3-x86-64_gcc-5.4.0_musl-1.1.16.Linux-x86_64.tar.xz
endif

SDK_FILE:= $(notdir $(LEDE_SDK))
SDK_URL:= $(LEDE_MIRROR)/$(LEDE_SDK)

default: world

clean:
	$(RM) -rf target

target:
	mkdir -p target
	mkdir -p tmp
	wget -c $(SDK_URL) -O tmp/$(SDK_FILE)
	tar -C target --strip 1 -xf tmp/$(SDK_FILE)

target/.config: target
	echo "src-link berlin_addons $(PWD)/addons" > target/feeds.conf
	echo "src-link berlin_defaults $(PWD)/defaults" > target/feeds.conf
	echo "src-link berlin_utils $(PWD)/utils" > target/feeds.conf
	./target/scripts/feeds update -a
	./target/scripts/feeds install -a
	$(MAKE) -C target defconfig 

world: target/.config
	$(MAKE) -C target world CONFIG_TARGET_ARCH_PACKAGES=all CONFIG_SIGNED_PACKAGES=
	$(RM) -rf target/bin/packages/all/base/
	tar -C target/bin/packages/all -czf target/opkg_feed.tar.gz .



