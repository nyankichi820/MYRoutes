MYRoutes
====

simplify application view transition. original API make very easy and more useful.

- simplify code. automatic push and present viewcontroller to current controller
- Support for UINavigationController transition completion. not use delegate
- Support with parameters transtion
- Support url base routing like web servise

## Install

instal from cocoapods

     pod 'MYRoutes', '~> 0.1.0'

## Usage


### URL Routing

It is possible to dealthe URL of the various types. like a web service routing.

#### Routing Configurations

     [[MYRoutes shared] loadRouteConfig:@[
          @[@"/nib/:message" , @{@"nib":@"XIBTestViewController",@"class":@"MYViewController"}],
          @[@"/storyboard/first/:message" , @{@"storyboard":@"Main",@"identifier":@"First"}],
     ]];


### transition from Xib with parameter

    // push MYViewController from Xib has message an categoryId parameters 
    [routes dispatch:@"/nib/hello?category_id=1"]
    
### transition from Storyboard with parameter

    // push MYViewController from Storyboard has message parameter 
    [routes dispatch:@"/storyboard/first/hello"]
    
### open from url scheme 

    - (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
    sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
    {
        // dispatch from url scheme. example xxxx://tweet/view/id
        return [[MYRoutes shared] dispatch:url ];
    }

 
### open external app

    [routes dispatch:@"http://www.yahoo.co.jp"]

    
### manual transition

#### push to navigationcontroller

##### push view controller

    // auto search current navigation contorller
    [routes pushViewController:viewController animated:YES];


##### With Storyboard

    MYRoutes *routes = [MYRoutes shared];
    [routes pushViewController:@"ViewControllerIdnetifier" withStoryboard:@"StoryboardName" animated:YES];

##### With Xib

    [routes pushViewController:@"ViewController" withNib:@"ViewControllerXIB" animated:YES];

##### Extend feature use navigation completion block not use delegate

    [routes pushViewController:@"ViewControllerIdnetifier" withStoryboard:@"StoryboardName" animated:YES completion:^{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"navigation complete"
                                                        message:@"complete!!"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];

    }];

#### present view contorller 

##### push view controller
    
    // auto search current viewcontorller
    [routes presentViewController:viewController animated:YES completion:nil];
    
##### With Storyboard

    [routes presentViewController:@"ViewControllerIdnetifier" withStoryboard:@"StoryboardName" animated:YES completion:nil];

##### With Xib

    [routes presentViewController:@"ViewController" withNib:@"XIBTestViewController" animated:YES completion:nil];

##### with parameters transition

    NSDictionary *params = @{@"message":self.messageTexfield.text};
    [routes presentViewController:@"ViewControllerIdnetifier" withStoryboard:@"StoryboardName" animated:YES completion:nil];
    [routes pushViewController:@"ViewControllerIdnetifier" withStoryboard:@"StoryboardName" withParameters:params animated:YES completion:nil];


