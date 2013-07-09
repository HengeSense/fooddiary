//
//  ProfileViewController.m
//  FoodDiary
//
//  Created by James Hicklin on 2013-06-28.
//  Copyright (c) 2013 James Hicklin. All rights reserved.
//

#import "ProfileViewController.h"
#import "ProfileNameCell.h"
#import "NonEditableNameCell.h"
#import "ProfileAgeCell.h"
#import "NonEditableAgeCell.h"
#import "ProfileHeightCell.h"
#import "ProfileWeightCell.h"
#import "UnitSelectionViewController.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

BOOL unitType; // YES = metric, NO = english

// initiliaze these as 0
CGFloat feet = 0;
CGFloat inches = 0;
CGFloat cm = 0;
CGFloat kg = 0;
CGFloat lbs = 0;

NSString* firstName;
NSString* lastName;
NSInteger age;

ActionSheetCustomPicker *heightPicker;

// Editable Cells
ProfileNameCell *firstNameCell;
ProfileNameCell *lastNameCell;
ProfileHeightCell *heightCell;
ProfileWeightCell *weightCell;

// Non-Editable Cells
NonEditableNameCell *nameCell;
ProfileAgeCell *ageCell;
NonEditableAgeCell *noEditAgeCell;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}

-(NSArray*)feetAndInchesFromCm:(CGFloat)cm {
    CGFloat totalInches = cm * 0.39370;
    NSArray *feetAndInches = [NSArray arrayWithObjects:[NSNumber numberWithFloat:fmod(totalInches, 12)], [NSNumber numberWithFloat:totalInches/12], nil];
    return feetAndInches;
}

