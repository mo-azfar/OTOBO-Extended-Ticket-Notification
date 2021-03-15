# OTOBO-Ticket-Notification-To-Mattermost-Users
- Built for OTOBO v10.0.x
- This module extend Ticket Notification module to send notification to Mattermost users (agent).
  
  
1. Login to your mattermost instance. Take note in your mattermost base URL.
  
		Example: wxyz.cloud.mattermost.com
  
  
2. Create a bot via Menu > Integrations > Bot Accounts > Add Bot Accounts
  
		username = otobo
		display name = OTOBO
		role = member
		post:all : enabled
  
  
3. Generate access token. At your new created bot, select Create New Token
  
After create, take a note / remember the generated 'Access Token' 
  
		Example of Bot Access Token: abcdefghijklm
  
  
4. Get the bot id. At your new created bot, select Edit. (You can grab the bot id from the URL)
  
		Example url: https://wxyz.cloud.mattermost.com/main/integrations/bots/edit?id=nopqrstuvwxyz
		Example of bot id: nopqrstuvwxyz
  
  
5. Update System Configuration 
	
		> MattermostAgent::BaseURL			#with base url taken from no 1  
		> MattermostAgent::BotAccessToken		#with bot access token taken from no 3  
		> MattermostAgent::BotID			#with bot id taken from no 4  


6. Fill in agent preferences (profile) with Mattermost username at 'Mattermost Username' field


7. Create or edit ticket notification and enable 'Mattermost Agent' method.

		- Select 'Mattermost Agent' as notification method.  
		- Only supported recipient type : Agent  

[![slack.png](https://i.postimg.cc/63TG456r/slack.png)](https://postimg.cc/TLMPZxD1)
