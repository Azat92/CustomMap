//
//  CMMapSource.h
//  CustomMap
//
//  Created by Azat Almeev on 10.04.14.
//  Copyright (c) 2014 Azat Almeev. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CMMapSource <NSObject>
- (CGSize)tileSize;
- (int)maxZoom;
- (UIImage *)tileForX:(int)x y:(int)y andZoom:(int)zoom completion:(void (^)(BOOL success))completion;
@end
