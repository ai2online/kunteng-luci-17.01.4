#
# Copyright (C) 2008-2015 The LuCI Team <luci@lists.subsignal.org>
#
# This is free software, licensed under the Apache License, Version 2.0 .
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-base

LUCI_TYPE:=mod
LUCI_BASENAME:=base

LUCI_TITLE:=LuCI core libraries
LUCI_DEPENDS:=+lua +libuci-lua +luci-lib-nixio +luci-lib-ip +rpcd +libubus-lua +luci-lib-jsonc

PKG_SOURCE:=luasrcdiet-0.12.1.zip
PKG_SOURCE_URL:=https://github.com/liudf0716/luasrcdiet/releases/download/v0.12.1/
PKG_MD5SUM:=dfe7728e38abbfa9f710244f9c78103a9d8fa3e0bde0600cbf33a24aa096a116

HOST_BUILD_DIR:=$(BUILD_DIR_HOST)/luasrcdiet-0.12.1

include $(INCLUDE_DIR)/host-build.mk

define Package/luci-base/conffiles
/etc/luci-uploads
/etc/config/luci
endef

include ../../luci.mk

define Host/Configure
endef

define Host/Compile
	$(MAKE) -C src/ clean po2lmo
	$(MAKE) -C $(HOST_BUILD_DIR) bin/LuaSrcDiet.lua
endef

define Host/Install
	$(INSTALL_DIR) $(1)/bin
	$(INSTALL_BIN) src/po2lmo $(1)/bin/po2lmo
	$(INSTALL_BIN) $(HOST_BUILD_DIR)/bin/LuaSrcDiet.lua $(1)/bin/LuaSrcDiet
endef

$(eval $(call HostBuild))

# call BuildPackage - OpenWrt buildroot signature
