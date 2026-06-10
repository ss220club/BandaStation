// Extends /obj/machinery/power/apc with vars needed by the integration cog mechanic
/obj/machinery/power/apc
	/// The integration cog installed in this APC, if any
	var/obj/item/clockwork/integration_cog/integration_cog = null
	/// Whether this APC has already granted its clock power bonus (prevents double-rewarding)
	var/clock_cog_rewarded = FALSE
