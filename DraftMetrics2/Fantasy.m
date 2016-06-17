//
//  Fantasy.m
//  FantasyDrafter
//
//  Created by Jack on 8/5/14.
//  Copyright (c) 2014 JackCable. All rights reserved.
//

#define N(x) [NSNumber numberWithInt: x]
#define F(x) [NSNumber numberWithFloat: x]

#import "Fantasy.h"

static float EPSILON = 1E-14;
static int TOTAL_PICKS = 14;

@implementation Fantasy {
    NSMutableArray *players;
    NSMutableDictionary *PlayerIDs;
    NSArray *myPositions;
    NSArray *positions;
    NSArray *playerValueWeights;
    NSMutableArray *myPicks;
    NSArray *illegalChars;
    NSMutableArray *bestNames;
    NSMutableArray *availablePlayers;
    NSMutableArray *cumulative;
    NSMutableArray *bestValues;
    
    NSMutableDictionary *playerImages;
    
    NSArray *picksFromFile;
    int currentPickFromFile;
    
    int NUM_TEAMS;
    int MY_PICK;
    int NUM_ROUNDS_IN_ADVANCE;
    
    BOOL noCalc;
    
    NSArray *scoring;
    
    NSUserDefaults *userDefaults;
    
    CFTimeInterval startTime;
}

+ (Fantasy*)sharedInstance {
    static Fantasy *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if([defaults objectForKey:@"NUM_TEAMS"] == nil) [defaults setObject:@8 forKey:@"NUM_TEAMS"];
        if([defaults objectForKey:@"MY_PICK"] == nil) [defaults setObject:@1 forKey:@"MY_PICK"];
        if([defaults objectForKey:@"NUM_ROUNDS_IN_ADVANCE"] == nil) [defaults setObject:@2 forKey:@"NUM_ROUNDS_IN_ADVANCE"];
        if([defaults objectForKey:@"SHOW_BEST_AVAIL"] == nil) [defaults setObject:@NO forKey:@"SHOW_BEST_AVAIL"];
        if([defaults objectForKey:@"SCORING"] == nil) [defaults setObject:@[@.04, @4, @-2, @.1, @6, @0, @.1, @6, @1, @2, @-2] forKey:@"SCORING"];
        
        int NUM_TEAMS = [[defaults objectForKey:@"NUM_TEAMS"] intValue];
        int NUM_PICK = [[defaults objectForKey:@"MY_PICK"] intValue];
        int NUM_ROUNDS_IN_ADVANCE = [[defaults objectForKey:@"NUM_ROUNDS_IN_ADVANCE"] intValue];
        sharedInstance = [[self alloc] initWithNumTeams:NUM_TEAMS withNumPick:NUM_PICK withNumRoundsInAdvance:NUM_ROUNDS_IN_ADVANCE withCustomScoring:[defaults objectForKey:@"SCORING"]];
    });
    return sharedInstance;
}

-(instancetype) initWithNumTeams:(int)num_teams withNumPick:(int)my_pick withNumRoundsInAdvance :(int)num_rounds_in_advance {
    return [self initWithNumTeams:num_teams withNumPick:my_pick withNumRoundsInAdvance:num_rounds_in_advance withCustomScoring:[userDefaults objectForKey:@"SCORING"]];
}

-(instancetype) initWithNumTeams:(int)num_teams withNumPick:(int)my_pick withNumRoundsInAdvance:(int)num_rounds_in_advance withCustomScoring:(NSArray *)customRules {
    userDefaults = [NSUserDefaults standardUserDefaults];
    if(self = [super init]) {
        NUM_TEAMS = num_teams;
        MY_PICK = my_pick;
        NUM_ROUNDS_IN_ADVANCE = num_rounds_in_advance;
        scoring = customRules;
        [self prepValues];
    }
    
    return self;
}

