//
//  AddFoodViewController.h
//  FoodDiary
//
//  Created by James Hicklin on 2013-06-15.
//  Copyright (c) 2013 James Hicklin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "FSFood.h"
#import "MyFood.h"
#import "CustomFood.h"

@interface AddFoodViewController : UIViewController <UISearchDisplayDelegate, UITableViewDataSource, UITableViewDelegate, UITabBarDelegate> {
  
  NSMutableArray *temporaryFoods;
  NSMutableArray *temporaryServings;
  
}

@property (nonatomic, strong) NSMutableArray *temporaryServings;
@property (nonatomic, strong) NSMutableArray *temporaryFoods;
@property (nonatomic, weak) FSFood *foodToBeSentToNextView;
@property (nonatomic, weak) MyFood *recentFoodToBeSentToNextView;
@property (nonatomic, weak) CustomFood *customFoodToBeSentToNextView;
@property (nonatomic, weak) NSString *foodDescription;
@property (strong, nonatomic) IBOutlet UITabBar *tabBar;
@property (strong, nonatomic) IBOutlet UITabBarItem *recentlyAdded;
@property (strong, nonatomic) IBOutlet UITabBarItem *savedMeals;
@property (strong, nonatomic) IBOutlet UITableView *tabBarTableView;
@property (strong, nonatomic) IBOutlet UIButton *foodsInMealButton;

-(IBAction)handleCancelButton:(id)sender;
- (IBAction)newFood:(id)sender;
- (IBAction)transitionToCurrentFoods:(id)sender;
- (IBAction)saveFoodsFromThisView:(id)sender;
-(void)saveFoods;

@end

