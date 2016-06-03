//
//  Player.m
//  FantasyDrafter
//
//  Created by Jack on 8/5/14.
//  Copyright (c) 2014 JackCable. All rights reserved.
//

#import "Player.h"

@implementation Player

-(PlayerIdent*) getPID {
    return [[PlayerIdent alloc] initWithName:_name andTeam:_team];
}

-(NSString*) toString {
    return [NSString stringWithFormat:@"{ID = %i, Position = %i, Name = %@, Team = %@, ADP = %f, Points = %f", _ID, _position, _name, _team, _ADP, _points];
}

-(void) calcInfo {
    if(_numPicks > 0) {
        _mean = _totalPicks*1.0/_numPicks;
        _stdev = sqrtf((_sumsquares+_mean*_mean*_numPicks - 2*_mean*_totalPicks)*1.0/_numPicks);
    }
}

-(NSString*) adpInfo {
    [self calcInfo];
    return [NSString stringWithFormat:@"{Name = %@, ADP = %f, Total Picks = %i, # Picks = %i, Mean = %f, Std Dev = %f", _name, _ADP, _totalPicks, _numPicks, _mean, _stdev];
}

- (NSComparisonResult)compare:(Player *)otherObject {
    return self.score < otherObject.score;
}

- (NSComparisonResult)compare:(Player *)otherObject options:(NSStringCompareOptions)mask {
    return self.rank > otherObject.rank;
}

@end
