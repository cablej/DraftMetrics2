//
//  Fantasy.h
//  FantasyDrafter
//
//  Created by Jack on 8/5/14.
//  Copyright (c) 2014 JackCable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Player.h"
#import "PlayerIdent.h"

@interface Fantasy : NSObject

+(Fantasy*) sharedInstance;

-(instancetype) initWithNumTeams : (int) num_teams withNumPick : (int) my_pick withNumRoundsInAdvance : (int) num_rounds_in_advance;
-(instancetype) initWithNumTeams : (int) num_teams withNumPick : (int) my_pick withNumRoundsInAdvance : (int) num_rounds_in_advance withCustomScoring : (NSArray*) customRules; //pts per passing yard, pts for passing td, points for interception, points for rushing yard, pts for rushing td, pts for reception, pts for receiving yard, receiving td points, passing 2 pt conversion, rushing 2 pt conversion, fumbles
-(void) calculateData;
-(void) makeCalculations;

-(NSArray*) getPlayersByPositionForRound : (int) round;
-(int) getRecommendedPositionForRound : (int) round;

-(NSArray*) getAvailablePlayers;
-(int) getRelativePick : (int) pick;
-(int) getRelativePick;
-(int) getCurrentPick;
-(int) getCurrentRound;
-(BOOL) isUserPick;
-(void) reloadPicks;

-(void) draftPlayer : (Player *) p;
-(BOOL) draftHasFinished;

-(NSArray*) getDraftHistory;
-(void) clearDraft;
-(NSArray*) getPositionsArray;

-(float) getChanceOfAvailability : (Player *) p : (int) round;
-(float) getChanceOfBestAvailable : (Player *) p : (int) round;

-(int) getPick : (int) round : (int) pick;

-(int) getNextRoundToDraft;

-(void) setNoCalc : (BOOL) val;

-(void) prepValues;

-(BOOL) picksHaveChanged;
-(BOOL) settingsHaveChanged : (int) numTeams : (int) myPick : (int) numberPreviews : (NSArray*) scoringNew;

-(void) removePickAtIndex : (int) index;

-(void) saveFilesToDocuments;

-(NSArray*) getPlayerProjections;
-(void) saveNewPlayerProjections : (NSArray*) newPlayerProjections;

-(void) resetPlayerProjections;

@end
