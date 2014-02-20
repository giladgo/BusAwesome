//
//  TripHistory.h
//  BusAwesome
//
//  Created by Gilad Goldberg on 2/20/14.
//  Copyright (c) 2014 Gilad Goldberg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface BUSTripHistory : NSManagedObject

@property (nonatomic, retain) NSString * tripId;
@property (nonatomic, retain) NSDate * hitTime;
@property (nonatomic, retain) NSString * routeName;
@property (nonatomic, retain) NSString * directionDescription;

@end
