# OTOBO-Ticket-Notification-To-Telegram-Users  
- Built for OTOBO 10.0.x 
- This module extend Ticket Notification module to send notification to Telegram users (agent / customer / non-users).   

1. A telegram bot must be created by chat with @FatherBot and obtain the token via Telegram.  

2. Update the telegram bot token at System Configuration > TelegramAgent::Token  

3. Update the field name that holds the telegram chat id for agent at System Configuration > TelegramAgent::ChatIDField  

		Default: UserTelegramChatID  

4. Update the field name that holds the telegram chat id for customer user at System Configuration > TelegramAgent::CustomerUserChatIDField

		Default: UserComment  
		
5. Obtain the telegram chat_id for the :

		- agent and update it into Agent Profile in 'Telegram Chat ID' field (as per no 3). 
		- customer and update it into Customer Profile in 'UserComment ' field (as per no 4). 
		- non-users and update directly in 'Recipient Telegram Chat ID' field at the Ticket Notification setup itself.


		- An agent/customer/non-users must start the conversation with the created telegram bot (no 1) first by using telegram.  
		- By using  https://api.telegram.org/bot<TOKEN>/getUpdates , we can obtain the chat_id of the agent/customer/non-user.  

6. Create a new Ticket Notification  

		- Select 'Telegram Agent' as notification method.  
		- Supported recipient type : Agent, Customer, 3rd Party Chat ID (non registered user/customer)  

[![t3.png](https://i.postimg.cc/50k8Tt2Q/t3.png)](https://postimg.cc/ygcJSs97)


6. To test the connection to telegram,

	shell > curl -X GET https://api.telegram.org/bot<TELEGRAM_BOT_TOKEN>/getMe