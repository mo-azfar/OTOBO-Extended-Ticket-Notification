# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --
package Kernel::System::CustomMessage;

use strict;
use warnings;

# use ../ as lib location
use File::Basename;
use FindBin qw($RealBin);
use lib dirname($RealBin);

#use Data::Dumper;
#use Fcntl qw(:flock SEEK_END);
use JSON::MaybeXS;
use LWP::UserAgent;
use HTTP::Request::Common;
#yum install -y perl-LWP-Protocol-https
#yum install -y perl-JSON-MaybeXS

our @ObjectDependencies = (
    'Kernel::System::Ticket',
    'Kernel::System::Log',
	'Kernel::System::Group',
	'Kernel::System::Queue',
	'Kernel::System::User',
	
);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    return $Self;
}

=cut

		my $Test = $Self->SendMessageTelegramAgent(
                TicketURL => $TicketURL,
				Token    => $Token,
				TelegramAgentChatID  => $RecipientChatIDField,
				Message      => $Notification{Body},
				TicketID      => $TicketID, #sent for log purpose
				ReceiverName      => $UserFullName, #sent for log purpose
		);

=cut

sub SendMessageTelegramAgent {
	my ( $Self, %Param ) = @_;
	
	# check for needed stuff
    for my $Needed (qw(TicketURL Token TelegramAgentChatID Message TicketID ReceiverName)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Missing parameter $Needed!",
            );
            return;
        }
    }
	
	my $ua = LWP::UserAgent->new;
	utf8::decode($Param{Message});
	my $p = {
			chat_id=>$Param{TelegramAgentChatID},
			parse_mode=>'HTML',
			text=>$Param{Message},
			reply_markup => {
				#resize_keyboard => \1, # \1 = true when JSONified, \0 = false
				inline_keyboard => [
				# Keyboard: row 1
				[
				
				{
                text => 'View',
                url => $Param{TicketURL}
				}
                  
				]
				]
				}
			};
	
	my $response = $ua->request(
		POST "https://api.telegram.org/bot".$Param{Token}."/sendMessage",
		Content_Type    => 'application/json',
		Content         => JSON::MaybeXS::encode_json($p)
       )	;
	
	my $ResponseData = $Kernel::OM->Get('Kernel::System::JSON')->Decode(
        Data => $response->decoded_content,
    );
	
	if ($ResponseData->{ok} eq 0)
	{
		$Kernel::OM->Get('Kernel::System::Log')->Log(
			 Priority => 'error',
			 Message  => "Telegram notification to $Param{ReceiverName} ($Param{TelegramAgentChatID}): $ResponseData->{description}",
		);
		return 0;
	}
	else 
	{
		return 1;
	}
}

=cut

		my $Test = $Self->SendMessageSlackAgent(
                Token    => $Token,
				SlackMemberID  => $RecipientMemberID,	
				TicketURL	=>	$TicketURL,
				TicketNumber	=>	$Ticket{TicketNumber},
				Message	=>	$Notification{Body},
				Created	=> $TicketDateTimeString,
				Queue	=> $Ticket{Queue},
				Service	=>	$Ticket{Service},
				Priority=>	$Ticket{Priority},	
				TicketID      => $TicketID, #sent for log purpose
				ReceiverName      => $UserFullName, #sent for log purpose
		);

=cut

sub SendMessageSlackAgent {
	my ( $Self, %Param ) = @_;
	
	# check for needed stuff
    for my $Needed (qw(Token SlackMemberID TicketURL TicketNumber Message Created Queue Service Priority TicketID ReceiverName)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Missing parameter $Needed!",
            );
            return;
        }
    }
	
	my $ua = LWP::UserAgent->new;
	utf8::decode($Param{Message});
	
	#https://api.slack.com/methods/conversations.open
	#to get userid based on member id
	my $params1 = {
       "return_im" => "true",
	   "users" => $Param{SlackMemberID},

	};
	
	my $response1 = $ua->post('https://slack.com/api/conversations.open',
    'Content' => JSON::MaybeXS::encode_json($params1),
    'Content-Type' => 'application/json',
    'Authorization' => $Param{Token}
	);
	
	my $content1  = decode_json ($response1->decoded_content());
	my $resCode1 = $response1->code();
	
	if (defined $content1->{error})
	{
	$Kernel::OM->Get('Kernel::System::Log')->Log(
			 Priority => 'error',
			 Message  => "Slack notification to $Param{ReceiverName} ($Param{SlackMemberID}): $content1->{error}",
		);
    return 0;
	}
	
	
	#https://api.slack.com/methods/chat.postMessage
	#send message to userid
	my $params2 = {
       "channel" => $content1->{channel}->{user},
	   "text" => $Param{Message},
	   "blocks"=> [
		{
		"type" => "section",
		"text" => {
			"type" => "mrkdwn",
			"text" => "*<$Param{TicketURL}|$Param{TicketNumber}>*\n\n$Param{Message}"
		}
		},
		{
		"type" => "section",
		"fields" => [
			{
				"type" => "mrkdwn",
				"text" => "*Created:*\n$Param{Created}"
			},
			{
				"type" => "mrkdwn",
				"text" => "*Queue:*\n$Param{Queue}"
			},
			{
				"type" => "mrkdwn",
				"text" => "*Service:*\n$Param{Service}"
			},
			{
				"type" => "mrkdwn",
				"text" => "*Priority:*\n$Param{Priority}"
			}
		]
		}
		]	
	};
		
	my $response2 = $ua->post('https://slack.com/api/chat.postMessage',
    'Content' => JSON::MaybeXS::encode_json($params2),
    'Content-Type' => 'application/json',
    'Authorization' => $Param{Token}
	);

	my $content2  = decode_json ($response2->decoded_content());
	my $resCode2 = $response2->code();
	
	if (defined $content2->{error})
	{
		$Kernel::OM->Get('Kernel::System::Log')->Log(
			 Priority => 'error',
			 Message  => "Slack notification to $Param{ReceiverName} ($Param{SlackMemberID}): $content2->{error}",
		);
		return 0;
	}
	else 
	{
		return 1;
	}
}

