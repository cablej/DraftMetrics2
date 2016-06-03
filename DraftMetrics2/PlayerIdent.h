//
//  PlayerIdent.h
//  FantasyDrafter
//
//  Created by Jack on 8/5/14.
//  Copyright (c) 2014 JackCable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlayerIdent : NSObject <NSCopying>

@property(strong, nonatomic) NSString *name;
@property(strong, nonatomic) NSString *team;

-(PlayerIdent*) initWithName: (NSString*) name andTeam : (NSString*) team;

- (BOOL)isEqual:(id)anObject;
- (NSUInteger)hash;


@end
