MYRoutes
====

simplify application view transition. original API make very easy and more useful.

- simplify code. automatic push and present viewcontroller
- Support for UINavigationController transition completion. not use delegate
- Support with parameters transtion

## Usage

### push to navigationcontroller

#### push view controller

    // auto search current navigation contorller
    [routes pushViewController:viewController animated:YES];


#### With Storyboard

    MYRoutes *routes = [MYRoutes shared];
    [routes pushViewController:@"ViewControllerIdnetifier" withStoryboard:@"StoryboardName" animated:YES];

#### With Xib

    [routes pushViewController:@"ViewController" withNib:@"ViewControllerXIB" animated:YES];

#### Extend feature use navigation completion block not use delegate

    [routes pushViewController:@"ViewControllerIdnetifier" withStoryboard:@"StoryboardName" animated:YES completion:^{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"navigation complete"
                                                        message:@"complete!!"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];

    }];

### present view contorller 

#### push view controller
    
    // auto search current viewcontorller
    [routes presentViewController:viewController animated:YES completion:nil];
    
#### With Storyboard

    [routes presentViewController:@"ViewControllerIdnetifier" withStoryboard:@"StoryboardName" animated:YES completion:nil];

#### With Xib

    [routes presentViewController:@"ViewController" withNib:@"XIBTestViewController" animated:YES completion:nil];

#### with parameters transition

    NSDictionary *params = @{@"message":self.messageTexfield.text};
    [routes presentViewController:@"ViewControllerIdnetifier" withStoryboard:@"StoryboardName" animated:YES completion:nil];
    [routes pushViewController:@"ViewControllerIdnetifier" withStoryboard:@"StoryboardName" withParameters:params animated:YES completion:nil];

## Next Implement Feature

comming soon

## URL Routing

It is possible to dealthe URL of the various types. like a web service routing.
### open external app

    [routes openURLString:@"http://www.yahoo.co.jp"]

### my app url scheme open with route configuration

    [routes openURLString:@"app://tweet/view/1"]

### internal url path open with route configuration

    // open tweet view  has parameter id = 1 
    [routes openURLString:@"/tweet/view/1"]