-(void) prepValues {
    
    
    if([userDefaults objectForKey:@"FILES_SAVED"] == nil) {
        [self saveFilesToDocuments];
        [userDefaults setObject:@"1" forKey:@"FILES_SAVED"];
    }
    
    scoring = [userDefaults objectForKey:@"SCORING"];
    noCalc = false;
    players = [NSMutableArray array];
    PlayerIDs = [NSMutableDictionary dictionary];
    myPositions = @[@"QB", @"RB", @"WR", @"TE"];
    playerValueWeights = @[@[@0.5, @1.0], @[@0.6,@0.8,@0.95,@1.0,@1.0],@[@0.5,@0.7,@0.9,@1.0,@1.0],@[@0.6,@1.0]];
    myPicks = [self arrayWithAllValuesNil:TOTAL_PICKS];
    illegalChars = @[@"\""];
    bestNames = [self arrayWithAllValuesNil:TOTAL_PICKS+1];
    positions = myPositions;
    [self loadImages];
    [self loadMainInfo];
    //[self loadAdjustedPlayers];
}

-(void) reloadPicks {
    picksFromFile = [self getContentsOfUserFile:@"picks" :@"txt"];
    currentPickFromFile = 0;
    
    availablePlayers = [self arrayWithAllValuesNil:(int)myPositions.count];
    NSUInteger mpcount = myPositions.count;
    for(int i=0; i<mpcount; i++) {
        availablePlayers[i] = [NSMutableArray array];
    }
    cumulative = [self arrayWithDimensions:@[N((int)players.count), N(TOTAL_PICKS*NUM_TEAMS+1)]];
    [self loadAvailablePlayers];
    [self loadCumulative];
    bestValues = [self arrayWithDimensions:@[N((int)myPositions.count), N(TOTAL_PICKS*NUM_TEAMS+1)]];
}

-(void) makeCalculations {
    [self reloadPicks];
    [self calculateValues:1];
}



-(NSArray*) getDraftHistory {
    NSMutableArray *playerArray = [NSMutableArray array];
    for(int i=0; i<picksFromFile.count; i++) {
        NSString *playerID = picksFromFile[i];
        Player *p = players[[playerID intValue]];
        [playerArray addObject:p];
    }
    return playerArray;
}

-(void) clearDraft {
    [self saveArrayToFile:@"picks" : @"txt" withArray:@[]];
    picksFromFile = @[];
}

-(NSArray*) getPlayersByPositionForRound:(int)round {
    NSMutableArray *returnArray = [NSMutableArray array];
    for(int i=0; i<positions.count; i++) {
        int NUM_PLAYERS = 5;
        [returnArray addObject:[self getMostLikely:[self getCurrentPick] :[self getPick:round :MY_PICK] :NUM_PLAYERS :i]];
    }
    return returnArray;
}

-(NSArray*) getPlayerProjections {
    return players;
}

-(void) saveNewPlayerProjections:(NSArray *)newPlayerProjections {
    NSMutableArray *adjustmentsToSave = [NSMutableArray array];
    for(int i=0; i<newPlayerProjections.count; i++) {
        Player *playerAtIndex = newPlayerProjections[i];
        if(i > players.count - 1) return;
        Player *origPlayer = players[i];
        if(playerAtIndex.points != origPlayer.points) {
            [adjustmentsToSave addObject:playerAtIndex.name];
            [adjustmentsToSave addObject:F(playerAtIndex.points - origPlayer.points)];
        }
    }
    [self saveArrayToFile:@"playerAdjustments" :@"txt" withArray:adjustmentsToSave];
}

-(void) resetPlayerProjections {
    [self saveArrayToFile:@"playerAdjustments" :@"txt" withArray:@[]];
}

-(int) getRecommendedPositionForRound:(int)round {
    return [bestNames[round] intValue];
}

-(NSArray*) getAvailablePlayers {
    NSMutableArray *availablePlayersSortedByADP = [NSMutableArray array];
    for(NSArray *a in availablePlayers) {
        [availablePlayersSortedByADP addObjectsFromArray:a];
    }
    [availablePlayersSortedByADP sortUsingSelector:@selector(compare:options:)];
    return availablePlayersSortedByADP;
}

-(int) getRelativePick {
    return [self getCurrentPick] - ([self getCurrentRound] - 1)*NUM_TEAMS;
}

