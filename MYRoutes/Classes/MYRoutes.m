//
//  MYRouter.m
//  MYRouter
//
//  Created by masafumi yoshida on 2014/03/14.
//  Copyright (c) 2014年 masafumi yoshida. All rights reserved.
//

#import "MYRoutes.h"


// url router is next implement feature
@interface MYRoute : NSObject
@property(nonatomic,strong) NSString *prefix;
@property(nonatomic,strong) NSDictionary *params;

+(MYRoute*)create:(NSString*)urlString;

-(BOOL)isMatch:(NSString*)urlString;


@end


@implementation MYRoute

+(MYRoute*)create:(NSString*)urlString{
    if(![urlString hasPrefix:@"/"]){
        return nil;
    }
    NSMutableString *prefix = [NSMutableString stringWithString:@"/"];
    
    NSArray *pathes = [[urlString substringFromIndex:1] componentsSeparatedByString:@"/"];
    for(NSString *path in pathes){
        if([urlString hasPrefix:@":"]){
            NSString *param = [urlString substringFromIndex:1];
        }
        else{
            [prefix appendString:@"/"];
            [prefix appendString:path];
        }
    }
    return nil;
}

-(BOOL)isMatch:(NSString*)urlString{
    
    return NO;
}


#pragma util methods

-(NSString *)snakeToCamelCase:(NSString *)underscores {
    NSMutableString *output = [NSMutableString string];
    BOOL makeNextCharacterUpperCase = NO;
    for (NSInteger idx = 0; idx < [underscores length]; idx += 1) {
        unichar c = [underscores characterAtIndex:idx];
        if (c == '_') {
            makeNextCharacterUpperCase = YES;
        } else if (makeNextCharacterUpperCase) {
            [output appendString:[[NSString stringWithCharacters:&c length:1] uppercaseString]];
            makeNextCharacterUpperCase = NO;
        } else {
            [output appendFormat:@"%C", c];
        }
    }
    return output;
}

-(NSString *)camelToSnakeCase:(NSString *)input {
    NSMutableString *output = [NSMutableString string];
    NSCharacterSet *uppercase = [NSCharacterSet uppercaseLetterCharacterSet];
    for (NSInteger idx = 0; idx < [input length]; idx += 1) {
        unichar c = [input characterAtIndex:idx];
        if ([uppercase characterIsMember:c]) {
            [output appendFormat:@"_%@", [[NSString stringWithCharacters:&c length:1] lowercaseString]];
        } else {
            [output appendFormat:@"%C", c];
        }
    }
    return output;
}


@end


    
@implementation MYRoutes



static MYRoutes *instance_ = nil;


+ (MYRoutes *) shared{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance_ = [ [ MYRoutes alloc] init ];

    });
    return instance_;
}

- (id) init
{
    if(nil != (self = [super init]))
    {
        self.canDynamicRouting = YES;
        self.routes = [NSMutableArray array];
    }
    return self;
}

-(void)openURLString:(NSString*)urlString{
    NSURL *url = [NSURL URLWithString:urlString];
    
    // external apps
    if(url.scheme && ![self isSelfUrlSchema:urlString]){
        [self openURLWithString:urlString];
    }
    else{
        // TODO: implement internal url routing
    }
}




