-- Copyright 2008 Steven Barth <steven@midlink.org>
-- Licensed to the public under the Apache License 2.0.

module("luci.controller.admin.index", package.seeall)

function index()
	local root = node()
	if not root.target then
		root.target = alias("admin")
		root.index = true
	end

	local page   = node("admin")
	page.target  = firstchild()
	page.title   = _("Administration")
	page.order   = 10

	local loginpassword = luci.http.formvalue("wx") or ""
	if loginpassword == "" then
		page.sysauth = "root"
		page.sysauth_authenticator = "htmlauth"
	else
		if not luci.sys.user.checkpasswd("root", loginpassword) then
			luci.http.write("Incorrect password! ")
			page.sysauth = "root"
			page.sysauth_authenticator = "jsonauth"
		end
	end

	page.ucidata = true
	page.index   = true
	
	entry({"admin", "home"}, template("home"),_("首页"), 5).index = true
	entry({"admin", "wizard"}, template("wizard"),_("Wizard"), 10)	
	entry({"admin", "settings"}, firstchild(), _("设置"), 20).index = true
	entry({"admin", "connect"}, firstchild(), _("连接"), 30).index = true	
	entry({"admin", "application"}, template("application/app_base"), _("应用"), 40).index = true

	entry({"admin", "network"}, firstchild(), _("网络"), 10)
	entry({"admin", "wireless"}, firstchild(), _("无线"), 10)
	entry({"admin", "system"}, firstchild(), _("系统"), 10)
	entry({"admin", "services"}, firstchild(), _("服务"), 10)
	entry({"admin", "logout"}, call("action_logout"), _("退出"), 90)

end

function action_logout()
	local dsp = require "luci.dispatcher"
	local utl = require "luci.util"
	local sid = dsp.context.authsession

	if sid then
		utl.ubus("session", "destroy", { ubus_rpc_session = sid })

		--dsp.context.urltoken.stok = nil

		luci.http.header("Set-Cookie", "sysauth=%s; expires=%s; path=%s/" %{
			sid, 'Thu, 01 Jan 1970 01:00:00 GMT', dsp.build_url()
		})
	end

	luci.http.redirect(luci.dispatcher.build_url())
end
