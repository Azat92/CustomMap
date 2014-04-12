//
//  CMLocationGetter.h
//  CustomMap
//
//  Created by Azat Almeev on 11.04.14.
//  Copyright (c) 2014 Azat Almeev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMLocationGetter : NSObject
+ (void)subscribeToUpdateUserLocation:(void(^)(CLLocationCoordinate2D coord, NSString *message))completion;
@end
