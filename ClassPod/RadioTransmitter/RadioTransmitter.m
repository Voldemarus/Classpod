//
//  RadioTransmitter.m
//  ClassPod
//
//  Created by Водолазкий В.В. on 22.05.2021.
//

#import "RadioTransmitter.h"

NSString * const PubNub_User    =   @"demo";
NSString * const PubNub_Pass    =   @"demo";
NSString * const PubNub_UID     =   @"myUniqueUUID";

@interface RadioTransmitter () <PNEventsListener>

@property (nonatomic, strong) PubNub *client;

@end

@implementation RadioTransmitter


+ (RadioTransmitter *) sharedTransmitter
{
    static RadioTransmitter *__radioTransmitter = nil;
    if (!__radioTransmitter) {
        __radioTransmitter = [[RadioTransmitter alloc] init];
    }
    return __radioTransmitter;
}

- (instancetype) init
{
    if (self = [super init]) {
        PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:PubNub_User subscribeKey:PubNub_Pass];
        configuration.uuid = PubNub_UID;

        self.client = [PubNub clientWithConfiguration:configuration];
        [self.client addListener:self];

        self.channels = [[NSMutableSet alloc] init];

        // Subscribe to demo channel with presence observation
        [self addchannel:@"demo"];
    }
    return self;
}

- (void) addchannel:(NSString *)name
{
    if (!name) {
        return;
    }
    if ([self.channels containsObject:name] == NO) {
        [self.channels addObject:name];
        [self.client subscribeToChannels: @[name] withPresence:YES];
    }
}



#pragma mark - PubNub Delegate -

// Handle new message from one of channels on which client has been subscribed.
- (void)client:(PubNub *)client didReceiveMessage:(PNMessageResult *)message {

    // Handle new message stored in message.data.message
    if (![message.data.channel isEqualToString:message.data.subscription]) {

        // Message has been received on channel group stored in message.data.subscription.
    }
    else {

        // Message has been received on channel stored in message.data.channel.
    }

    NSLog(@"Received message: %@ on channel %@ at %@", message.data.message[@"msg"],
          message.data.channel, message.data.timetoken);
}

// New presence event handling.
- (void)client:(PubNub *)client didReceivePresenceEvent:(PNPresenceEventResult *)event {

    if (![event.data.channel isEqualToString:event.data.subscription]) {

        // Presence event has been received on channel group stored in event.data.subscription.
    }
    else {

        // Presence event has been received on channel stored in event.data.channel.
    }

    if (![event.data.presenceEvent isEqualToString:@"state-change"]) {

        NSLog(@"%@ \"%@'ed\"\nat: %@ on %@ (Occupancy: %@)", event.data.presence.uuid,
              event.data.presenceEvent, event.data.presence.timetoken, event.data.channel,
              event.data.presence.occupancy);
    }
    else {

        NSLog(@"%@ changed state at: %@ on %@ to: %@", event.data.presence.uuid,
              event.data.presence.timetoken, event.data.channel, event.data.presence.state);
    }
}

// Handle subscription status change.
- (void)client:(PubNub *)client didReceiveStatus:(PNStatus *)status {

    if (status.operation == PNSubscribeOperation) {

        // Check whether received information about successful subscription or restore.
        if (status.category == PNConnectedCategory || status.category == PNReconnectedCategory) {

            // Status object for those categories can be casted to `PNSubscribeStatus` for use below.
            PNSubscribeStatus *subscribeStatus = (PNSubscribeStatus *)status;
            if (subscribeStatus.category == PNConnectedCategory) {

                // This is expected for a subscribe, this means there is no error or issue whatsoever.

                // Select last object from list of channels and send message to it.
                NSString *targetChannel = [client channels].lastObject;
                [self.client publish: @{ @"msg": @"hello" }
                           toChannel: targetChannel withCompletion:^(PNPublishStatus *publishStatus) {

                    // Check whether request successfully completed or not.
                    if (!publishStatus.isError) {

                        // Message successfully published to specified channel.
                    }
                    else {

                        /**
                         Handle message publish error. Check 'category' property to find out
                         possible reason because of which request did fail.
                         Review 'errorData' property (which has PNErrorData data type) of status
                         object to get additional information about issue.

                         Request can be resent using: [publishStatus retry];
                         */
                    }
                }];
            }
            else {

                /**
                 This usually occurs if subscribe temporarily fails but reconnects. This means there was
                 an error but there is no longer any issue.
                 */
            }
        }
        else if (status.category == PNUnexpectedDisconnectCategory) {

            /**
             This is usually an issue with the internet connection, this is an error, handle
             appropriately retry will be called automatically.
             */
        }
        // Looks like some kind of issues happened while client tried to subscribe or disconnected from
        // network.
        else {

            PNErrorStatus *errorStatus = (PNErrorStatus *)status;
            if (errorStatus.category == PNAccessDeniedCategory) {

                /**
                 This means that PAM does allow this client to subscribe to this channel and channel group
                 configuration. This is another explicit error.
                 */
            }
            else {

                /**
                 More errors can be directly specified by creating explicit cases for other error categories
                 of `PNStatusCategory` such as: `PNDecryptionErrorCategory`,
                 `PNMalformedFilterExpressionCategory`, `PNMalformedResponseCategory`, `PNTimeoutCategory`
                 or `PNNetworkIssuesCategory`
                 */
            }
        }
    }
}

@end
