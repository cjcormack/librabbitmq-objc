//
//  AMQPChannel.m
//  This file is part of librabbitmq-objc.
//  Copyright (C) 2014 *Prof. MAAD* aka Max Wolter
//  librabbitmq-objc is released under the terms of the GNU Lesser General Public License Version 3.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU Lesser General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//  
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU Lesser General Public License for more details.
//  
//  You should have received a copy of the GNU Lesser General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.

#import "AMQPChannel.h"

# import <amqp.h>
# import <amqp_framing.h>

@implementation AMQPChannel

@synthesize internalChannel = channel;
@synthesize connection;

- (id)init
{
	if(self = [super init])
	{
		channel = nil;
		connection = nil;
		isClosed = false;
	}
	
	return self;
}
- (void)dealloc
{
	[self close];

}

- (void)openChannel:(amqp_channel_t)theChannel onConnection:(AMQPConnection*)theConnection
{
	connection = theConnection;
	channel = theChannel;
	
	amqp_channel_open(connection.internalConnection, channel);

	[connection checkLastOperation:@"Failed to open a channel"];

	isClosed = false;
}
- (void)close
{
	if (isClosed) {
		return;
	}

	amqp_rpc_reply_t reply = amqp_channel_close(connection.internalConnection, channel, AMQP_REPLY_SUCCESS);

	isClosed = true;

	if(reply.reply_type != AMQP_RESPONSE_NORMAL)
	{
		[NSException raise:@"AMQPConnectionException" format:@"Unable to close channel: %@", [self errorDescriptionForReply:reply]];
	}
}

@end
