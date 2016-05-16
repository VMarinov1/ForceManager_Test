//
//  Utilities.h
//  ForceManager_Test
//
//  Created by Vladimir Marinov on 16.05.16.
//  Copyright © 2016 Vladimir Marinov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Utilities: NSObject

+ (void)showErrorMessage:(NSString*)message withError:(NSError*)error withSender:(UIViewController*)sender;
+ (NSString *)getUuid;

@end