-(int) getRelativePick : (int) pick {
    return (pick % NUM_TEAMS) + 1;
}

-(int) getCurrentPick {
    return (int) picksFromFile.count + 1;
}

-(int) getCurrentRound {
    return ([self getCurrentPick]+NUM_TEAMS - 1)/NUM_TEAMS;
}

-(BOOL) isUserPick {
    return [self getCurrentPick] == [self getPick:[self getCurrentRound] :MY_PICK];
}

-(void) calculateData {
    [self runDraft];
}

-(void) removePickAtIndex:(int)index {
    NSMutableArray *newPicks = [NSMutableArray arrayWithArray:picksFromFile];
    [newPicks removeObjectAtIndex:index];
    [self saveArrayToFile:@"picks" : @"txt" withArray:newPicks];
    picksFromFile = newPicks;
}

-(int) nextPick {
    int pick = [picksFromFile[currentPickFromFile] intValue];
    currentPickFromFile++;
    return pick;
}

-(void) draftPlayer:(Player *)p {
    NSMutableArray *currentPicks = [NSMutableArray arrayWithArray:picksFromFile];
    [currentPicks addObject:[NSString stringWithFormat:@"%i", p.ID]];
    [self saveArrayToFile:@"picks" : @"txt" withArray:currentPicks];
    picksFromFile = currentPicks;
}

-(void) loadAdjustedPlayers {
    NSArray *adjPlayers = [self getContentsOfUserFile:@"playerAdjustments" :@"txt"];
    for(int i=0; i<adjPlayers.count/2; i++) {
        NSString *playerName = adjPlayers[i];
        float ptsAdj = [adjPlayers[i+1] floatValue];
        int playerID = [[PlayerIDs objectForKey:playerName] intValue];
        Player *p = players[playerID];
        p.points += ptsAdj;
    }
}

-(void) loadImages {
    playerImages = [NSMutableDictionary new];
    NSData *imageJSON = [self getDataOfUserFile:@"players" :@"json"];
    if(imageJSON) {
        NSError *error;
        id data = [NSJSONSerialization JSONObjectWithData:imageJSON options:0 error:&error];
        if(!error) {
            NSArray *jsonPlayerImages =  data[@"body"][@"players"];
            for(NSDictionary *jsonPlayer in jsonPlayerImages) {
                [playerImages setObject:jsonPlayer[@"photo"] forKey:[self removeSpecialCharacters:jsonPlayer[@"fullname"]]];
            }
        }
    }
}

-(NSString*) removeSpecialCharacters : (NSString*) str {
    return [[str componentsSeparatedByCharactersInSet:[[NSCharacterSet letterCharacterSet] invertedSet]] componentsJoinedByString:@""];
}

