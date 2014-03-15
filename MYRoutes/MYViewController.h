//
//  MYViewController.h
//  MYRouter
//
//  Created by masafumi yoshida on 2014/03/14.
//  Copyright (c) 2014年 masafumi yoshida. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MYViewController : UIViewController<UINavigationControllerDelegate>
@property(nonatomic,strong) NSString* message;
@property(nonatomic,strong) IBOutlet UITextField *messageTexfield;
@property(nonatomic,strong) IBOutlet UILabel *messageLabel;
@end
