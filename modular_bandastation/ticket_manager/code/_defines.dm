#define TICKET_OPEN 0
#define TICKET_CLOSED 1
#define TICKET_RESOLVED 2

#define TICKET_TYPE_ADMIN "Admin"
#define TICKET_TYPE_MENTOR "Mentor"

#define TICKET_OPEN_LINK(id, msg) ("<a href='byond://?src=[GLOB.ticket_manager_ref];ticket_id=[id];open_ticket=1'>[msg]</a>")
#define TICKET_REPLY_LINK(id, msg) ("<a href='byond://?src=[GLOB.ticket_manager_ref];ticket_id=[id];reply_ticket=1'>[msg]</a>")
#define TICKET_RESOLVE_LINK(id) ("<a href='byond://?src=[GLOB.ticket_manager_ref];ticket_id=[id];resolve_ticket=1'>(CLOSE)</a>")
#define TICKET_CLOSE_LINK(id) ("<a href='byond://?src=[GLOB.ticket_manager_ref];ticket_id=[id];close_ticket=1'>(RESOLVE)</a>")

#define TICKET_FULLMONTY(user, ticket_id) "[ADMIN_FULLMONTY_NONAME(user)] [TICKET_RESOLVE_LINK(ticket_id)] [TICKET_CLOSE_LINK(ticket_id)]"
