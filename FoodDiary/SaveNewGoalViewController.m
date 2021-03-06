//
//  SaveNewGoalViewController.m
//  FoodDiary
//
//  Created by James Hicklin on 2013-07-15.
//  Copyright (c) 2013 James Hicklin. All rights reserved.
//

#import "SaveNewGoalViewController.h"
#import "MealController.h"
#import "DateManipulator.h"
#import "StoredWeight.h"
#import "CalorieCalculator.h"

@interface SaveNewGoalViewController ()

@end

@implementation SaveNewGoalViewController

@synthesize goalWeightLabel;
@synthesize goalDateLabel;
@synthesize totalCaloriesLabel;
@synthesize currentWeightKg;
@synthesize currentWeightLbs;

NSUserDefaults *profile;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
  profile = [NSUserDefaults standardUserDefaults];
  
  // MALE == 0, FEMALE == 1
  NSInteger gender = [profile integerForKey:@"gender"];
  CGFloat metricWeight = currentWeightKg;
  CGFloat metricHeight = [profile floatForKey:@"cm"];
  NSInteger age = [profile integerForKey:@"age"];
    
    CalorieCalculator *calorieCalculator = [[CalorieCalculator alloc] init];
  
  CGFloat bmr = [calorieCalculator calculateBMR:metricWeight height:metricHeight age:age gender:gender];
  
  NSInteger activityLevel = [profile integerForKey:@"activityLevel"];
  
  // Harris Benedict Equation
  CGFloat calsToMaintainWeight = [calorieCalculator harrisBenedict:bmr activityLevel:activityLevel];
  [profile setFloat:calsToMaintainWeight forKey:@"calsToMaintainWeight"];
 // CGFloat calsToMaintainWeight = [profile floatForKey:@"calsToMaintainWeight"];
  
  
  CGFloat currentWeight = currentWeightLbs;//[profile floatForKey:@"lbs"];
  CGFloat goalWeightLbs = [profile floatForKey:@"goalWeightLbs"];
  CGFloat goalWeightKg = [profile floatForKey:@"goalWeightKg"];
  NSInteger timeToLose = [profile integerForKey:@"timeForGoal"];
  BOOL unitType = [profile boolForKey:@"unitType"];
  
  CGFloat amountToChange = [self deficitCalculation:currentWeight goalWeight:goalWeightLbs timeToLose:timeToLose];
  
  CGFloat totalCalsToConsume;
  if (currentWeight > goalWeightLbs)
    totalCalsToConsume = calsToMaintainWeight - amountToChange;
  else if (currentWeight < goalWeightLbs)
    totalCalsToConsume = calsToMaintainWeight + amountToChange;
  else
    totalCalsToConsume = calsToMaintainWeight;
  
  if (totalCalsToConsume < 1200 && gender == 1){
    totalCalsToConsume = (CGFloat)1200;
   timeToLose = ((CGFloat)3500 * (currentWeight - goalWeightLbs))/(calsToMaintainWeight-1200)/7;
    [self showWarningAlert];
   }
  if (totalCalsToConsume < 1800 && gender == 0) {
    totalCalsToConsume = (CGFloat)1800;
    timeToLose = ((CGFloat)3500 * (currentWeight - goalWeightLbs))/(calsToMaintainWeight-1800)/7;
    [self showWarningAlert];
  }
   goalDateLabel.text = [NSString stringWithFormat:@"%d weeks", timeToLose];
  if (unitType == NO){
   goalWeightLabel.text = [NSString stringWithFormat:@"%.00f lbs", goalWeightLbs];
  }
  else {
    goalWeightLabel.text = [NSString stringWithFormat:@"%.00f kg", goalWeightKg];
  }
  totalCaloriesLabel.text = [NSString stringWithFormat:@"%.00f calories", totalCalsToConsume];
  
  [profile setFloat:totalCalsToConsume forKey:@"calsToConsumeToReachGoal"];
  
  NSDate *goalStartDate = [NSDate date];
  [profile setObject:goalStartDate forKey:@"goalStartDate"];
  
  DateManipulator *dateManipulator = [[DateManipulator alloc] initWithDateFormatter];
  NSDate *goalFinishDate = [dateManipulator findDateWithOffset:timeToLose*7 date:goalStartDate];
  [profile setObject:goalFinishDate forKey:@"goalFinishDate"];
  
  [profile setInteger:(NSInteger)timeToLose forKey:@"timeForGoal"];
  
  MealController *controller = [MealController sharedInstance];
  controller.calorieCountTodayFloat = 0;
  controller.totalCalsNeeded = totalCalsToConsume;
  [profile synchronize];
  
}

