//
//  PlayerIdent.m
//  FantasyDrafter
//
//  Created by Jack on 8/5/14.
//  Copyright (c) 2014 JackCable. All rights reserved.
//

#import "PlayerIdent.h"

@implementation PlayerIdent

-(PlayerIdent*) initWithName:(NSString *)name andTeam:(NSString *)team {
    if(self = [super init]) {
        _name = name;
        _team = team;
    }
    return self;
}

-(BOOL) isEqual:(id)anObject {
    return [_name isEqualToString:((PlayerIdent*)anObject).name] && [_team isEqualToString:((PlayerIdent*)anObject).team];
}

-(NSUInteger) hash {
    return [_name hash];
}

- (id)copyWithZone:(NSZone *)zone {
    PlayerIdent *objectCopy = [[PlayerIdent allocWithZone:zone] init];
    objectCopy.name = _name;
    objectCopy.team = _team;
    return objectCopy;
}

@end
