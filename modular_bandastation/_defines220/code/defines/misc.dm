///Do (almost) nothing - indev placeholder for switch case implementations etc
#define NOOP (.=.)
/// Copies the L from element START to elememt END if L is initialized, otherwise returns an empty list.
#define LAZYCOPY_RANGE(L, START, END) ( L ? L.Copy(START, END) : list() )
/// Cuts the L from element START to elememt END if L is initialized, otherwise returns an empty list.
#define LAZYCUT(L, START, END) ( L ? L.Cut(START, END) : NOOP )

#define PLAYER_REQUIRES_LINKED_DISCORD_CHAT_MESSAGE custom_boxed_message("red_box", span_alertwarning("Вам необходимо привязать дискорд-профиль к аккаунту!<br>Перейдите во вкладку '<b>OOC</b>', она справа сверху, и нажмите '<b>Привязать Discord</b>' для получения инструкций.<br>Если вы уверены, что ваш аккаунт уже привязан, подождите синхронизации."))