-(void) loadMainInfo {
    NSArray *projections = [self getContentsOfUserFile:@"projections" : @"csv"];
    NSUInteger pcount = projections.count;
    for(int i=1;/*header*/ i<pcount; i++) {
        if([projections[i] isEqualToString:@""]) continue;
        NSArray *row = [projections[i] componentsSeparatedByString:@","];
        Player *p = [[Player alloc] init];
        p.name = row[1];
        NSUInteger icount = illegalChars.count;
        for(int i=0; i<icount; i++) {
            p.name = [p.name stringByReplacingOccurrencesOfString:illegalChars[i] withString:@""];
        }
        p.team = row[3];
        for(int i=0; i<icount; i++) {
            p.team = [p.team stringByReplacingOccurrencesOfString:illegalChars[i] withString:@""];
        }
        p.ADP = [row[10] floatValue];
        //p.stdev = 1;
        NSUInteger mpcount = myPositions.count;
        for(int i=0; i<mpcount; i++) {
            if([myPositions[i] isEqualToString:[row[2] stringByReplacingOccurrencesOfString:@"\"" withString:@""]]) {
                p.position = i;
            }
        }
        p.ID = (int) players.count;
        p.rank = [row[0] floatValue];
        
        p.image = playerImages[[self removeSpecialCharacters:p.name]];
        
        if([[userDefaults objectForKey:@"updatedProjections2"] isEqualToString:@"1"]) {
            p.points = [row[11] floatValue]*[scoring[0] floatValue]; //passYds
            p.points += [row[12] floatValue]*[scoring[1] floatValue]; //passTds
            p.points += [row[13] floatValue]*[scoring[2] floatValue]; //passInt
            p.points += [row[14] floatValue]*[scoring[3] floatValue]; //rushYds
            p.points += [row[15] floatValue]*[scoring[4] floatValue]; //rushTds
            p.points += [row[16] floatValue]*[scoring[5] floatValue]; //rec
            p.points += [row[17] floatValue]*[scoring[6] floatValue]; //recYds
            p.points += [row[18] floatValue]*[scoring[7] floatValue]; //recTds
            if(p.position == 0) p.points += [row[19] floatValue]*[scoring[8] floatValue]; //twoPts PASS
            else p.points += [row[19] floatValue]*[scoring[9] floatValue]; //twoPts RUSH / REC
            p.points += [row[20] floatValue]*[scoring[10] floatValue]; //fumbles
        } else {
            p.points = [row[7] floatValue];
        }
        
        [players addObject:p];
        PlayerIdent *ident = p.getPID;
        if([PlayerIDs objectForKey:ident] != nil) {
            NSLog(@"Double player: %@ %@", p.name, p.team);
        }
        [PlayerIDs setObject:N(p.ID) forKey:ident];
    }
    
    if(noCalc) {
        return;
    }
    
    NSArray *stdev = [self getContentsOfUserFile:@"stdev" : @"csv"];
    NSUInteger stdcount = stdev.count;
    for(int i=1; i<stdcount; i++) {
        if([stdev[i] isEqualToString:@""]) continue;
        NSArray *row = [stdev[i] componentsSeparatedByString:@","];
        PlayerIdent *thisPlayer = [[PlayerIdent alloc] initWithName:row[1] andTeam:row[3]];
        NSNumber *ID_number = [PlayerIDs objectForKey:thisPlayer];
        if(ID_number != nil) {
            int ID = [ID_number intValue];
            Player *p = players[ID];
            if(p.stdev > EPSILON) {
                NSLog(@"Double player: %@ %@", p.name, p.team);
            }
            p.ADP = [row[4] floatValue];
            p.stdev = [row[5] floatValue];
        }
    }
}

-(void) loadAvailablePlayers {
    NSUInteger pcount = players.count;
    for(int i=0; i<pcount; i++) {
        Player *p = players[i];
        int pos = p.position;
        NSMutableArray *curr = availablePlayers[pos];
        int index = 0;
        NSUInteger ccount = curr.count;
        while (index < ccount && p.points < ((Player*)curr[index]).points) {
            index++;
        }
        [curr insertObject:p atIndex:index];
    }
}

-(void) loadCumulative {
    NSUInteger pcount = players.count;
    for (int i=0; i<pcount; i++) {
        Player *p = players[i];
        if(p.ADP > 0) {
            NSArray *normal = [self getNormalCurve:p.ADP :p.stdev];
            cumulative[i][0] = @0;
            NSUInteger ccount = ((NSArray*)cumulative[0]).count;
            for(int j=1; j < ccount; j++) {
                cumulative[i][j] = F([cumulative[i][j-1] floatValue] + [normal[j-1] floatValue]);
            }
        }
    }
}

-(void) calculateValues : (int) pick {
    NSUInteger pcount = positions.count;
    for(int i = 0; i < pcount; i++)
    {
        int S = (int)((NSArray*)availablePlayers[i]).count;
        for(int j = pick; j < TOTAL_PICKS*NUM_TEAMS+1; j++)
        {
            float prob = 1;
            for(int k = 0; k < S; k++)
            {
                Player *p = availablePlayers[i][k];
                int ID = p.ID;
                float pavail = 0;
                if(1 - [cumulative[ID][pick] floatValue] >= EPSILON)
                {
                    pavail = (1 - [cumulative[ID][j] floatValue])/(1 - [cumulative[ID][pick] floatValue]);
                }
                bestValues[i][j] = F([bestValues[i][j] floatValue] + (prob*pavail*p.points));
                prob *= (1-pavail);
            }
        }
    }
}

