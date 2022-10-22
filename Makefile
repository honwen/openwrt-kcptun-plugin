#
# Copyright (C) 2021-2022 honwen <https://github.com/honwen>
#
# This is free software, licensed under the GNU General Public License v3.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=kcptun-plugin
PKG_VERSION:=1.0.5
PKG_RELEASE:=20221022
PKG_MAINTAINER:=honwen <https://github.com/honwen>

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)-$(PKG_RELEASE)

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=net
	CATEGORY:=Network
	TITLE:=SIP003 plugin for shadowsocks, based on kcptun
	URL:=https://github.com/honwen/kcptun-plugin
	DEPENDS:=+kcptun
endef

define Package/$(PKG_NAME)/description
	Yet another SIP003 plugin for shadowsocks, based on kcptun
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/postinst
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	if [ -f /etc/uci-defaults/$(PKG_NAME) ]; then
		( . /etc/uci-defaults/$(PKG_NAME) ) && \
		rm -f /etc/uci-defaults/$(PKG_NAME)
	fi
fi
exit 0
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./src/kcptun $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/uci-defaults $(1)/etc/uci-defaults/$(PKG_NAME)
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