-(void)showWarningAlert {
  
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning!" message:@"The goal you set resulted in a daily calorie goal of fewer than the minimum recommended number of calories per day (1800 for men and 1200 for women). Food Buddy adjusted the time frame accordingly." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
  [alert show];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)saveGoal:(id)sender {
  
  [profile setBool:YES forKey:@"goalSet"];
  MealController *controller = [MealController sharedInstance];
  NSCalendar *calendar = [NSCalendar currentCalendar];
  NSDate *date = [controller dateToShow];
  
  DateManipulator *dateManipulator = [[DateManipulator alloc] initWithDateFormatter];
  NSDate *start = [dateManipulator getDateForDateAndTime:calendar date:date hour:0 minutes:0 seconds:0];
  NSDate *end = [dateManipulator getDateForDateAndTime:calendar date:date hour:23 minutes:59 seconds:59];
  
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(date >= %@) AND (date <= %@)", start, end];
  
  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  [request setEntity:[NSEntityDescription entityForName:@"StoredWeight" inManagedObjectContext:[controller managedObjectContext]]];
  [request setPredicate:predicate];
  
  NSError *error = nil;
  NSArray *results = [[controller managedObjectContext] executeFetchRequest:request error:&error];
  StoredWeight *weight;
  CGFloat weightInKg;
  CGFloat weightInLbs;
  if ([profile boolForKey:@"unitType"]) {
    // convert weights to lbs
    weightInKg = currentWeightKg;
    weightInLbs = weightInKg*2.2046;
  }
  else {
    // convert weights to kg
    weightInLbs = currentWeightLbs;
    weightInKg = weightInLbs/2.2046;
  }
  
  if ([results count] == 0) {
    weight = (StoredWeight*)[NSEntityDescription insertNewObjectForEntityForName:@"StoredWeight" inManagedObjectContext:[controller managedObjectContext]];
    [weight setDate:[NSDate date]];
  }
  else {
    weight = [results objectAtIndex:0];
  }
  
  NSUserDefaults *profile = [NSUserDefaults standardUserDefaults];
  [profile setFloat:weightInLbs forKey:@"lbs"];
  [profile setFloat:weightInKg forKey:@"kg"];
  
  [weight setLbs:[NSNumber numberWithFloat:weightInLbs]];
  [weight setKg:[NSNumber numberWithFloat:weightInKg]];
  
  if (![[controller managedObjectContext] save:&error]) {
    [controller showDetailedErrorInfo:error];
  }
  
  [profile setFloat:weightInLbs forKey:@"lbs"];
  [profile setFloat:weightInKg forKey:@"kg"];

  [profile synchronize];
  [self dismissViewControllerAnimated:YES completion:nil];
}

// Daily calorie deficit calculation - time is in weeks - 3500 cals in one pound
-(CGFloat)deficitCalculation:(CGFloat)currentWeight goalWeight:(CGFloat)goalWeight timeToLose:(NSInteger)timeToLose {
  
  CGFloat lbsDifference;
  if (currentWeight > goalWeight)
    lbsDifference = currentWeight - goalWeight;
  else
    lbsDifference = goalWeight - currentWeight;
  
  CGFloat amountToChange = ((CGFloat)3500 * lbsDifference) / (timeToLose * (CGFloat)7);
  return amountToChange;
  
}

@end
