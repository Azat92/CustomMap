//
//  CMMapView.h
//  CustomMap
//
//  Created by Azat Almeev on 10.04.14.
//  Copyright (c) 2014 Azat Almeev. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CMMapView;

@protocol CMMapViewDelegate <NSObject>
- (void)mapView:(CMMapView *)mapView didUpdatedUserLocation:(NSString *)newLocation;
- (void)mapView:(CMMapView *)mapView didFailUpdateUserLocation:(NSString *)errorString;
@end

@interface CMMapView : UIView
@property (nonatomic, weak) id <CMMapViewDelegate> delegate;
- (void)moveToStartPosition;
- (void)searchByQuery:(NSString *)query;
@end
