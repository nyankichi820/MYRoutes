//
//  MYRouter.h
//  MYRouter
//
//  Created by masafumi yoshida on 2014/03/14.
//  Copyright (c) 2014年 masafumi yoshida. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void ((^MYRoutesNavigationCompleteBlocks)(void));

@interface MYRoutes : NSObject<UINavigationControllerDelegate>
+ (MYRoutes *) shared;
@property(nonatomic,strong) MYRoutesNavigationCompleteBlocks navigationDelegateCompletion;
@property(nonatomic,weak) id<UINavigationControllerDelegate> navigationDelegate;
@property(nonatomic) BOOL canDynamicRouting;
@property(nonatomic,strong) NSMutableArray *routes;
@property(nonatomic,weak) UIView *currentView;

-(void)openURLString:(NSString*)urlString;


-(UINavigationController*)currentNavigationController;

-(UIViewController*)currentViewController;

-(UIView*)createView:(NSObject*)owner withNib:(NSString*)nibName;


-(UIView*)createView:(NSObject*)owner withNib:(NSString*)nibName withParameters:(NSDictionary*)params;


-(UIViewController*)createViewController:(NSString*)identifier withStoryboard:(NSString*)storyboardName;

-(UIViewController*)createViewController:(NSString*)className withNib:(NSString*)nibName;


-(NSObject*)assignParams:(NSObject*)object params:(NSDictionary*)params;


-(UIViewController*)pushViewController:(NSString*)className withNib:(NSString*)nibName animated:(BOOL)animated;

-(UIViewController*)pushViewController:(NSString*)className withNib:(NSString*)nibName animated:(BOOL)animated completion:(void (^)(void))completion;

-(UIViewController*)presentViewController:(NSString*)className withNib:(NSString*)nibName animated:(BOOL)animated completion:(void (^)(void))completion;

-(UIViewController*)pushViewController:(NSString*)identifier withStoryboard:(NSString*)storyboardName animated:(BOOL)animated completion:(void (^)(void))completion;

-(UIViewController*)pushViewController:(NSString*)identifier withStoryboard:(NSString*)storyboardName animated:(BOOL)animated;

-(void)pushViewController:(UIViewController*)viewController animated:(BOOL)animated completion:(void (^)(void))completion;

-(UIViewController*)presentViewController:(NSString*)identifier withStoryboard:(NSString*)storyboardName animated:(BOOL)animated completion:(void (^)(void))completion;




-(UIViewController*)pushViewController:(NSString*)className withNib:(NSString*)nibName withParameters:(NSDictionary*)params animated:(BOOL)animated;

-(UIViewController*)pushViewController:(NSString*)className withNib:(NSString*)nibName withParameters:(NSDictionary*)params animated:(BOOL)animated completion:(void (^)(void))completion;



-(UIViewController*)presentViewController:(NSString*)className withNib:(NSString*)nibName withParameters:(NSDictionary*)params animated:(BOOL)animated completion:(void (^)(void))completion;

-(UIViewController*)pushViewController:(NSString*)identifier withStoryboard:(NSString*)storyboardName withParameters:(NSDictionary*)params animated:(BOOL)animated;

-(UIViewController*)pushViewController:(NSString*)identifier withStoryboard:(NSString*)storyboardName withParameters:(NSDictionary*)params animated:(BOOL)animated completion:(void (^)(void))completion;

-(UIViewController*)presentViewController:(NSString*)identifier withStoryboard:(NSString*)storyboardName withParameters:(NSDictionary*)params animated:(BOOL)animated completion:(void (^)(void))completion;


-(void)pushViewController:(UIViewController*)viewController animated:(BOOL)animated;

-(void)presentViewController:(UIViewController*)viewController animated:(BOOL)animated completion:(void (^)(void))completion;
@end
