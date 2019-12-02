//
//  AppDelegate.h
//  W1
//
//  Created by sohan on 2/19/17.
//  Copyright © 2017 Squarebits pvt ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "KeychainItemWrapper.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "UtilityObject.h"
#import "ALSystem.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <ImageIO/ImageIO.h>
@import EventKit;

@interface AppDelegate : UIResponder <UIApplicationDelegate,CLLocationManagerDelegate,CBCentralManagerDelegate,AVAudioRecorderDelegate, AVAudioPlayerDelegate>
{
    NSMutableArray *contactList;
    
    NSArray *imageArray;
    NSMutableArray *mutableArray;
    
    BOOL isImagesUploading;
}

@property BOOL isOCR_inProgress;

@property (strong, nonatomic) UIWindow *window;

@property(strong,nonatomic)CLLocationManager *locationManager;
@property(strong,nonatomic) CLLocation *CurrentUserLocation;

@property(strong,nonatomic)NSString *strLATITUDE;
@property(strong,nonatomic)NSString *strLONGITUDE;

@property(strong,nonatomic)NSString *strDEVICE_ID;
@property(strong,nonatomic)NSString *strDEVICE_OS;
@property(strong,nonatomic)NSString *strDEVICE_TYPE;
@property(strong,nonatomic)NSString *strDEVICE_OS_VERSION;
@property(strong,nonatomic)NSString *strDEVICE_TOKEN;

@property(strong,nonatomic)CBCentralManager *bluetoothManager;

@property(strong,nonatomic) UtilityObject *utility;
@property BOOL bluetoothEnabled;
@property(strong,nonatomic) NSDateFormatter *formatter;

-(BOOL)isInternetAvailable;

@property (nonatomic, strong) EKEventStore *eventStore;

// Default calendar associated with the above event store
@property (nonatomic, strong) EKCalendar *defaultCalendar;

@property (nonatomic, strong)AVAudioRecorder *audioRecorder;

@property int counterForRecord;
@property (nonatomic, strong)AVAudioSession *session;

@property(strong,nonatomic)NSArray *assets;

@property(strong,nonatomic)NSMutableArray *aryImageIdentifiers;

@property BOOL isScreenRecording;
-(void)GetcurrentLocation;

-(void)checkContactPermission;
-(void)requestCalendarAccess;
-(void)setupAudisSession;
@end

