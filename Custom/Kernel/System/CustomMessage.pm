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


1;

