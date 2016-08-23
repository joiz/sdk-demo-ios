//
//  Consts.h
//  joizSDKDemo
//
//  Created by George Ilies on 01.08.2016.
//  Copyright © 2016 Reea. All rights reserved.
//

#ifndef Consts_h
#define Consts_h

#import <JoizSDK/JoizSDKAppSettings.h>

#define absImageUrl(size, path) [path length] ? [NSString stringWithFormat:@"%@/media/cache/%@%@", [[JoizSDKAppSettings singleton] baseApiURL], size, path] : nil

#define kArticleModelFieldId                @"id"
#define kArticleModelFieldTitle             @"title"
#define kArticleModelFieldDescription       @"description"
#define kArticleModelFieldTeaserType        @"teaserType"
#define kArticleModelFieldImageUrl          @"imageUrl"
#define kArticleModelFieldCreatedDate       @"createdDate"
#define kArticleModelFieldUpdatedAt         @"updated_at"
#define kArticleModelFieldSponsorTag        @"sponsorTag"
#define kArticleModelFieldBlogName          @"blogName"
#define kArticleModelFieldsExtId            @"extId"
#define kArticleModelFieldCompetitionId     @"competitionId"

#define kJoizCompetitionDataPath(competitionId)              [NSString stringWithFormat:@"api/secure/red-button/%@/static", competitionId]

#endif /* Consts_h */