-(NSMutableArray*) getMostLikely : (int) currentPick : (int) myPick : (int) amount : (int) position {
    NSMutableArray *mostLikely = [NSMutableArray array];
    int S = (int)((NSArray*)availablePlayers[position]).count;
    float prob = 1;
    for(int k=0; k < S; k++) {
        Player *p = availablePlayers[position][k];
        int ID = p.ID;
        float pavail = 0;
        if(1 - [cumulative[ID][myPick] floatValue] >= EPSILON)
        {
            pavail = (1 - [cumulative[ID][myPick] floatValue])/(1 - [cumulative[ID][currentPick] floatValue]);
        }
        p.score = prob * pavail;
        [mostLikely addObject:p];
        prob *= (1-pavail);
    }
    [mostLikely sortUsingSelector:@selector(compare:)];
    NSMutableArray *best = [NSMutableArray array];
    for(int i = 0; i < amount; i++) {
        [best addObject:mostLikely[i]];
    }
    return best;
}

-(BOOL) picksHaveChanged {
    NSArray *newPicks = [self getContentsOfUserFile:@"picks" :@"txt"];
    return ![newPicks isEqualToArray:picksFromFile];
}

-(BOOL) settingsHaveChanged:(int)numTeams :(int)myPick :(int)numberPreviews :(NSArray *)scoringNew {
    if(NUM_TEAMS != numTeams || MY_PICK != myPick || NUM_ROUNDS_IN_ADVANCE != numberPreviews) {
        return true;
    }
    for(int i=0; i<scoring.count; i++) {
        if([scoring[i] floatValue] != [scoringNew[i] floatValue]) {
            return true;
        }
    }
    return false;
}

-(void) runDraft {
    NSMutableArray *numPositions = [NSMutableArray arrayWithArray:@[@2, @5, @5, @2, @0, @0]];
    int myPick = MY_PICK;
    for(int pick = 1; pick < TOTAL_PICKS*NUM_TEAMS+1; pick++) {
        int round = (pick+NUM_TEAMS - 1)/NUM_TEAMS;
        int ID = 0;
        if(currentPickFromFile < picksFromFile.count)
            ID = [self nextPick];
        else {
            if(noCalc) return;
            [self clearValues];
            [self calculateValues:pick];
            if(pick > [self getPick:round :myPick]) {
                [self calcBestDraft:[NSMutableArray arrayWithArray:numPositions] :round+1];
            } else {
                [self calcBestDraft:numPositions :round];
            }
            //[self showCurrentState : numPositions : pick];
            return;
        }
        if(ID == -1) return;
        BOOL yourPick = pick == [self getPick:round :myPick];
        Player *toRemove = players[ID];
        int pos = toRemove.position;
        if(yourPick) {
            myPicks[round-1] = toRemove;
            numPositions[pos] = N([numPositions[pos] intValue] - 1);
        }
        [availablePlayers[pos] removeObject:toRemove];
        //NSLog(@"Finished round #%i pick #%i removing %@.", round, pick,toRemove.name);
    }
}

-(float) getChanceOfAvailability:(Player *)p : (int) round {
    int thisPick = [self getPick:round :MY_PICK];
    return (1 - [cumulative[p.ID][thisPick] floatValue])/(1 - [cumulative[p.ID][[self getCurrentPick]] floatValue]);
}

-(float) getChanceOfBestAvailable:(Player *)p : (int) round {
    return p.score;
}

-(void)  showCurrentState : (NSMutableArray*) numPositions : (int) pick {
    for(int i = 0; i < TOTAL_PICKS; i++) {
        int thisPick = [self getPick:i+1 :MY_PICK];
        if(thisPick < pick) NSLog(@"Pick %i: You picked the %@ %@, who is projected to score %f points.", thisPick, myPositions[((Player*)myPicks[i]).position], ((Player*)myPicks[i]).name, ((Player*)myPicks[i]).points);
        else {
            int recPos = [bestNames[i+1] intValue];
            NSLog(@"Pick %i: Recomended position is %@.", thisPick, myPositions[recPos]);
            for(int j=0; j<4; j++) {
                int TO_GRAB = 5;
                NSMutableArray *mostLikely = [self getMostLikely:pick :thisPick :TO_GRAB :j];
                NSLog(@"    •%@'s", myPositions[j]);
                for(int k = 0; k < TO_GRAB; k++) {
                    NSLog(@"    •%@.", ((Player*)mostLikely[k]).name);
                }
            }
        }
    }
}

