data:extend({
  {
    type = "bool-setting",
    name = "roadrunner-enabled",
    setting_type = "runtime-global",
    default_value = true,
    order = "aa"
  },
	{
		type = "int-setting",
		name = "roadrunner-volume",
		setting_type = "runtime-global",
		default_value = 50,
    minimum_value = 0,
    maximum_value = 100,
    order = "ab"
	},
	{
		type = "int-setting",
		name = "roadrunner-distance",
		setting_type = "runtime-global",
		default_value = 5,
    minimum_value = 0,
    maximum_value = 100,
    order = "ac"
  },
  {
		type = "int-setting",
		name = "roadrunner-chance",
		setting_type = "runtime-global",
		default_value = 75,
    minimum_value = 0,
    maximum_value = 100,
    order = "ad"
  },
  {
    type = "string-setting",
    name = "roadrunner-sound-type",
    setting_type = "runtime-global",
    default_value = "roadrunner-nggyu",
    allowed_values = {"roadrunner-nggyu", "none"},
    order = "ba"
  },
  {
    type = "string-setting",
    name = "roadrunner-motd",
    setting_type = "runtime-global",
    default_value = "Epstein didn't kill himself",
    order = "bb"
  }
})