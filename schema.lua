local iputils = require "resty.iputils"
local Errors = require "kong.dao.errors"

local function validate_ips(v, t, column)
  if v and type(v) == "table" then
    for _, ip in ipairs(v) do
      local _, err = iputils.parse_cidr(ip)
      if type(err) == "string" then -- It's an error only if the second variable is a string
        return false, "cannot parse '" .. ip .. "': " .. err
      end
    end
  end
  return true
end

return {
  name = "kong-waf",
  fields = {
    whitelist = {type = "array", func = validate_ips},
    blacklist = {type = "array", func = validate_ips},
    openwaf = {type = "string", required = true},
    rulepath = {type = "path", required = true},
    attacklog = {type = "string", required = true},
    logdir = {type = "path", required = true},
    urldeny = {type = "string", required = true},
    Redirect = {type = "string", required = true},
    cookiematch = {type = "string", required = true},
    postmatch = {type = "string", required = true},
    black_fileExt = {type = "array", elements = string}
  },
  self_check = function(schema, plugin_t, dao, is_update)
    local wl = type(plugin_t.whitelist) == "table" and plugin_t.whitelist or {}
    local bl = type(plugin_t.blacklist) == "table" and plugin_t.blacklist or {}

    if #wl > 0 and #bl > 0 then
      return false, Errors.schema "you cannot set both a whitelist and a blacklist"
    elseif #wl == 0 and #bl == 0 then
      return false, Errors.schema "you must set at least a whitelist or blacklist"
    end

    return true
  end
}
