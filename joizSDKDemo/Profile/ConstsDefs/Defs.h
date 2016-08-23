//
//  Defs.h
//  joizSDKDemo
//
//  Created by George Ilies on 03.08.2016.
//  Copyright © 2016 Reea. All rights reserved.
//

#ifndef Defs_h
#define Defs_h

#import <joizSDK/JoizSDKAppSettings.h>

#define absImageUrl(size, path) [path length] ? [NSString stringWithFormat:@"%@/media/cache/%@%@", [[JoizSDKAppSettings singleton] baseApiURL], size, path] : nil
#define kJoizCompetitionDataPath(competitionId)              [NSString stringWithFormat:@"api/secure/red-button/%@/static", competitionId]

#endif /* Defs_h */
