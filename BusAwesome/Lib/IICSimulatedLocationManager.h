//
//  IICSimulatedLocationManager.h
//  BusAwesome
//
//  Created by Gilad Goldberg on 11/3/13.
//  Copyright (c) 2013 Gilad Goldberg. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

/*
 
 HOW TO USE THIS:
 
 This class's initWithKML expects as "kmlFile" the name of the kml file resource (WITHOUT the .kml extension).
 The KML file should contain ONE linestring (preferrably exported from Google Earth). The IICSimulatedLocationManager
 will then fire each coordinate in the LineString one by one in a one second interval.
 
 Enjoy!
 */

@interface IICSimulatedLocationManager : CLLocationManager

- (id) initWithKML:(NSString *)kmlFile;

@end
g