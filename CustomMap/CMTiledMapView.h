//
//  CMMapView.h
//  CustomMap
//
//  Created by Azat Almeev on 07.04.14.
//  Copyright (c) 2014 Azat Almeev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMMapSource.h"

@interface CMTiledMapView : UIView
- (id)initWithFrame:(CGRect)frame tilesSource:(id <CMMapSource>)mapSource;
@end
