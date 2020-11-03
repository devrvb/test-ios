//
//  ObjC.m
//  intelbras-integrador
//
//  Created by Nicholas Meschke on 11/27/17.
//  Copyright © 2018 Intelbras S/A. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ObjC.h"

@implementation ObjC

+ (BOOL)catchException:(void(^)(void))tryBlock error:(__autoreleasing NSError **)error {
    if (!tryBlock) { return NO; }
    @try {
        tryBlock();
        return YES;
    }
    @catch (NSException *exception) {
        NSDictionary* info = @{
                               NSLocalizedDescriptionKey: exception.reason
                               };
        *error = [[NSError alloc] initWithDomain:exception.name code:0 userInfo:info];
        return NO;
    }
}

@end