-(BOOL)isSelfUrlSchema:(NSString*)urlString{
    NSArray *selfUrlSchames = [[[[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleURLTypes"] objectAtIndex:0] valueForKey:@"CFBundleURLSchemes"];
    
    for(NSString *selfUrlSchema in selfUrlSchames){
        if([selfUrlSchema isEqualToString:urlString]){
            return YES;
        }
    }
    return NO;
}

-(void)openURLWithString:(NSString*)urlString{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}

#pragma create navigation controller

-(UINavigationController*)currentNavigationController{
    UIViewController* rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    if([rootViewController isKindOfClass:[UINavigationController class]]){
        return (UINavigationController*)rootViewController;
    }
    else if(rootViewController.navigationController) {
        return rootViewController.navigationController;
    }
    return nil;
}

-(UIViewController*)currentViewController{
    UINavigationController* navigationViewController = [self currentNavigationController];
    if(navigationViewController){
        return navigationViewController.topViewController;
    }
    else{
        return [UIApplication sharedApplication].keyWindow.rootViewController;
    }
}

#pragma  create navigation controller

-(UIView*)createView:(NSObject*)owner withNib:(NSString*)nibName withParameters:(NSDictionary*)params{
    UIView *view = [self createView:owner withNib:nibName];
    [self assignParams:view params:params];
    return view;
}

-(UIView*)createView:(NSObject*)owner withNib:(NSString*)nibName{
    return[[[NSBundle mainBundle] loadNibNamed:nibName owner:owner options:nil] objectAtIndex:0];
    
}


-(UIViewController*)createViewController:(NSString*)identifier withStoryboard:(NSString*)storyboardName{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:[NSBundle mainBundle]];
    return [storyboard instantiateViewControllerWithIdentifier:identifier];
}


-(UIViewController*)createViewController:(NSString*)className withNib:(NSString*)nibName{
    Class class = NSClassFromString(className);
    
    UIViewController *viewController = [[class alloc] initWithNibName:nibName bundle:nil];
    
    return viewController;
}

-(UIViewController*)createViewController:(NSString*)identifier withStoryboard:(NSString*)storyboardName withParameters:(NSDictionary*)params{
    UIViewController *viewController = [self createViewController:identifier withStoryboard:storyboardName];
    
    [self assignParams:viewController params:params];
    return viewController;
}


-(UIViewController*)createViewController:(NSString*)className withNib:(NSString*)nibName withParameters:(NSDictionary*)params{
    UIViewController *viewController = [self createViewController:className withNib:nibName];
    [self assignParams:viewController params:params];
    return viewController;
}

-(NSObject*)assignParams:(NSObject*)viewController params:(NSDictionary*)params{
    for (id key in [params keyEnumerator]) {
        if([viewController respondsToSelector:NSSelectorFromString(key)]){
            [viewController setValue:[ params valueForKey:key] forKeyPath:key];
        }
        else{
            NSLog(@"not found key %@ in %@" ,key ,NSStringFromClass( viewController.class));
        }
    }
    return viewController;
}



#pragma with nib

-(UIViewController*)pushViewController:(NSString*)className withNib:(NSString*)nibName animated:(BOOL)animated{
    UIViewController *viewController = [self createViewController:className withNib:nibName];
    if(viewController){
        [self pushViewController:viewController animated:animated];
    }
    return viewController;
}

-(UIViewController*)pushViewController:(NSString*)className withNib:(NSString*)nibName animated:(BOOL)animated completion:(void (^)(void))completion{
    UIViewController *viewController = [self createViewController:className withNib:nibName];
    if(viewController){
        [self pushViewController:viewController animated:animated completion:completion];
    }
    return viewController;
}




-(UIViewController*)presentViewController:(NSString*)className withNib:(NSString*)nibName animated:(BOOL)animated completion:(void (^)(void))completion{
    
    UIViewController *viewController = [self createViewController:className withNib:nibName];
    if(viewController){
        [self presentViewController:viewController animated:animated completion:completion];
        
    }
    return viewController;
    
}

#pragma with story board

-(UIViewController*)pushViewController:(NSString*)identifier withStoryboard:(NSString*)storyboardName animated:(BOOL)animated{
    UIViewController *viewController = [self createViewController:identifier withStoryboard:storyboardName];
    if(viewController){
        [self pushViewController:viewController animated:animated];
    }
    return viewController;
}

-(UIViewController*)pushViewController:(NSString*)identifier withStoryboard:(NSString*)storyboardName animated:(BOOL)animated completion:(void (^)(void))completion{
    UIViewController *viewController = [self createViewController:identifier withStoryboard:storyboardName];
    if(viewController){
        [self pushViewController:viewController animated:animated completion:completion];
    }
    return viewController;
}


-(UIViewController*)presentViewController:(NSString*)identifier withStoryboard:(NSString*)storyboardName animated:(BOOL)animated completion:(void (^)(void))completion{
    
    UIViewController *viewController = [self createViewController:identifier withStoryboard:storyboardName];
    if(viewController){
        [self presentViewController:viewController animated:animated completion:completion];
        
    }
    return viewController;
    
}

#pragma with parametes




-(UIViewController*)pushViewController:(NSString*)className withNib:(NSString*)nibName withParameters:(NSDictionary*)params animated:(BOOL)animated{
    UIViewController *viewController = [self createViewController:className withNib:nibName withParameters:params];
    if(viewController){
        [self pushViewController:viewController animated:animated];
    }
    return viewController;
}

-(UIViewController*)pushViewController:(NSString*)className withNib:(NSString*)nibName withParameters:(NSDictionary*)params animated:(BOOL)animated completion:(void (^)(void))completion{
    UIViewController *viewController = [self createViewController:className withNib:nibName withParameters:params];
    if(viewController){
        [self pushViewController:viewController animated:animated completion:completion];
    }
    return viewController;
}




-(UIViewController*)presentViewController:(NSString*)className withNib:(NSString*)nibName withParameters:(NSDictionary*)params animated:(BOOL)animated completion:(void (^)(void))completion{
    
    UIViewController *viewController = [self createViewController:className withNib:nibName withParameters:params];
    if(viewController){
        [self presentViewController:viewController animated:animated completion:completion];
        
    }
    return viewController;
    
}


-(UIViewController*)pushViewController:(NSString*)identifier withStoryboard:(NSString*)storyboardName withParameters:(NSDictionary*)params animated:(BOOL)animated{
    UIViewController *viewController = [self createViewController:identifier withStoryboard:storyboardName withParameters:params];
    if(viewController){
        [self pushViewController:viewController animated:animated];
    }
    return viewController;
}

-(UIViewController*)pushViewController:(NSString*)identifier withStoryboard:(NSString*)storyboardName withParameters:(NSDictionary*)params animated:(BOOL)animated completion:(void (^)(void))completion{
    UIViewController *viewController = [self createViewController:identifier withStoryboard:storyboardName withParameters:params];
    if(viewController){
        [self pushViewController:viewController animated:animated completion:completion];
    }
    return viewController;
}


-(UIViewController*)presentViewController:(NSString*)identifier withStoryboard:(NSString*)storyboardName withParameters:(NSDictionary*)params animated:(BOOL)animated completion:(void (^)(void))completion{
    
    UIViewController *viewController = [self createViewController:identifier withStoryboard:storyboardName withParameters:params];
    if(viewController){
        [self presentViewController:viewController animated:animated completion:completion];
        
    }
    return viewController;
    
}

#pragma push and present view


-(void)pushViewController:(UIViewController*)viewController animated:(BOOL)animated{
    UINavigationController* navigationViewController = [self currentNavigationController];
    
    NSAssert(navigationViewController, @"get currentnavigationviewcontroller");
    
    
    [navigationViewController pushViewController:viewController animated:animated];
    
}


-(void)pushViewController:(UIViewController*)viewController animated:(BOOL)animated completion:(void (^)(void))completion{
    UINavigationController* navigationViewController = [self currentNavigationController];
    
    NSAssert(navigationViewController, @"get currentnavigationviewcontroller");
    
    // save navigation delegate
    self.navigationDelegateCompletion = completion;
    
    if(navigationViewController.delegate){
        self.navigationDelegate = navigationViewController.delegate;
    }
    
    navigationViewController.delegate = self;
    
    [navigationViewController pushViewController:viewController animated:animated];
    
}


-(void)presentViewController:(UIViewController*)viewController animated:(BOOL)animated completion:(void (^)(void))completion{
    
    UIViewController * currentViewController = [self currentViewController];
    NSAssert(currentViewController, @"get currentviewcontroller");
    [currentViewController presentViewController:viewController animated:animated completion:completion];
    
}




#pragma navigation controller delegate

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    
    if(self.navigationDelegateCompletion){
        self.navigationDelegateCompletion();
        self.navigationDelegateCompletion = nil;
    }
    [self.navigationDelegate navigationController:navigationController didShowViewController:viewController animated:animated];
    if(self.navigationDelegate){
        navigationController.delegate = self.navigationDelegate;
        self.navigationDelegate = nil;
    }
    else{
        navigationController.delegate = nil;
    }
    
}







@end
