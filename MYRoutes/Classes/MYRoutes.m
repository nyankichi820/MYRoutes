//
//  MYRouter.m
//  MYRouter
//
//  Created by masafumi yoshida on 2014/03/14.
//  Copyright (c) 2014年 masafumi yoshida. All rights reserved.
//

#import "MYRoutes.h"


@implementation MYGuidPost

-(id)initWithConfig:(NSString*) key destination:(NSDictionary*)destination{
    self = [self init];
    self.paramTokens = [NSMutableArray array];
    self.tokens = [NSMutableArray array];
    if(self){
        NSMutableString *path = [[NSMutableString alloc] init];
        NSArray *pathes = [[key substringFromIndex:1] componentsSeparatedByString:@"/"];
        for(NSString *token in pathes){
            NSDictionary *routeToken = [self convertToken:token];
            [path appendString:@"/"];
            [path appendString:[routeToken objectForKey:@"path"]];
        }
        self.path = path;
        self.destination = destination;
    }
    return self;
}


-(NSDictionary*)convertToken:(NSString*)token{
    NSDictionary *routeToken;
    if([token hasPrefix:@":"]){
        NSString *name =[token substringFromIndex:1];
        routeToken = @{@"path":@"([^\\/]+)",@"type":@"param",@"name":name};
        [self.paramTokens addObject:routeToken];
    }
    else{
        routeToken = @{@"path":token,@"type":@"match"};
    }
    [self.tokens addObject:routeToken];
    return routeToken;
}

-(BOOL)isMatch:(NSString*)urlString{
    NSError *error   = nil;
    NSRegularExpression *regexp =
    [NSRegularExpression regularExpressionWithPattern:self.path
                                              options:0
                                                error:&error];
    if (error != nil) {
        NSLog(@"%@", error);
    } else {
        
        NSTextCheckingResult *match =
        [regexp firstMatchInString:urlString options:0 range:NSMakeRange(0, urlString.length)];
        if(match.numberOfRanges == self.paramTokens.count + 1){
           return YES;
        }
        
    }
    return NO;
}

-(NSDictionary*)captureParams:(NSString*)urlString{
    NSError *error   = nil;
    NSRegularExpression *regexp =
    [NSRegularExpression regularExpressionWithPattern:self.path
                                              options:0
                                                error:&error];
    if (error != nil) {
        NSLog(@"%@", error);
    } else {
        
        NSTextCheckingResult *match =
        [regexp firstMatchInString:urlString options:0 range:NSMakeRange(0, urlString.length)];
        if(match.numberOfRanges == self.paramTokens.count + 1){
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            for(int i = 1 ; i<= self.paramTokens.count ;i++){
                NSString *matchValue =  [urlString substringWithRange:[match rangeAtIndex:i]];
                [params setValue:matchValue forKey:[[self.paramTokens objectAtIndex:i-1] objectForKey:@"name"]];
            }
            return params;
        }
        
    }
    return nil;
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

-(void)loadRouteConfig:(NSArray*)routeConfig{
    self.routes = [NSMutableArray array];
    for(NSArray *config in routeConfig){
        NSString *path = [config objectAtIndex:0];
        NSDictionary *destination = [config objectAtIndex:1];
        MYGuidPost *route = [[MYGuidPost alloc] initWithConfig:path destination:destination];
        [self.routes addObject:route];
    }
}

-(void)dispatch:(NSString*)urlString{
    NSURL *url = [NSURL URLWithString:urlString];
    
    // external apps
    if(url.scheme && ![self isSelfUrlSchema:urlString]){
        [self openURLWithString:urlString];
    }
    else{
        for(MYGuidPost *guildPost in self.routes){
            if([guildPost isMatch:urlString]){
                NSDictionary *param = [guildPost captureParams:urlString];
                [self dispatch:param destination:guildPost.destination];
                break;
            }
        }
    }
    NSLog(@"not found route");
}

-(void)dispatch:(NSDictionary*)params destination:(NSDictionary*)destination{
    NSString *type = @"push"; // default push
    NSNumber *animated = [NSNumber numberWithBool:YES]; // default push
    
    if([destination valueForKey:@"type"]){
        type = [destination valueForKey:@"type"];
    }
    if([destination valueForKey:@"animated"]){
        animated = [destination valueForKey:@"animated"];
    }
    
    if([destination valueForKey:@"storyboard"] && [destination valueForKey:@"identifier"] ){
        NSString *storyboardName = [destination valueForKey:@"storyboard"] ;
        NSString *identifier = [destination valueForKey:@"identifier"] ;
        if( [type isEqualToString:@"push"]){
            [self pushViewController:identifier withStoryboard:storyboardName withParameters:params  animated:[animated boolValue]];
        }
        else{
            [self presentViewController:identifier withStoryboard:storyboardName withParameters:params animated:[animated boolValue] completion:nil ];
        }
    }
    else if([destination valueForKey:@"nib"]){
        NSString *nibName = [destination valueForKey:@"nib"] ;
        NSString *className = [destination valueForKey:@"class"] ;
        if( [type isEqualToString:@"push"]){
            [self pushViewController:className withNib:nibName withParameters:params  animated:[animated boolValue]];
        }
        else{
            [self presentViewController:className withNib:nibName withParameters:params  animated:[animated boolValue] completion:nil];
        }
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
