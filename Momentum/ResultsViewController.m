//
//  ResultsViewController.m
//  Momentum
//
//  Created by Joe on 21/02/14.
//  Copyright (c) 2014 Joe. All rights reserved.
//

#import "ResultsViewController.h"
#import "ResultsMilestoneProgress.h"
#import "AuthService.h"
#import "CoreDataSingleton.h"
#import "User.h"
#import "SoloChallenge.h"
#import "Charity.h"
#import "UIImage+animatedGIF.h"
#import "Milestones.h"


@interface ResultsViewController()

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (nonatomic) NSInteger index;
@property (strong, nonatomic) AuthService *authService;
@property (strong, nonatomic) CoreDataSingleton *coreData;
@property (strong, nonatomic) UIStoryboard *layoutStoryboard;
@property (strong, nonatomic) UIViewController *results;


//these are test buttons
@property (weak, nonatomic) IBOutlet UIButton *progressButton;

- (IBAction)soloProgUpdate:(id)sender;

@end


@implementation ResultsViewController

- (void) viewDidLoad{
    //UIImage *img = [UIImage animatedImageWithAnimatedGIFURL:[NSURL URLWithString:@"http://media3.giphy.com/media/kIi56vFHsAlb2/giphy.gif"]];
    
    //self.resultsBackground.image = img;
    
    //creates a new back button to replace the navigation controller one.
    //suprisingly difficult, THANKS APPLE
    UIButton* backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 90, 30)];
    [backButton setTitle:@"Challenges" forState:UIControlStateNormal];
    [backButton setContentEdgeInsets:UIEdgeInsetsMake(-2.5, 0, 0, 0)];
    backButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:15.0];
    [backButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(toChallengeAction:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setShowsTouchWhenHighlighted:YES];
    UIBarButtonItem* rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.navigationItem setRightBarButtonItem:rightBarButtonItem];
    
    CoreDataSingleton *coreData = [[CoreDataSingleton alloc] init];
    User *user = [coreData getUserInfo];
    
    self.layoutStoryboard = [UIStoryboard storyboardWithName:@"ResultsStoryboard" bundle:[NSBundle mainBundle]];
    if(user.userChallenge == nil){
        self.navigationController.navigationBarHidden = YES;
        self.results = [self.layoutStoryboard instantiateViewControllerWithIdentifier:@"NoChallengeSelectedView"];
    }
    else{
        self.navigationController.navigationBarHidden = NO;
        self.results = [self.layoutStoryboard instantiateViewControllerWithIdentifier:@"ResultsMilestoneProgress"];
    }
    
    [self addChildViewController:self.results];
    [self.results didMoveToParentViewController:self];
    
    self.authService = [AuthService getInstance];
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bang) name:@"UIApplicationDidEnterBackgroundNotification" object:nil];
}

-(void) viewDidAppear:(BOOL)animated{
    //this is here as the frame is resized after view did load
    //else we would have the frame 

    CoreDataSingleton *coreData = [[CoreDataSingleton alloc] init];
    
    User *user = [coreData getUserInfo];
    //NSLog(@"%@", user.userChallenge.);
    
    if(user.userChallenge != nil){
        self.navigationController.navigationBarHidden = NO;
    }
    else{
        self.navigationController.navigationBarHidden = YES;
    }
    
    CGRect frame = self.results.view.frame;
    frame.size.height = self.view.frame.size.height;
    self.results.view.frame = frame;
    [self.results.view addSubview:self
     .progressButton];
    //[self.results.view addSubview:self.challengeButton];
    [self.view addSubview:self.results.view];
}


- (IBAction)soloProgUpdate:(id)sender {
    CoreDataSingleton *coreData = [[CoreDataSingleton alloc] init];
    
    User*user = [coreData getUserInfo];
    
    
    NSLog(@"%@",user.userChallenge.challengeName);
    NSLog(@"%@", user.userChallenge.charity.charityName);
    NSDictionary *dict = @{@"User_idUser" : user.idUser, @"soloChallenge_idsoloChallenge": user.userChallenge.challengeID, @"steps": @"0", @"walkD": user.totalWalkingDist, @"runD": user.totalRunningDist, @"cycleD": @"200", @"challengeComplete": @"1", @"sChallengeAmountRaised" : @"10"};
    //user.totalAmountRaised
    
    [self.authService.client invokeAPI:@"soloprogressupdate" body:dict HTTPMethod:@"POST" parameters:nil headers:nil completion:^(id result, NSHTTPURLResponse *response, NSError *error) {
        if(error){
            NSLog(@"%@", [error localizedDescription]);
        }
        else{
            NSLog(@"Success");
            NSLog(@"%@", result);
        }
    }];
}

- (void) toChallengeAction:(id)sender{
    [self performSegueWithIdentifier:@"ChallengePageSegue" sender:self];
}

- (void) setResultsBackground{
    
    if ([self.results  isKindOfClass:[ResultsMilestoneProgress class]]) {
        ResultsMilestoneProgress *result = (ResultsMilestoneProgress*)self.results;
        [result killPedometer];
    }
    
    [self.results.view removeFromSuperview];
    self.results = nil;
    
    self.results = [self.layoutStoryboard instantiateViewControllerWithIdentifier:@"ResultsMilestoneProgress"];
    self.results.view.alpha = 0;
    [self.view addSubview:self.results.view];

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelay:0.5];
    self.results.view.alpha = 1;
    [UIView commitAnimations];

}



@end
