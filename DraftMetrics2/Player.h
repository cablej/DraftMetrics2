//
//  Player.h
//  FantasyDrafter
//
//  Created by Jack on 8/5/14.
//  Copyright (c) 2014 JackCable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlayerIdent.h"

@interface Player : NSObject

@property int ID;
@property int position;
@property int totalPicks;
@property int numPicks;
@property(strong, nonatomic) NSString* name;
@property(strong, nonatomic) NSString* team;
@property float ADP;
@property float points;
@property float sumsquares;
@property float stdev;
@property float mean;
@property float score;
@property float rank;

@property(strong, nonatomic) NSString* image;

-(PlayerIdent*) getPID;
-(NSString*) toString;
-(void) calcInfo;
-(NSString*) adpInfo;

@end
