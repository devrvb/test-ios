//
//  ObjC.h
//  intelbras-integrador
//
//  Created by Nicholas Meschke on 11/27/17.
//  Copyright © 2018 Intelbras S/A. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ObjC : NSObject

+ (BOOL)catchException:(void(^)(void))tryBlock error:(__autoreleasing NSError **)error;

@end