-(void)viewWillAppear:(BOOL)animated {
    
    NSUserDefaults *profile = [NSUserDefaults standardUserDefaults];
    
    // get all private variables from NSUserDefaults
    unitType = [profile boolForKey:@"unitType"];
    feet = [profile floatForKey:@"feet"];
    inches = [profile floatForKey:@"inches"];
    cm = [profile floatForKey:@"cm"];
    age = [profile integerForKey:@"age"];
    firstName = [profile stringForKey:@"firstName"];
    lastName = [profile stringForKey:@"lastName"];
    kg = [profile floatForKey:@"kg"];
    lbs = [profile floatForKey:@"lbs"];
    
    [self.tableView reloadData];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    // Return the number of rows in the section.
    if (self.editing == YES) {
        if (section == 0)
            return 2;
        if (section == 1)
            return 1;
        if (section == 2)
            return 3;
    }
    else {
        if (section == 0)
            return 1;
        if (section == 1)
            return 1;
        if (section == 2)
            return 2;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // Configure the cell...
    if (self.editing == YES) {
        
        // section 1 is the name section - in editing mode there is a first and last name field
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                firstNameCell = [tableView dequeueReusableCellWithIdentifier:@"profileNameCell"];
                
                // First Name Cell in editing mode
                firstNameCell.nameTextField.placeholder = @"First Name";
                firstNameCell.nameTextField.text = firstName;
                //firstNameCell.nameTextField.delegate = firstNameCell;
                
                return firstNameCell;
                
            }
            if (indexPath.row == 1) {
                lastNameCell = [tableView dequeueReusableCellWithIdentifier:@"profileNameCell"];
                
                // Last Name Cell in editing mode
                lastNameCell.nameTextField.placeholder = @"Last Name";
                lastNameCell.nameTextField.text = lastName;
                //lastNameCell.nameTextField.delegate = lastNameCell;
                
                return lastNameCell;
            }
            
        }
        // section 1 is the age section
        if (indexPath.section == 1) {
            ageCell = [tableView dequeueReusableCellWithIdentifier:@"profileAgeCell"];
            ageCell.ageTextBox.text = [NSString stringWithFormat:@"%d", age];
            return ageCell;
        }
        
        if (indexPath.section == 2) {
            if (indexPath.row == 0) {
                static NSString *standardIdentifier = @"cellId";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:standardIdentifier];
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:standardIdentifier];
                cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.textLabel.font = [UIFont systemFontOfSize:11];
                cell.textLabel.text = @"Measurement Unit";
                cell.detailTextLabel.font = [UIFont systemFontOfSize:17];
                if (unitType == NO) {
                    cell.detailTextLabel.text = @"English";
                }
                else {
                    cell.detailTextLabel.text = @"Metric";
                }
                
                return cell;
                
            }
            if (indexPath.row == 1) {
                heightCell = [tableView dequeueReusableCellWithIdentifier:@"heightCell"];
                
                UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
                numberToolbar.barStyle = UIBarStyleBlackTranslucent;
                numberToolbar.items = [NSArray arrayWithObjects:
                                       [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelHeightNumberPad:)],
                                       [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                                       [[UIBarButtonItem alloc]initWithTitle:@"Apply" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithHeightNumberPad:)],
                                       nil];
                [numberToolbar sizeToFit];
                heightCell.metricHeightTextField.inputAccessoryView = numberToolbar;
                
                if (unitType == NO) {
                    heightPicker = [[ActionSheetCustomPicker alloc] initWithTitle:@"Height Picker" delegate:self showCancelButton:YES origin:self.tableView];
                    NSString *englishHeight = [NSString stringWithFormat:@"%.00f\" %.00f'", feet, inches];
                    heightCell.metricHeightTextField.text = englishHeight;
                    [heightCell.metricHeightTextField setEnabled:NO];
                    heightCell.cmLabel.hidden = YES;
                }
                else {
                    heightCell.cmLabel.hidden = NO;
                    [heightCell.metricHeightTextField setEnabled:YES];
                    NSString *metricHeight = [NSString stringWithFormat:@"%.00f",cm];
                    heightCell.metricHeightTextField.text = metricHeight;
                    
                }
                return heightCell;
            }
            if (indexPath.row == 2) {
                weightCell = [tableView dequeueReusableCellWithIdentifier:@"weightCell"];
                
                UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
                numberToolbar.barStyle = UIBarStyleBlackTranslucent;
                numberToolbar.items = [NSArray arrayWithObjects:
                                       [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelWeightNumberPad:)],
                                       [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                                       [[UIBarButtonItem alloc]initWithTitle:@"Apply" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithWeightNumberPad:)],
                                       nil];
                [numberToolbar sizeToFit];
                weightCell.weightTextField.inputAccessoryView = numberToolbar;
                [weightCell.weightTextField setEnabled:YES];
                
                if (unitType == NO) {
                    weightCell.weightTextField.text = [NSString stringWithFormat:@"%.00f lbs", lbs];
                }
                else {
                    weightCell.weightTextField.text = [NSString stringWithFormat:@"%.00f kg", kg];
                }
                return weightCell;
            }
        }
    }
    else {
        
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                nameCell = [tableView dequeueReusableCellWithIdentifier:@"nonEditableNameCell"];
                // First Name Cell in non-editing mode
                nameCell.name.text = [firstName stringByAppendingFormat:@" %@", lastName];
                
                return nameCell;
            }
        }
        if (indexPath.section == 1) {
            noEditAgeCell = [tableView dequeueReusableCellWithIdentifier:@"nonEditableAgeCell"];
            if (age != 0)
                noEditAgeCell.ageLabel.text = [NSString stringWithFormat:@"%d", age];
            else
                noEditAgeCell.ageLabel.text = @"";
            
            return noEditAgeCell;
            
            
        }
        if (indexPath.section == 2) {
            if (indexPath.row == 0) {
                heightCell = [tableView dequeueReusableCellWithIdentifier:@"heightCell"];
                [heightCell.metricHeightTextField setEnabled:NO];
                if (unitType == NO) {
                    heightCell.cmLabel.hidden = YES;
                    NSString *englishHeight = [NSString stringWithFormat:@"%.00f\" %.00f'", feet, inches];
                    heightCell.metricHeightTextField.text = englishHeight;
                }
                else {
                    heightCell.cmLabel.hidden = NO;
                    NSString *metricHeight = [NSString stringWithFormat:@"%.00f",cm];
                    heightCell.metricHeightTextField.text = metricHeight;
                }
                
                return heightCell;
            }
            if (indexPath.row == 1) {
                weightCell = [tableView dequeueReusableCellWithIdentifier:@"weightCell"];
                [weightCell.weightTextField setEnabled:NO];
                if (unitType == NO) {
                    weightCell.weightTextField.text = [NSString stringWithFormat:@"%.00f lbs", lbs];
                }
                else {
                    weightCell.weightTextField.text = [NSString stringWithFormat:@"%.00f kg", kg];
                }
                return weightCell;
            }
        }
        
    }
    
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    
    if (indexPath.section == 2 && self.editing == YES && indexPath.row == 0) {
        [self performSegueWithIdentifier:@"unitTypeSegue" sender:self];
    }
    if (indexPath.section == 2 && self.editing == YES && indexPath.row == 1 && unitType == NO) {
        [heightPicker showActionSheetPicker];
        
        [(UIPickerView*)heightPicker.pickerView selectRow:feet-1 inComponent:0 animated:NO];
        [(UIPickerView*)heightPicker.pickerView selectRow:inches inComponent:1 animated:NO];
    }
    
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
    
    if(editing == YES)
    {
        
        // NSIndexSet *section = [NSIndexSet indexSetWithIndexesInRange:range];
        
        //  [self.tableView beginUpdates];
        //  [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:0],[NSIndexPath indexPathForRow:0 inSection:2],nil] withRowAnimation:UITableViewRowAnimationBottom];
        //  [self.tableView endUpdates];
        
        //  [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
        //  [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
        //[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationNone];
        
        //  if (unitType == NO) {
        //    [heightCell.metricHeightTextField setEnabled:NO];
        //  }
        [self.tableView reloadData];
        
        
    } else {
        // Your code for exiting edit mode goes here
        
        // Resign first responders so that profile information is updated
        [self textFieldShouldReturn:firstNameCell.nameTextField];
        [self textFieldShouldReturn:lastNameCell.nameTextField];
        [self textFieldShouldReturn:ageCell.ageTextBox];
        [heightCell.metricHeightTextField resignFirstResponder];
        
        [self.tableView reloadData];
        //[self.tableView reloadData];
        //  [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:0],[NSIndexPath indexPathForRow:0 inSection:2],nil] withRowAnimation:UITableViewRowAnimationFade];
        
        //  [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
        //  [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
        //[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationFade];
        // [heightCell.metricHeightTextField setEnabled:NO];
        
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    NSUserDefaults *profile = [NSUserDefaults standardUserDefaults];
    
    if (textField == firstNameCell.nameTextField){
        firstName = textField.text;
        [profile setObject:textField.text forKey:@"firstName"];
    }
    if (textField == lastNameCell.nameTextField){
        lastName = textField.text;
        [profile setObject:textField.text forKey:@"lastName"];
    }
    if (textField == ageCell.ageTextBox){
        age = [textField.text integerValue];
        [profile setInteger:[textField.text integerValue] forKey:@"age"];
    }
    if (textField == heightCell.metricHeightTextField) {
        cm = [textField.text floatValue];
        
        inches = [[[self feetAndInchesFromCm:cm] objectAtIndex:0] floatValue];
        feet = [[[self feetAndInchesFromCm:cm] objectAtIndex:1] floatValue];
        
        [profile setFloat:inches forKey:@"inches"];
        [profile setFloat:feet forKey:@"feet"];
        [profile setFloat:[textField.text floatValue] forKey:@"cm"];
    }

    [profile synchronize];
    
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    
    NSUserDefaults *profile = [NSUserDefaults standardUserDefaults];
    
    if (textField == firstNameCell.nameTextField){
        firstName = textField.text;
        [profile setObject:textField.text forKey:@"firstName"];
    }
    if (textField == lastNameCell.nameTextField){
        lastName = textField.text;
        [profile setObject:textField.text forKey:@"lastName"];
    }
    if (textField == ageCell.ageTextBox){
        age = [textField.text integerValue];
        [profile setInteger:[textField.text integerValue] forKey:@"age"];
    }
    
    [profile synchronize];
    
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == weightCell.weightTextField) {
        if (unitType == NO) {
            weightCell.weightTextField.text = [NSString stringWithFormat:@"%.00f", lbs];
        }
        else {
            kg = [weightCell.weightTextField.text floatValue];
            lbs = kg / 0.453592;
            weightCell.weightTextField.text = [NSString stringWithFormat:@"%.00f", kg];
        }
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleNone;
}


