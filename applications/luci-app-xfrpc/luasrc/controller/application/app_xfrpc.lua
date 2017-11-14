module("luci.controller.application.app_xfrpc", package.seeall)

local uci = require "luci.model.uci".cursor()

function index()
		entry({"admin", "application", "xfrpc"}, template("application/app_xfrpc"), _("内网映射"), 36).index = true
		entry({"admin", "application", "xfrpc", "addWebProxy"}, call("addWebProxy"))
		entry({"admin", "application", "xfrpc", "delWebProxy"}, call("delWebProxy"))
end

local uci  = require "luci.model.uci".cursor()

function delWebProxy()
	local rspData = {}
	local codeResp = 1

	local name = luci.http.formvalue("name")

	if _deleteWebProxy(name) then 
		codeResp = 0
		uci:commit("xfrpc")
	end

	rspData["code"] = codeResp

	luci.util.exec("/etc/init.d/xfrpc restart")
	luci.http.prepare_content("application/json")
	luci.http.write_json(rspData)
end

function addWebProxy()
	local rspData = {}
	local codeResp = 0

	local proxyType		= luci.http.formvalue("type")
	local localIP		= luci.http.formvalue("ip")
	local localPort		= luci.http.formvalue("port")
	local customDomains	= luci.http.formvalue("domain")
	local name = os.time()

	local codeResp = _addWebProxy(name, proxyType, localIP, localPort, customDomains)

	rspData["code"] = codeResp
	rspData["sname"] = name

	if codeResp == 0 then
		luci.util.exec("/etc/init.d/xfrpc restart")
	end

	luci.http.prepare_content("application/json")
	luci.http.write_json(rspData)
end

function _nameConflictCheck(t, domain)
	local result = nil
	uci:foreach("xfrpc", "proxy",
		function(s)
			if s.type == t and s.custom_domains == domain then
				result = s[".name"]
			end
		end
	)
	return result
end

function _deleteWebProxy(name)
	local result = false

	uci:foreach("xfrpc", "proxy",
		function(s)
			if s.name == name then
				uci:delete("xfrpc", s[".name"])
				result = true
			end
		end)

	return result
end


function _addWebProxy(name, tp, ip, port, domain)
	if _nameConflictCheck(tp, domain) ~= nil then
		return 2
	end

	local options = {
		["name"]		= name or "",
		["type"]		= tp,
		["local_ip"]	= ip,
		["local_port"]	= port,
		["custom_domains"] = domain,
	}

	uci:section("xfrpc", "proxy", nil, options)
	uci:commit("xfrpc")
	return 0
end