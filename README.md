# OTOBO-Extended-Ticket-Notification

[![paypal](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://paypal.me/MohdAzfar?locale.x=en_US)  
[![Donate with Bitcoin](https://en.cryptobadges.io/badge/small/3FSyJ9euCk4XD7Be1V8Khdmtb2CCSfJ8nh)](https://en.cryptobadges.io/donate/3FSyJ9euCk4XD7Be1V8Khdmtb2CCSfJ8nh)  
[![Donate with Ethereum](https://en.cryptobadges.io/badge/small/0x39B2E6E49B7434F1cEa0f92CBb9bE1843dC65153)](https://en.cryptobadges.io/donate/0x39B2E6E49B7434F1cEa0f92CBb9bE1843dC65153)

- Built for OTOBO 10.0.x
- This module extend default Ticket Notification module to send notification to agent via [Telegram](TELEGRAMAGENT.md) | [Slack](SLACKAGENT.md) | [Mattermost](MATTERMOSTAGENT.md).
- Based on https://github.com/mo-azfar/OTRS-Extended-Ticket-Notification  
- Using perl / cpan module

             JSON::MaybeXS  
             LWP::UserAgent  
             HTTP::Request::Common  
             Data::Dumper


OTOBO Agent Preferences (Profile) : 

[![preferences.png](https://i.postimg.cc/bJNRgKB2/preferences.png)](https://postimg.cc/nsg7cwZH)

OTOBO Ticket Notification Setting: 

[![notification.png](https://i.postimg.cc/BnTc0SWK/notification.png)](https://postimg.cc/87CrdVzp)

  
| For Telegram		           | For Slack                    | For Mattermost               |
| -----------------------------| -----------------------------| -----------------------------|
| [README](TELEGRAMAGENT.md)   | [README](SLACKAGENT.md)      | [README](MATTERMOSTAGENT.md) |