-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    return 2;
    
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    if (component == 0)
        return 7;
    else
        return 12;
    
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    if (component == 0)
        return [NSString stringWithFormat:@"%d'", row+1];
    else
        return [NSString stringWithFormat:@"%d\"", row];
    
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    
    NSUserDefaults *profile = [NSUserDefaults standardUserDefaults];
    if (component == 0) {
        feet = row+1;
        [profile setFloat:feet forKey:@"feet"];
    }
    else {
        inches = row;
        [profile setFloat:inches forKey:@"inches"];
    }
    
    cm = ((feet * 12) + inches) / 0.39370;
    [profile setFloat:cm forKey:@"cm"];
    
    [profile synchronize];
    
    NSString *englishHeight = [NSString stringWithFormat:@"%.00f\" %.00f'", feet, inches];
    heightCell.metricHeightTextField.text = englishHeight;
    
}

//------------------------ Height Number Pad Methods -------------------------//
-(IBAction)cancelHeightNumberPad:(id)sender{
    [heightCell.metricHeightTextField resignFirstResponder];
    if (unitType == NO) {
        
        NSString *englishHeight = [NSString stringWithFormat:@"%.00f\" %.00f'", feet, inches];
        heightCell.metricHeightTextField.text = englishHeight;
        
    }
    else {
        
        NSString *metricHeight = [NSString stringWithFormat:@"%.00f",cm];
        heightCell.metricHeightTextField.text = metricHeight;
        
    }
    
}

