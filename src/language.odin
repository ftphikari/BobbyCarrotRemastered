package main

SUPPORT_LANGUAGES :: true

Language :: enum {
	EN,
	UA,
}

language_to_string: [Language]string = {
	.EN = "English",
	.UA = "Українська",
}

Language_Strings :: enum {
	Select_Level,
	Continue,
	New_Game,
	Campaign,
	Scoreboard,
	Language,
	Renderer,
	Credits,
	Quit,
	Restart_Level,
	Exit_Level,
	Scoreboard_Steps,
	Level,
	Time,
	Steps,
	Press_Any_Key,
	Credits_Original,
	Credits_Remastered,
}

language_strings: [Language][Language_Strings]string = {
	.EN = {
		.Select_Level = "Select level",
		.Continue = "Continue",
		.New_Game = "New game",
		.Campaign = "Campaign",
		.Scoreboard = "Scoreboard",
		.Language = "Language",
		.Renderer = "Renderer",
		.Credits = "Credits",
		.Quit = "Quit",
		.Restart_Level = "Restart level",
		.Exit_Level = "Exit level",
		.Scoreboard_Steps = "steps",
		.Level = "Level",
		.Time = "Time",
		.Steps = "Steps",
		.Press_Any_Key = "Press any key to continue",
		.Credits_Original = "Original Bobby Carrot made by:",
		.Credits_Remastered = "Remastered by: @ftphikari",
	},
	.UA = {
		.Select_Level = "Виберіть рівень",
		.Continue = "Продовжити",
		.New_Game = "Нова гра",
		.Campaign = "Кампанія",
		.Scoreboard = "Табло",
		.Language = "Мова",
		.Renderer = "Рендерер",
		.Credits = "Титри",
		.Quit = "Вийти",
		.Restart_Level = "Перезапустити рівень",
		.Exit_Level = "Вийти з рівня",
		.Scoreboard_Steps = "кроків",
		.Level = "Рівень",
		.Time = "Час",
		.Steps = "Кроків",
		.Press_Any_Key = "Натисніть будь-яку клавішу, щоб продовжити",
		.Credits_Original = "Оригінальний Bobby Carrot зроблено:",
		.Credits_Remastered = "Ремастеринг: @ftphikari",
	},
}

campaign_to_string: [Language][Campaign]string = {
	.EN = {
		.Carrot_Harvest = "Carrot Harvest",
		.Easter_Eggs = "Easter Eggs",
	},
	.UA = {
		.Carrot_Harvest = "Збір Моркви",
		.Easter_Eggs = "Пасхальні Яйця",
	},
}
