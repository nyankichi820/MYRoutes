//
//  MYViewController.m
//  MYRouter
//
//  Created by masafumi yoshida on 2014/03/14.
//  Copyright (c) 2014年 masafumi yoshida. All rights reserved.
//

#import "MYViewController.h"
#import "MYRoutes.h"

@interface MYViewController ()

@end

@implementation MYViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    if(self.message){
        self.messageLabel.text = self.message;
    }
    
 	// Do any additional setup after loading the view, typically from a nib.
}

-(IBAction)dispatchRouterToNib:(id)sender{
    MYRoutes *routes = [MYRoutes shared];
    NSURL *url =  [NSURL URLWithString:@"/nib/hello"];
    [routes dispatch:url];
}

-(IBAction)dispatchRouterToStoryboard:(id)sender{
    MYRoutes *routes = [MYRoutes shared];
    NSURL *url =  [NSURL URLWithString:@"/storyboard/first/good"];
    [routes dispatch:url];
}


-(IBAction)openFromScheme:(id)sender{
     [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"myroutes://nib/from_external"]];
}

-(IBAction)openExternalApp:(id)sender{
    MYRoutes *routes = [MYRoutes shared];
    NSURL *url =  [NSURL URLWithString:@"http://www.yahoo.co.jp"];
    [routes dispatch:url];
}

-(IBAction)pushInternalStoryboard:(id)sender{
      MYRoutes *routes = [MYRoutes shared];
    
    [routes pushViewController:@"First" withStoryboard:@"Main" animated:YES];
    
}

-(IBAction)pushExternalStoryboard:(id)sender{
    MYRoutes *routes = [MYRoutes shared];
    
    [routes pushViewController:@"Second" withStoryboard:@"Second" animated:YES];
    
}

-(IBAction)pushfromXib:(id)sender{
    MYRoutes *routes = [MYRoutes shared];
    
    [routes pushViewController:@"XIBTestViewController" withNib:@"XIBTestViewController" animated:YES];
}


-(IBAction)pushHasCompletion:(id)sender{
    MYRoutes *routes = [MYRoutes shared];
    
   
    [routes pushViewController:@"First" withStoryboard:@"Main" animated:YES completion:^{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"navigation complete"
                                                            message:@"complete!!"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        
    }];
    
}

-(IBAction)pushHasCompletionAndOriginalDelegate:(id)sender{
    MYRoutes *routes = [MYRoutes shared];
    
    self.navigationController.delegate = self;
    
    [routes pushViewController:@"First" withStoryboard:@"Main" animated:YES completion:^{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"navigation complete"
                                                            message:@"complete!!"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        
    }];
    
}



- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    
    MYViewController* myViewController = (MYViewController*)viewController;
    myViewController.messageLabel.text = @"complete has from original delegate";
    navigationController.delegate = nil;
    
}


-(IBAction)presentInternalStoryboard:(id)sender{
    MYRoutes *routes = [MYRoutes shared];
    
    [routes presentViewController:@"First" withStoryboard:@"Main" animated:YES completion:nil];
    
}

-(IBAction)presentExternalStoryboard:(id)sender{
    MYRoutes *routes = [MYRoutes shared];
    
    [routes presentViewController:@"Second" withStoryboard:@"Second" animated:YES completion:nil];
    
}

-(IBAction)presentFromXib:(id)sender{
    MYRoutes *routes = [MYRoutes shared];
    
    [routes presentViewController:@"MYViewController" withNib:@"XIBTestViewController" animated:YES completion:nil];
}


-(IBAction)pushWithParameter:(id)sender{
    MYRoutes *routes = [MYRoutes shared];
    
    NSDictionary *params = @{@"message":self.messageTexfield.text};
    
    [routes pushViewController:@"First" withStoryboard:@"Main" withParameters:params animated:YES completion:nil];
    
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField{
    [textField resignFirstResponder];
    return YES;
}

-(IBAction)close:(id)sender{
    if(self.navigationController){
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
        
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
