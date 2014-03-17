//
//  MYRoutesTests.m
//  MYRoutesTests
//
//  Created by masafumi yoshida on 2014/03/15.
//  Copyright (c) 2014年 masafumi yoshida. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MYRoutes.h"
@interface MYRoutesTests : XCTestCase

@end

@implementation MYRoutesTests

- (void)setUp
{
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testConvertToken
{
    MYGuidPost *guidPost = [[MYGuidPost alloc] init];
    
    NSDictionary *routeToken = [guidPost convertToken:@"hogehoge"];
    XCTAssert([[routeToken objectForKey:@"path"] isEqualToString: @"hogehoge"], @"hoge");
    XCTAssert([[routeToken objectForKey:@"type"] isEqualToString: @"match"], @"fuga");
    
    
    routeToken = [guidPost convertToken:@":hoge"];
    XCTAssert([[routeToken objectForKey:@"path"] isEqualToString: @"([^\\/]+)"], @"hoge");
    XCTAssert([[routeToken objectForKey:@"type"] isEqualToString: @"param"], @"fuga");
    XCTAssert([[routeToken objectForKey:@"name"] isEqualToString: @"hoge"], @"fuga");
    
}

- (void)testInit
{
    MYGuidPost *route = [[MYGuidPost alloc] initWithConfig:@"/hoge/fuga/:hoge" destination:@{@"xib":@"hoge"}];
    
    
    NSDictionary *routeToken = [route.tokens objectAtIndex:0];
    XCTAssert([[routeToken objectForKey:@"path"] isEqualToString: @"hoge"], @"hoge");
    XCTAssert([[routeToken objectForKey:@"type"] isEqualToString: @"match"], @"fuga");
    
    routeToken = [route.tokens objectAtIndex:1];
    XCTAssert([[routeToken objectForKey:@"path"] isEqualToString: @"fuga"], @"hoge");
    XCTAssert([[routeToken objectForKey:@"type"] isEqualToString: @"match"], @"fuga");
   
    routeToken = [route.tokens objectAtIndex:2];
    XCTAssert([[routeToken objectForKey:@"path"] isEqualToString: @"([^\\/]+)"], @"hoge");
    XCTAssert([[routeToken objectForKey:@"type"] isEqualToString: @"param"], @"fuga");
    XCTAssert([[routeToken objectForKey:@"name"] isEqualToString: @"hoge"], @"fuga");
    
    XCTAssert([route.path isEqualToString: @"/hoge/fuga/([^\\/]+)"], @"hoge");
    
}


- (void)testIsMatch
{
    MYGuidPost *guidPost = [[MYGuidPost alloc] initWithConfig:@"/hoge/fuga/:hoge" destination:@{@"xib":@"hoge"}];
   
    NSURL *url =  [NSURL URLWithString:@"/hoge/fuga/fuga"];
    XCTAssert([guidPost isMatch:url ], @"hoge");
    
    url =  [NSURL URLWithString:@"/hoge/fuga/"];
    XCTAssert(![guidPost isMatch:url], @"hoge");
    
    
    guidPost = [[MYGuidPost alloc] initWithConfig:@"/blog/:id/:action" destination:@{@"xib":@"hoge"}];
    url =  [NSURL URLWithString:@"/blog/1/show"];
    XCTAssert([guidPost isMatch: url], @"hoge");
    
}

- (void)testCaptureParam
{
    MYGuidPost *guidPost = [[MYGuidPost alloc] initWithConfig:@"/hoge/fuga/:hoge" destination:@{@"xib":@"hoge"}];
    
    NSURL *url =  [NSURL URLWithString:@"/hoge/fuga/fuga"];
    NSDictionary *params = [guidPost captureParams:url];
 
    XCTAssert([[params objectForKey:@"hoge"] isEqualToString:@"fuga"], @"hoge");
    
    url =  [NSURL URLWithString:@"/hoge/fuga/"];
    XCTAssert(![guidPost captureParams:  url], @"hoge");
    

    
    guidPost = [[MYGuidPost alloc] initWithConfig:@"/blog/:id/:action" destination:@{@"xib":@"hoge"}];
   
    url =  [NSURL URLWithString:@"/blog/1/show?category_id=2"];
    params = [guidPost captureParams:url ];
    XCTAssert([[params objectForKey:@"id"] isEqualToString:@"1"], @"hoge");
    XCTAssert([[params objectForKey:@"action"] isEqualToString:@"show"], @"hoge");
    XCTAssert([[params objectForKey:@"categoryId"] isEqualToString:@"2"], @"hoge");
    
    
    guidPost = [[MYGuidPost alloc] initWithConfig:@"/blog/:id/:action" destination:@{@"xib":@"hoge"}];
    
    url =  [NSURL URLWithString:@"myroutes://blog/1/show?category_id=2"];
    params = [guidPost captureParams:url ];
    XCTAssert([[params objectForKey:@"id"] isEqualToString:@"1"], @"hoge");
    XCTAssert([[params objectForKey:@"action"] isEqualToString:@"show"], @"hoge");
    XCTAssert([[params objectForKey:@"categoryId"] isEqualToString:@"2"], @"hoge");
    
}

- (void)testLoadConfig
{
    [[MYRoutes shared] loadRouteConfig:@[
        @[@"/hoge/:id" , @{@"nib":@"hoge",@"class":@"fuga"}],
        @[@"/hoge/fuga/:id" , @{@"storyboard":@"hoge",@"identifier":@"fuga"}],
        @[@"/hoge/fuga/:hoge" , @{@"nib":@"hoge",@"class":@"fuga",@"type":@"present"}],
        @[@"/hoge/fuga/:hoge" , @{@"storyboard":@"hoge",@"identifier":@"fuga",@"animated":[NSNumber numberWithBool:NO]}]
    ]];
    
    XCTAssert([MYRoutes shared].routes.count == 4, @"hoge");
   
    
}

- (void)testDispatch
{
    [[MYRoutes shared] loadRouteConfig:@[
                                         @[@"/hoge/:id" , @{@"nib":@"hoge",@"class":@"fuga"}],
                                         @[@"/hoge/fuga/:id" , @{@"storyboard":@"hoge",@"identifier":@"fuga"}],
                                         @[@"/hoge/fuga/:hoge" , @{@"nib":@"hoge",@"class":@"fuga",@"type":@"present"}],
                                         @[@"/hoge/fuga/:hoge" , @{@"storyboard":@"hoge",@"identifier":@"fuga",@"animated":[NSNumber numberWithBool:NO]}]
                                         ]];
    
    
    XCTAssert([MYRoutes shared].routes.count == 4, @"hoge");
    
    
}

@end
