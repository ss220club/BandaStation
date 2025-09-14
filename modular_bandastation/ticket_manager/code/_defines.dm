#define TICKET_STAT_PANEL_MESSAGE_MAX_LENGHT 100

#define TICKET_REPLY_COOLDOWN 5 SECONDS
#define TICKET_AUTOCLOSE_TIMER 10 MINUTES

#define TICKET_OPEN 0
#define TICKET_CLOSED 1
#define TICKET_RESOLVED 2

#define TICKET_TYPE_ADMIN "Admin"
#define TICKET_TYPE_MENTOR "Mentor"
#define TICKET_TYPE_HIDDEN_PM "Private Message"
#define TICKET_TYPE_HIDDEN_TICKET "Ticket"

#define TICKET_OPEN_LINK(id, msg) ("<a href='byond://?src=[GLOB.ticket_manager_ref];ticket_id=[id];open_ticket=1'>[msg]</a>")
#define TICKET_REPLY_LINK(id, msg) (span_adminsay("<a href='byond://?src=[GLOB.ticket_manager_ref];ticket_id=[id];reply_ticket=1'>[msg]</a>"))
#define TICKET_RESOLVE_LINK(id) ("<a href='byond://?src=[GLOB.ticket_manager_ref];ticket_id=[id];resolve_ticket=1'>Решить</a>")
#define TICKET_CLOSE_LINK(id) ("<a href='byond://?src=[GLOB.ticket_manager_ref];ticket_id=[id];close_ticket=1'>Закрыть</a>")

#define TICKET_FULLMONTY(user, id) "[ADMIN_FULLMONTY_NONAME(user)] [TICKET_RESOLVE_LINK(id)] [TICKET_CLOSE_LINK(id)] [TICKET_OPEN_LINK(id, "Открыть чат")]"