-(void) calcBestDraft : (NSMutableArray *) myNumPositions : (int) myRound {
    NSMutableArray *numPositions = [NSMutableArray arrayWithArray:myNumPositions];
    int pick = MY_PICK;
    [self calcBest:numPositions :myRound :pick : 0];
    NSUInteger bcount = bestNames.count;
    for(int m = 1; m < bcount; m++) {
        //int currPick = [self getPick:m :pick];
        int pos = 0;
        if(bestNames[m] != 0) {
            pos = [bestNames[m] intValue];
        }
        //NSString *player = ((Player*)availablePlayers[pos][0]).name;
        //float value = [bestValues[pos][currPick] floatValue];
    }
}

-(float) calcBest : (NSMutableArray*) numPositions : (int) round : (int) pick : (int) numDeep {
    if(round > TOTAL_PICKS) return 0;
    float optimal = 0;
    int currPick = [self getPick:round :pick];
    NSArray *bestToReturn = [self arrayWithDimensions:@[N(TOTAL_PICKS+1), N((int)numPositions.count)]];
    NSUInteger bcount = bestToReturn.count;
    int optPos = 0;
    NSUInteger ncount = numPositions.count;
    for(int i=0; i<ncount; i++) {
        int pos = i;
        if([numPositions[i] intValue] > 0) {
            float weight = [playerValueWeights[pos][[numPositions[i] intValue] - 1] floatValue];
            numPositions[i] = N([numPositions[i] intValue] - 1);
            float total = weight*[bestValues[pos][currPick] floatValue];
            if(numDeep <= NUM_ROUNDS_IN_ADVANCE)
                total = weight*[bestValues[pos][currPick] floatValue] + [self calcBest:numPositions :round+1 :pick : numDeep+1];
            numPositions[i] = N([numPositions[i] intValue] + 1);
            if(total > optimal) {
                bestToReturn[round][i] = [NSString stringWithFormat:@"%i", pos];
                for(int m = round + 1; m < bcount; m++) {
                    bestToReturn[m][i] = bestNames[m];
                }
                optimal = total;
                optPos = i;
            }
        }
    }
    for(int m = 0; m < bcount; m++) {
        bestNames[m] = bestToReturn[m][optPos];
    }
    return optimal;
}

-(void) clearValues {
    NSUInteger pcount = positions.count;
    for(int i = 0; i < pcount; i++)
    {
        for(int j = 0; j < TOTAL_PICKS*NUM_TEAMS+1; j++)
        {
            bestValues[i][j] = @0;
        }
    }
}

-(void) setNoCalc : (BOOL) val {
    noCalc = val;
}

-(int) getPick : (int) round : (int) pick {
    int basePick = (round - 1) * NUM_TEAMS;
    int more = pick;
    if(round % 2 == 0)
        more = NUM_TEAMS + 1 - pick;
    return basePick + more;
}

-(int) getNextRoundToDraft {
    int round = [self getCurrentRound];
    if([self getPick:round :MY_PICK] >= [self getCurrentPick]) {
        return round;
    } else {
        return round+1;
    }
}

-(NSArray*) getNormalCurve : (float) mean : (float) stdev {
    int S = 1;
    if(stdev < EPSILON) stdev = 1;
    int L = TOTAL_PICKS*NUM_TEAMS+1;
    NSMutableArray *returnVals = [NSMutableArray arrayWithCapacity:L];
    float total = 0;
    for(int i=0; i<L; i++) {
        float val = 1/(stdev * sqrtf(2*M_PI));
        val *= powf(M_E, -(i-mean)*(i-mean)/(2*stdev*stdev));
        returnVals[i] = F(val);
        total += val;
    }
    float multiplier = S / total;
    for(int i=0; i<L; i++) {
        returnVals[i] = F([returnVals[i] floatValue] * multiplier);
    }
    return returnVals;
}

