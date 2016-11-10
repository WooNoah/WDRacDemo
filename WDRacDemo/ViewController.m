//
//  ViewController.m
//  WDRacDemo
//
//  Created by tb on 16/11/10.
//  Copyright © 2016年 com.tb. All rights reserved.
//

#import "ViewController.h"
#import "WDLoginUnit.h"

#import <ReactiveCocoa/ReactiveCocoa.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userNameTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UILabel *loginFailLabel;

@property (nonatomic,strong) WDLoginUnit *logService;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    //Textfield Config
    self.loginFailLabel.hidden = YES;
    
    RACSignal *isValidUserNameSignal =
    [self.userNameTF.rac_textSignal
     map:^id(NSString *value) {
         return @([self isValidUserName:value]);
     }];
    
    RACSignal *isValidPasswordSignal =
    [self.passwordTF.rac_textSignal
     map:^id(NSString *value) {
         return @([self isValidPassword:value]);
     }];
    
#if 1
    RAC(self.userNameTF,backgroundColor) =
    [isValidUserNameSignal
     map:^id(NSNumber *value) {
         return [value integerValue] ? [UIColor clearColor] : [UIColor yellowColor];
     }];
    
    RAC(self.passwordTF, backgroundColor) =
    [isValidPasswordSignal
     map:^id(NSNumber *value) {
         return [value boolValue] ? [UIColor clearColor] : [UIColor yellowColor];
     }];
#else
    //The code below has the same effect
    [[isValidUserNameSignal
      map:^id(NSNumber *value) {
          return [value boolValue] ? [UIColor clearColor] : [UIColor redColor];
      }]
     subscribeNext:^(UIColor *x) {
         self.userNameTF.backgroundColor = x;
     }];
    
    [[isValidPasswordSignal
      map:^id(NSNumber *value) {
          return [value boolValue] ? [UIColor clearColor] : [UIColor redColor];
      }]
     subscribeNext:^(UIColor *x) {
         self.passwordTF.backgroundColor = x;
     }];
    
#endif
    
    //button Config
    [[RACSignal
      combineLatest:@[isValidUserNameSignal,isValidPasswordSignal]
      reduce:^id(NSNumber *boolUserName, NSNumber *boolPassword){
          return @([boolUserName boolValue] && [boolPassword boolValue]);
      }]
     subscribeNext:^(NSNumber *x) {
         self.loginButton.enabled = [x boolValue];
     }];
    
    
    [[[[self.loginButton
        rac_signalForControlEvents:UIControlEventTouchUpInside]
       doNext:^(UIButton *x) {
           //Log the object 'x', Let's check it whether it belongs to class UIButton
           NSLog(@"%@",x);
           x.enabled = NO;
           self.loginFailLabel.hidden = YES;
       }]
      flattenMap:^RACStream *(id value) {
          //Because the pass object belongs to class UIButton,
          //it's a object not a signal, therefore we perfer to use flattenMap rather than map.
          //(Map can only used for the situation which the pass thing belongs to the kind RACSignal)
          return [self loginInService];
      }]
     subscribeNext:^(NSNumber *x) {
         //the pass thing should be a object belongs to Class BOOL, however we should conver bool value to object, thus  we use NSNumber
         NSLog(@"button click");
         NSLog(@"%@",x ? @"success identity" : @"failure identity");
         BOOL success = [x boolValue];
         self.loginFailLabel.hidden = success;
         if (success) {
             [self performSegueWithIdentifier:@"signInSuccess" sender:nil];
         }
     }];
    
}

#pragma mark - Lazy Method
- (WDLoginUnit *)logService {
    if (!_logService) {
        _logService = [[WDLoginUnit alloc]init];
    }
    return _logService;
}


#pragma mark - Private Method
- (RACSignal *)loginInService {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self.logService signInWithUsername:self.userNameTF.text password:self.passwordTF.text complete:^(BOOL whether) {
            [subscriber sendNext:@(whether)];
            [subscriber sendCompleted];
        }];
#warning -
        //If this sentence is not annotationed, We can receive the signal 'nil' immediately when we click the button.
        //        [subscriber sendNext:nil];
        return nil;
    }];
}

- (BOOL)isValidUserName:(NSString *)name {
    return name.length >= 6;
}

- (BOOL)isValidPassword:(NSString *)password {
    return password.length >= 6 && password.length <= 16;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