=cut

		my $Test = $Self->SendMessageMattermostAgent(
                BotAccessToken => $BotAccessToken,
				BotID => $BotID,
				BaseURL => $BaseURL,
				MattermostUsername  => $RecipientUsername,	
				TicketURL	=>	$TicketURL,
				TicketNumber	=>	$TicketHook.$Ticket{TicketNumber},
				Message	=>	$Notification{Body},
				Created	=> $TicketDateTimeString,
				Queue	=> $Ticket{Queue},
				Service	=>	$Ticket{Service},
				Priority=>	$Ticket{Priority},	
				TicketID      => $TicketID, #sent for log purpose
				ReceiverName      => $UserFullName, #sent for log purpose
		);

=cut

sub SendMessageMattermostAgent {
	my ( $Self, %Param ) = @_;
	
	# check for needed stuff
    for my $Needed (qw(BotAccessToken BotID BaseURL MattermostUsername TicketURL TicketNumber Message Created Queue Service Priority TicketID ReceiverName)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Missing parameter $Needed!",
            );
            return;
        }
    }
	
	my $ua = LWP::UserAgent->new;
	utf8::decode($Param{Message});
	
	#========gettting user id of specific receiver==============================
	my $params1 = [
	"$Param{MattermostUsername}"
	];
	
	my $response1 = $ua->post($Param{BaseURL}.'/users/usernames',
		'Content' => JSON::MaybeXS::encode_json($params1),
		'Content-Type' => 'application/json',
		'Authorization' => 'Bearer '.$Param{BotAccessToken}
	);
	
	
	my $resCode1 = $response1->code();
	my $content1  = decode_json ($response1->decoded_content());
	
	if ($resCode1 ne '200')
	{
		$Kernel::OM->Get('Kernel::System::Log')->Log(
			Priority => 'error',
			Message  => "Mattermost notification to $Param{ReceiverName} ($Param{MattermostUsername}): $content1->{status_code} $content1->{message}",
		);
		
		return 0;
	}

	
	if (!@{$content1})	#if user account not exist
	{
		$Kernel::OM->Get('Kernel::System::Log')->Log(
			Priority => 'error',
			Message  => "Mattermost notification to $Param{ReceiverName} ($Param{MattermostUsername}): Mattermost Username not found",
		);
		
		return 0;
	}
		
	my $userid = @{$content1}[0]->{id};
	#print "UserID: $userid\n";
	
	
	#========create DM channel between bot and receiver==============================
	my $params2 = [
	"$Param{BotID}", "$userid"
	];
	
	my $response2 = $ua->post($Param{BaseURL}.'/channels/direct',
		'Content' => JSON::MaybeXS::encode_json($params2),
		'Content-Type' => 'application/json',
		'Authorization' => 'Bearer '.$Param{BotAccessToken}
	);
	
	my $resCode2 = $response2->code();
	my $content2  = decode_json ($response2->decoded_content());
	
	if ($resCode2 ne '201')
	{
		$Kernel::OM->Get('Kernel::System::Log')->Log(
			Priority => 'error',
			Message  => "Mattermost notification to $Param{ReceiverName} ($Param{MattermostUsername}): $content2->{status_code} $content2->{message}",
		);
		
		return 0;
	}
	
	my $dm_channel_id = $content2->{id};
	#print "DM ID: $dm_channel_id\n";
	
	
	#===========send DM from bot to selected user====================
	my $params3 = {
		"channel_id" => "$dm_channel_id",
		"message" => "**$Param{TicketURL}\n$Param{TicketNumber}**\n$Param{Message}",
		"props"=> {"attachments" => [{"pretext" => "Information","text"=> "
		Created  : $Param{Created}                                
		Queue    : $Param{Queue}                                  
		Service  : $Param{Service}                                
		Priority : $Param{Priority}                               "}]}
		};
		
	my $response3 = $ua->post($Param{BaseURL}.'/posts',
		'Content' => JSON::MaybeXS::encode_json($params3),
		'Content-Type' => 'application/json',
		'Authorization' => 'Bearer '.$Param{BotAccessToken}
	);
	
	my $resCode3 = $response3->code();
	my $content3  = decode_json ($response3->decoded_content());
	
	if ($resCode3 ne '201')
	{
		$Kernel::OM->Get('Kernel::System::Log')->Log(
			Priority => 'error',
			Message  => "Mattermost notification to $Param{ReceiverName} ($Param{MattermostUsername}): $content3->{status_code} $content3->{message}",
		);
		
		return 0;
	}
	else
	{
		return 1;
	}

}

1;