-(NSMutableArray*) arrayWithAllValuesNil : (int) length {
    NSMutableArray *array = [NSMutableArray array];
    for(int i=0; i<length; i++) {
        [array addObject:@0];
    }
    return array;
}

-(NSMutableArray*) arrayWithDimensions : (NSArray*) dimensions {
    NSMutableArray *array = [self arrayWithAllValuesNil:[dimensions[0] intValue]];
    NSUInteger acount = array.count;
    for(int i=0; i<acount; i++) {
        array[i] = [self arrayWithAllValuesNil:[dimensions[1] intValue]];
    }
    
    return array;
}

-(NSArray*) getContentsOfFile : (NSString*) fileName : (NSString*) type {
    NSString* fileRoot = [[NSBundle mainBundle] pathForResource:fileName ofType:type];
    NSString* fileContents = [NSString stringWithContentsOfFile:fileRoot encoding:NSUTF8StringEncoding error:nil];
    NSArray* allLinedStrings = [fileContents componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]];
    return allLinedStrings;
}

-(NSData*) getDataOfUserFile : (NSString*) fileName : (NSString*) type {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@.%@",documentsDirectory, fileName, type];
    
    NSData *fileContents = [NSData dataWithContentsOfFile:filePath];
    return fileContents;
}


-(NSArray*) getContentsOfUserFile : (NSString*) fileName : (NSString*) type {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@.%@",documentsDirectory, fileName, type];

    NSString* fileContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    if([fileContents  isEqual: @""]) return nil;
    NSArray* allLinedStrings = [fileContents componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]];
    return allLinedStrings;
}

-(void) saveArrayToFile : (NSString*) fileName : (NSString*) ext withArray: (NSArray*) array {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@.%@",documentsDirectory, fileName, ext];
    
    NSString *outString = [array componentsJoinedByString:@"\n"];
    NSError *error = nil;
    [outString writeToFile: filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
}

-(void) saveFileToDocuments : (NSString*) urlStr : (NSString*) name : (NSString*) ext {
    NSURL *url = [NSURL URLWithString:urlStr];
    
    NSString *content = [NSString stringWithContentsOfURL: url encoding:NSASCIIStringEncoding error:nil];
    
    NSArray* allLinedStrings = [NSArray arrayWithArray: [content componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]]];
    
    if(content == nil || [allLinedStrings[0]  isEqual: @"<html><head>"]) {
        allLinedStrings = [self getContentsOfFile:name :ext];
    }
    
    [self saveArrayToFile:name : ext withArray:allLinedStrings];

}

-(NSString*) getFirstLineOfURL : (NSString*) urlStr {
    NSURL *url = [NSURL URLWithString:urlStr];
    
    NSString *content = [NSString stringWithContentsOfURL: url encoding:NSASCIIStringEncoding error:nil];
    
    NSArray* allLinedStrings = [NSArray arrayWithArray: [content componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]]];
    
    if(content == nil || [allLinedStrings[0]  isEqual: @"<html><head>"]) {
        return @"";
    }
    
    return allLinedStrings[0];
}

-(void) saveFilesToDocuments {
    [self saveFileToDocuments:@"http://d214mfsab.org/projections.csv" :@"projections" :@"csv"];
    [self saveFileToDocuments:@"http://d214mfsab.org/stdev.csv" :@"stdev" :@"csv"];
    [self saveFileToDocuments:@"http://api.cbssports.com/fantasy/players/list?version=3.0&SPORT=football&response_format=json" : @"players":@"json"];
    NSString* updatedProjections = [self getFirstLineOfURL:@"http://d214mfsab.org/updatedProjections.html"];
    if ([updatedProjections isEqualToString: @"1"]) {
        [userDefaults setObject:@"1" forKey:@"updatedProjections2"];
    }
}

@end


























