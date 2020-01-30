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
		default_value = 100,
    minimum_value = 0,
    maximum_value = 100,
    order = "ab"
	},
	{
		type = "int-setting",
		name = "roadrunner-range",
		setting_type = "runtime-global",
		default_value = 5,
    minimum_value = 0,
    maximum_value = 100,
    order = "ac"
	},
  {
    type = "string-setting",
    name = "roadrunner-sound-type",
    setting_type = "runtime-global",
    default_value = "roadrunner-single",
    allowed_values = {"roadrunner-single", "none"},
    order = "ba"
  }
})