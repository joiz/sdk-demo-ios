//
//  CompetitionsViewController.m
//  joizSDKDemo
//
//  Created by George Ilies on 01.08.2016.
//  Copyright © 2016 Reea. All rights reserved.
//

#import "CompetitionsViewController.h"
#import <joizSDK/JoizApiClient.h>
#import <joizSDK/JoizSDKUtilities.h>
#import <joizSDK/JoizSDKLoginManager.h>
#import "Consts.h"
#import "Defs.h"
#import "HomeCompetitionCell.h"
#import "JZSpinner.h"
#import <joizSDK/JZCompetitionsWebFormViewController.h>
#import <joizSDK/NSBundle+JZAdditions.h>


static NSString *kHomeCompetitionCellIdentifier = @"HomeCompetitionCellIdentifier";

@interface CompetitionsViewController()

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *competitionsData;

@end

@implementation CompetitionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    UIView *fv = [[UIView alloc] initWithFrame:CGRectZero];
    fv.backgroundColor = [UIColor clearColor];
    [self.tableView  setTableFooterView:fv];
    fv = nil;
}
#pragma mark -
#pragma mark UITableView Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.competitionsData count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *compData = [self.competitionsData objectAtIndex:indexPath.row];

    if ([[JoizSDKLoginManager shared] isLoggedIn]) {
            //            __weak JZGenericArticleDetailViewController *weakSelf = self;
        NSString *path = kJoizCompetitionDataPath(compData[@"competitionId"]);  
        [[JZSpinner defaultSpinner] showWaitView:@"Info" detailedText:@"Please wait"];
        [[JoizAPIClient client] GET:path parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                NSInteger statusCode = 0;//some malformed answer. If the status code will be missing , the form won't be shown
                if (responseObject[@"status_code"]) {
                    statusCode = [responseObject[@"status_code"] intValue];
                }
                
                switch (statusCode) {
                    case 0: { 
                        
                    }
                        break;
                    case 9092: { //already submitted, back
                        [[JZSpinner defaultSpinner] showWaitView:JZLocalizedString(@"info", @"")
                                                    detailedText:JZLocalizedString(@"alreadySubmitted", @"")
                                               hideAfterDuration:1.5];
                        
                        return;
                    }
                        break;
                        
                    default: {
                        [[JZSpinner defaultSpinner] showWaitView:JZLocalizedString(@"info", @"")
                                                    detailedText:JZLocalizedString(@"error", @"")
                                               hideAfterDuration:1.5];
                        return;
                    }
                        break;
                }
                
                if (!statusCode && 
                    [responseObject[@"formFields"] count] &&
                    [responseObject[@"campaignId"] intValue]) {
                    
                    JZCompetitionsWebFormViewController *competitionsVC = [[JZCompetitionsWebFormViewController alloc]
                                                                           initWithNibName:@"JZCompetitionsWebFormViewController"
                                                                           bundle:[NSBundle joizSDKResourcesBundle]];

                    [self.navigationController pushViewController:competitionsVC animated:YES];
                    
                    [competitionsVC setCampaignData:responseObject];
                    competitionsVC = nil;
                    
                    [[JZSpinner defaultSpinner] hideWaitView];
                } else {
                    //wrong competition data
                    NSString *errorMessage = @"Fetching competition data has failed";
                    if (responseObject[@"errorMessage"]) {
                        errorMessage = responseObject[@"errorMessage"];
                    }
                    
                    [[JZSpinner defaultSpinner] showWaitView:@"Error" detailedText:errorMessage hideAfterDuration:3.0f];
                }
            } else if ([responseObject isKindOfClass:[NSError class]]) {
                if ([responseObject code] == 403) { //authentication error
                    [[JZSpinner defaultSpinner] showWaitView:@"Info" detailedText:@"Your authentication has expired. Please authenticate, then try again" hideAfterDuration:2.0];            
                    
                    return;
                }            
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if ([error code] == 403) { //authentication error
                [[JZSpinner defaultSpinner] showWaitView:@"Info" detailedText:@"Your authentication has expired. Please authenticate, then try again" hideAfterDuration:2.0];            
//                    [[ContentManager shared] redirectToAuthScreen];
                
                return;
            } 
        }];
    } else {
        //goto authentication
        //[[ContentManager shared] gotoLoginScreen];
    }
}

-(void) loadData {
    NSString *path = [NSString stringWithFormat:@"/api/v1/articles/competition/%ld/%d", 0l, 20];
    
    __weak CompetitionsViewController *weakSelf = self; 
    [[JZSpinner defaultSpinner] showWaitView:@"Info" detailedText:@"Please wait"];
    [[JoizAPIClient client] GET:path parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSMutableArray *tmpItems = [NSMutableArray arrayWithArray:weakSelf.competitionsData];
            if ([responseObject[@"items"] isKindOfClass:[NSArray class]]) {
                //                    NSInteger rowsCount = [strongSelf.competitionsData count];                        
                //                    NSInteger validItems = 0;
                //cleanup API crap
                for (NSDictionary *compData in responseObject[@"items"]) {
                    NSString *competitionId = [JoizSDKUtilities safeString:[compData objectForKey:@"competition_id"]];
                    if ([competitionId integerValue]) {
                        NSString *imageUrl = [[JoizSDKUtilities safeString:[compData[@"teaser_image"] objectForKey:@"id"]] length] ? [compData[@"teaser_image"] objectForKey:@"id"] : @"";
                        NSDictionary *cleanData = @{
                                                    kArticleModelFieldCompetitionId : competitionId,
                                                    kArticleModelFieldImageUrl : imageUrl,
                                                    kArticleModelFieldTitle : [JoizSDKUtilities safeString:compData[@"title"]],
                                                    kArticleModelFieldDescription : [JoizSDKUtilities safeString:compData[@"teaser_text"]],
                                                    };
                        
                        [tmpItems addObject:cleanData];
                        cleanData = nil;
                    }
                    
                    //sort by date
                }
                //                    [tmpItems addObjectsFromArray:responseObject];
                weakSelf.competitionsData = [NSArray arrayWithArray:tmpItems];
                tmpItems = nil;
                
                [weakSelf.tableView reloadData];  
            }
        } else {
            UIView *fv = [[UIView alloc] initWithFrame:CGRectZero];
            fv.backgroundColor = [UIColor clearColor];
            [weakSelf.tableView  setTableFooterView:fv];
            fv = nil;
        }
        [[JZSpinner defaultSpinner] hideWaitView];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [[JZSpinner defaultSpinner] showWaitView:@"Error" detailedText:@"Competition data could not be fetched" hideAfterDuration:3.0f];
    }];
}

-(UITableViewCell *)tableView: (UITableView *) tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *cellData = [self.competitionsData objectAtIndex:indexPath.row];
    HomeCompetitionCell *cell = [tableView dequeueReusableCellWithIdentifier:kHomeCompetitionCellIdentifier forIndexPath:indexPath];
    
    [cell configureCell:cellData];
    
    return cell;
}

@end