-(IBAction)doneWithHeightNumberPad:(id)sender{
    
    NSUserDefaults *profile = [NSUserDefaults standardUserDefaults];
    
    cm = [heightCell.metricHeightTextField.text floatValue];
    inches = [[[self feetAndInchesFromCm:cm] objectAtIndex:0] floatValue];
    feet = [[[self feetAndInchesFromCm:cm] objectAtIndex:1] floatValue];
    [profile setFloat:inches forKey:@"inches"];
    [profile setFloat:feet forKey:@"feet"];
    [profile setFloat:cm forKey:@"cm"];
    [heightCell.metricHeightTextField resignFirstResponder];
    
    [profile synchronize];
}

//------------------------------- Weight Number Pad Methods ------------------------------//


-(IBAction)cancelWeightNumberPad:(id)sender{
    [weightCell.weightTextField resignFirstResponder];
    if (unitType == NO) {
        weightCell.weightTextField.text = [NSString stringWithFormat:@"%.00f lbs", lbs];
    }
    else {
        weightCell.weightTextField.text = [NSString stringWithFormat:@"%.00f kg", kg];
    }
    
}

-(IBAction)doneWithWeightNumberPad:(id)sender{
    
    NSUserDefaults *profile = [NSUserDefaults standardUserDefaults];
    
    if (unitType == NO) {
        lbs = [weightCell.weightTextField.text floatValue];
        kg = lbs * 0.453592;
        weightCell.weightTextField.text = [NSString stringWithFormat:@"%.00f lbs", lbs];
    }
    else {
        kg = [weightCell.weightTextField.text floatValue];
        lbs = kg / 0.453592;
        weightCell.weightTextField.text = [NSString stringWithFormat:@"%.00f kg", kg];
    }
    
    [profile setFloat:kg forKey:@"kg"];
    [profile setFloat:lbs forKey:@"lbs"];
    
    [weightCell.weightTextField resignFirstResponder];
    [profile synchronize];
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.view cache:YES];
    
    self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableView.frame.size.height); //resize
    [UIView commitAnimations];
    return YES;
}


@end
