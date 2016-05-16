//
//  Utilities.m
//  ForceManager_Test
//
//  Created by Vladimir Marinov on 16.05.16.
//  Copyright © 2016 Vladimir Marinov. All rights reserved.
//

#import "Utilities.h"

@implementation Utilities


+ (void)showErrorMessage:(NSString*)message withError:(NSError*)error withSender:(UIViewController*)sender{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *errorText = [NSString stringWithFormat:@"%@ with code: %ld", message, (long)error.code ];
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:message
                                                                       message:errorText
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        [alert addAction:defaultAction];
        [sender presentViewController:alert animated:YES completion:nil];
    });
}

+ (NSString *)getUuid{
    NSString *ident = nil;
    CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
    CFRelease(uuidRef);
    ident = [NSString stringWithString:(__bridge NSString *)uuidStringRef];
    CFRelease(uuidStringRef);
    return ident;
}
@end
