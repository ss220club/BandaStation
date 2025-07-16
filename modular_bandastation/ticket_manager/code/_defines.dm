#define TICKET_OPEN 0
#define TICKET_CLOSED 1
#define TICKET_RESOLVED 2

#define TICKET_TYPE_ADMIN "Admin"
#define TICKET_TYPE_MENTOR "Mentor"

#define TICKET_OPEN_LINK(id, msg) ("<a href='byond://?src=[GLOB.ticket_manager_ref];ticket_id=[id];response=1'>[msg]</a>")
#define TICKET_REPLY_LINK(id, msg) ("<a href='byond://?src=[GLOB.ticket_manager_ref];ticket_id=[id];open_ticket=1'>[msg]</a>")
