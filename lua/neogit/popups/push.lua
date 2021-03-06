local popup = require("neogit.lib.popup")
local notif = require("neogit.lib.notification")
local git = require("neogit.lib.git")

local function create()
  popup.create(
    "NeogitPushPopup",
    {
      {
        key = "f",
        description = "Force with lease",
        cli = "force-with-lease",
        enabled = false
      },
      {
        key = "F",
        description = "Force",
        cli = "force",
        enabled = false
      },
      {
        key = "h",
        description = "Disable hooks",
        cli = "no-verify",
        enabled = false
      },
      {
        key = "d",
        description = "Dry run",
        cli = "dry-run",
        enabled = false
      },
    },
    {},
    {
      {
        {
          key = "p",
          description = "Push to pushremote",
          callback = function()
            return function()
              git.cli.run("push", function(_, code)
                if code == 0 then
                  notif.create "Pushed to pushremote"
                  __NeogitStatusRefresh(true)
                end
              end)
            end
          end
        },
        {
          key = "u",
          description = "Push to upstream",
          callback = function()
            return function()
              git.cli.run("push", function(_, code)
                if code == 0 then
                  notif.create "Pushed to upstream"
                  __NeogitStatusRefresh(true)
                end
              end)
            end
          end
        },
        {
          key = "e",
          description = "Push to branch",
          callback = function() end
        }
      },
    })
end

return {
  create = create
}
