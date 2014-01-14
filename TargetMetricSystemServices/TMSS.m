//
//  TMSS.m
//  TargetMetricSystemServices
//
//  Created by Yeshwanth.Gowda on 12/10/13.
//  Copyright (c) 2013 Target Corporation. All rights reserved.
//

#import "TMSS.h"
#import "SSZipArchive.h"

#define WIFI_INFO_CONST 0
#define SYSTEM_INFO_CONST 1
#define BATTERY_INFO_CONST 2
#define LOCATION_INFO_CONST 3

//Log Timer
#define LOG_TIMER 60.0

//Server URl
#define kFileUploadScriptURL @"http://166.78.124.21/upload/upload.php"

@interface TMSS () {
    // Private
    //Temporary string for checking the status
    NSMutableString *tmpBatteryReading;
    NSMutableString *tmpSSIDReading;
    BOOL START_LOGGING;
}

// Get all System Information (All Methods)
//- (NSDictionary *)getAllSystemInformation;

@end

@implementation TMSS

@dynamic systemsUptime, deviceModel, deviceName, systemName, systemsVersion, systemDeviceTypeNotFormatted, systemDeviceTypeFormatted, screenWidth, screenHeight, screenBrightness, multitaskingEnabled, proximitySensorEnabled, debuggerAttached, pluggedIn, jailbroken, numberProcessors, numberActiveProcessors, processorSpeed, processorBusSpeed, accessoriesAttached, headphonesAttached, numberAttachedAccessories, nameAttachedAccessories,locationTimestamp,locationLatitude,locationLongitude,locationAltitude,locationHorizontal,locationVertical,locationCourse,locationSpeed,carrierName, carrierCountry, carrierMobileCountryCode, carrierISOCountryCode, carrierMobileNetworkCode, carrierAllowsVOIP, batteryLevel, charging, fullyCharged, currentSSID,currentIPAddress, currentMACAddress, externalIPAddress, cellIPAddress, cellMACAddress, cellNetmaskAddress, cellBroadcastAddress, wiFiIPAddress, wiFiMACAddress, wiFiNetmaskAddress, wiFiBroadcastAddress, connectedToWiFi, connectedToCellNetwork, diskSpace, freeDiskSpaceinRaw, freeDiskSpaceinPercent, usedDiskSpaceinRaw, usedDiskSpaceinPercent, longDiskSpace, longFreeDiskSpace, totalMemory, freeMemoryinRaw, freeMemoryinPercent, usedMemoryinRaw, usedMemoryinPercent, activeMemoryinRaw, activeMemoryinPercent, inactiveMemoryinRaw, inactiveMemoryinPercent, wiredMemoryinRaw, wiredMemoryinPercent, purgableMemoryinRaw, purgableMemoryinPercent, deviceOrientation, country,language, timeZoneSS, currency, applicationVersion, uniqueID, deviceSignature, cfuuid,CLController,appStartTime,appStopTime,mutableWifiInfo,mutableStaticInfo,mutableLocationInfo,mutableBatteryInfo,mutablePayload,mutableAppDuration,mutableAppLogInfo;

// Singleton
+ (id)sharedServices {
    static TMSS *sharedSystemServices = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSystemServices = [[self alloc] init];
    });
    return sharedSystemServices;
}

// Initialisation
- (id)init {
    if (self = [super init]) {
        NSLog(@"Loading init");
        START_LOGGING = false;
        [self initCoreLocationController];
        [NSTimer scheduledTimerWithTimeInterval: LOG_TIMER target: self
                                       selector: @selector(callAfterSixtySecond:) userInfo: nil repeats: YES];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillTerminate:)
                                                     name:UIApplicationDidEnterBackgroundNotification object:[UIApplication sharedApplication]];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillTerminate:)
                                                     name:UIApplicationWillTerminateNotification object:[UIApplication sharedApplication]];
    }

    return self;
}

- (void) initCoreLocationController{
    NSLog(@"Core Location Initiated");
    CLController = [[TMSSCoreLocationController alloc] init];
    CLController.delegate = self;
    [CLController.locMgr startUpdatingLocation];
    appStartTime = [self stringFormatedTimeStamp];
    [self storingMutableStringValue : SYSTEM_INFO_CONST  : [self getAllStaticSystemInformation]];
    NSLog(@"Waiting to log system generated info...please wait(approx every 60 seconds)");
}

- (void)locationUpdate:(CLLocation *)location {
    locationTimestamp = [NSDateFormatter localizedStringFromDate:location.timestamp
                                                       dateStyle:NSDateFormatterShortStyle
                                                       timeStyle:NSDateFormatterFullStyle];
    locationLatitude= [NSString stringWithFormat:@"%f", location.coordinate.latitude];
    locationLongitude = [NSString stringWithFormat:@"%f", location.coordinate.longitude];
    locationHorizontal= [NSString stringWithFormat:@"%f", location.horizontalAccuracy];
    locationVertical= [NSString stringWithFormat:@"%f", location.verticalAccuracy];
    locationCourse= [NSString stringWithFormat:@"%f", location.course];
    locationSpeed = [NSString stringWithFormat:@"%f", location.speed];
    locationAltitude = [NSString stringWithFormat:@"%f", location.altitude];
}

- (void)locationError:(NSError *)error {
    NSLog(@"Error Location Tracker :%@",error);
}

- (void) callAfterSixtySecond:(NSTimer*) t
{
    NSLog(@"Logging Started");
    START_LOGGING = true;
    [self storingMutableStringValue : WIFI_INFO_CONST    : [self getAllWifiInformation]];
    [self storingMutableStringValue : BATTERY_INFO_CONST : [self getAllBatteryInformation]];
    [self storingMutableStringValue : LOCATION_INFO_CONST: [self getAllLocationInformation]];
}
//method to generate an appended string
- (void) storingMutableStringValue : (NSInteger )CnstNumber : (NSDictionary *) info{
    switch (CnstNumber) {
        case 0:
            if([mutableWifiInfo length] <= 0 ){
                mutableWifiInfo = [NSMutableString stringWithFormat:@"%@",[self StringToJson : info]];
                tmpSSIDReading = [NSMutableString stringWithFormat:@"%@",[self currentSSID]];
            }
            else{
                //Logging only if the wifi ssid changes
                if(![tmpSSIDReading isEqualToString: [self currentSSID]])
                {
                    tmpSSIDReading = [NSMutableString stringWithFormat:@"%@",[self currentSSID]];
                    [mutableWifiInfo appendString:[NSString stringWithFormat:@","]];
                    [mutableWifiInfo appendString:[NSString stringWithFormat:@"%@",[self StringToJson : info]]];
                }else{
                    NSLog(@"No New Changes in wifi ssid");
                }
            }
            NSLog(@"Wifi Info Logged");
            break;

        case 1:
            if([mutableStaticInfo length] <= 0 ){
                mutableStaticInfo = [NSMutableString stringWithFormat:@"%@",[self StringToJson : info]];
            }
            else{
                [mutableStaticInfo appendString:[NSString stringWithFormat:@","]];
                [mutableStaticInfo appendString:[NSString stringWithFormat:@"%@",[self StringToJson : info]]];
            }
            NSLog(@"System Static Info Logged");
            break;

        case 2:
            NSLog(@"Switch :2");
            if([mutableBatteryInfo length] <= 0 ){
                mutableBatteryInfo = [NSMutableString stringWithFormat:@"%@",[self StringToJson : info]];
                tmpBatteryReading = [NSMutableString stringWithFormat:@"%f", [self batteryLevel]];
            }
            else{
                if(![tmpBatteryReading isEqualToString: [NSMutableString stringWithFormat:@"%f", [self batteryLevel]]])
                {
                    tmpBatteryReading = [NSMutableString stringWithFormat:@"%f", [self batteryLevel]];
                    [mutableBatteryInfo appendString:[NSString stringWithFormat:@","]];
                    [mutableBatteryInfo appendString:[NSString stringWithFormat:@"%@",[self StringToJson : info]]];

                }
                else{
                    NSLog(@"No New Changes in battery");
                }
            }
            NSLog(@"Battery Info Logged");
            break;

        case 3:
            if([mutableLocationInfo length] <= 0 ){
                mutableLocationInfo = [NSMutableString stringWithFormat:@"%@",[self StringToJson : info]];
            }
            else{
                [mutableLocationInfo appendString:[NSString stringWithFormat:@","]];
                [mutableLocationInfo appendString:[NSString stringWithFormat:@"%@",[self StringToJson : info]]];
            }
            NSLog(@"Location Info Logged");
            break;

        default:
            break;
    }
}

//Creating a formated TimeStamp for application start and stop
- (NSString *) stringFormatedTimeStamp{
    return [NSDateFormatter localizedStringFromDate:[NSDate date]
                                          dateStyle:NSDateFormatterShortStyle
                                          timeStyle:NSDateFormatterFullStyle];
}

//Creating a timestamp to generate a unique identifier to name the json file
- (NSString *)unixTimeStamp{
    NSString *timestamp = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
    return timestamp;
}

//Application Logger
- (void)log:(NSString *) strEvent : (NSString *)strPayload{
    NSString *strEventPayload;
    strEventPayload = [NSString stringWithFormat:@"\"%@\":\"%@\"",strEvent,strPayload];

    if([mutableAppLogInfo length] <= 0 ){
        mutableAppLogInfo = [NSMutableString stringWithFormat:@"%@",strEventPayload];
    }
    else{
        [mutableAppLogInfo appendString:[NSString stringWithFormat:@","]];
        [mutableAppLogInfo appendString:[NSString stringWithFormat:@"%@",strEventPayload]];
    }
}

//Method writes a string to a json file
-(void) writeToJsonFile:(NSString *) jsonStringToFile :(NSString *) fileName {
    NSString *strValue = jsonStringToFile;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);//Getting the documents path
    NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
    NSString *filePath = [documentsPath stringByAppendingPathComponent:[fileName stringByAppendingString:@".json"]]; //Add the file name

    [strValue writeToFile:filePath atomically:YES]; //Write the file
    /*Should be removed after testing*/
    NSLog(@"%@",jsonStringToFile);
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsPath error:nil];
    NSPredicate *textFilePredicate = [NSPredicate predicateWithFormat:@"self ENDSWITH '.json'"];//searching for files with .json extension
    files = [files filteredArrayUsingPredicate:textFilePredicate];
    NSString *logZipPath = [documentsPath stringByAppendingPathComponent:[[self uniqueID] stringByAppendingString:@".zip"]];//Creating a gzip file or folder
    if ([[NSFileManager defaultManager] fileExistsAtPath:logZipPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:logZipPath error:nil];
    }
    NSMutableArray *inputFiles = [NSMutableArray array];
    for (NSString *file in files) {//creating a gzip folder for all files in documents directory
        [inputFiles addObject:[documentsPath stringByAppendingPathComponent:file]];
    }
    [SSZipArchive createZipFileAtPath:logZipPath withFilesAtPaths:inputFiles];//Creating the Archive
    //on success return from server
    if ([self sendFile:filePath URL:kFileUploadScriptURL FNAME:fileName]) {
        [self removeFiles : paths : documentsPath : @"zip"];//remove gzip/json file on successfull uploading of the file
        [self removeFiles : paths : documentsPath : @"json"];

    }else{
        NSLog(@"Error Uploading the File");
    }
}
//Method to remove files with path and specified extension
- (void) removeFiles : (NSArray *)paths : (NSString *)documentsDirectory : (NSString *)extension{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:documentsDirectory error:NULL];
    NSEnumerator *e = [contents objectEnumerator];
    NSString *filename;
    while ((filename = [e nextObject])) {
        if ([[filename pathExtension] isEqualToString:extension]) {
            [fileManager removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:filename] error:NULL];
        }
    }
}
//Method to upload the file to server using mutipart data(presently using only for single part)
- (BOOL)sendFile:(NSString *)filePath URL:(NSString *)urlString FNAME:(NSString *)fname
{
    BOOL SUCCESS;
    NSMutableData *body = [NSMutableData data];
    NSString *boundary;
    NSString *contentType;
    NSData *returnData;
    NSString *returnString;
    NSURLConnection *theConnection;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    boundary = @"---------------------------777777777777888888888999999999";    //boudary to separate multipart data
    contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"uploadedfile\"; filename=\"%@\"\r\n",[fname stringByAppendingString:@".json"]] dataUsingEncoding:NSUTF8StringEncoding]];//appending content-disposition with name and name to identify the multipart and provide a unique filename
    [body appendData:[[NSString stringWithFormat:@"Content-Type: application/json\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[NSData dataWithContentsOfFile:filePath]];//Appending the data from the file
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]]; //set request body
    [request setHTTPBody:body];//send the request (submit the form) and get the response
    returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    theConnection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (!(returnString == nil || returnString.length <= 0)) {//Checking if the connection was a success
        SUCCESS = true;
        NSLog(@"connection successful");
    }else{
        SUCCESS = false;
        NSLog(@"connection failure");
    }
    NSLog(@"%@", returnString);
    return SUCCESS;
}

//Method to encrypt the file using AES and Base64Encoding(Not Yet implemented)
- (void)encryptJsonFile :(NSString *)jsonStringToFile{
    NSString *password = @"password";
    // It does not work with UTF8
    NSString *str = @"";
    // Encrypt
    NSLog(@"encrypting string = %@",str);
    NSData *data = [jsonStringToFile dataUsingEncoding: NSASCIIStringEncoding];
    NSData *encryptedData = [data AESEncryptWithPassphrase:password];
    // If you need to send over internet, encode NSData -> Base64 encoded string
    [Base64 initialize];
    NSString *base64EncStr = [Base64 encode:encryptedData];
    NSLog(@"Base 64 encoded = %@",base64EncStr);
    // Then you can put that back like this
    NSData	*b64DecData = [Base64 decode:base64EncStr];
    // This should be same before encode -> decode base 64
    //NSData *decryptedData = [encryptedData AESDecryptWithPassphrase:password];
    NSData *decryptedData = [b64DecData AESDecryptWithPassphrase:password];
    NSString* decryptedStr = [[NSString alloc] initWithData:decryptedData encoding:NSASCIIStringEncoding];
    NSLog(@"decrypted string = %@",decryptedStr);
}

//Creating a json from string
- (NSString *)StringToJson:(NSString *) str {
    NSError *error;
    NSString *JSONString;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:str options:0 error:&error];
    if (!jsonData) {
        NSLog(@"JSON error: %@", error);
    } else {
        JSONString = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
    }
    return JSONString;
}

//Json [Object] Creator;
- (NSString *)jsonObjectCreator:(NSString *) strEvent : (NSString *)strPayload{
    NSString *retString = [NSString stringWithFormat:@"\"%@\":[%@]",strEvent,strPayload];
    return retString;
}
//Json {Array} Creator;
- (NSString *)jsonArrayCreator:(NSString *)strPayload{
    NSString *retString;
    if([strPayload length] <= 0 ){
        retString = [NSString stringWithFormat:@"{\"Error\":\"Nothing is being logged from application\"}"];
    }else{
        retString = [NSString stringWithFormat:@"{%@}",strPayload];
    }
    return retString;
}


// System Information

- (NSString *)systemsUptime {
    NSLog(@"systemsUptime");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"cell" object:nil];
    return [TMSSHardwareInfo systemUptime];
}

- (NSString *)deviceModel {
    return [TMSSHardwareInfo deviceModel];
}

- (NSString *)deviceName {
    return [TMSSHardwareInfo deviceName];
}

- (NSString *)systemName {
    return [TMSSHardwareInfo systemName];
}

- (NSString *)systemsVersion {
    return [TMSSHardwareInfo systemVersion];
}

- (NSString *)systemDeviceTypeNotFormatted {
    return [TMSSHardwareInfo systemDeviceTypeFormatted:NO];
}

- (NSString *)systemDeviceTypeFormatted {
    return [TMSSHardwareInfo systemDeviceTypeFormatted:YES];
}

- (NSInteger)screenWidth {
    return [TMSSHardwareInfo screenWidth];
}

- (NSInteger)screenHeight {
    return [TMSSHardwareInfo screenHeight];
}

- (float)screenBrightness {
    return [TMSSHardwareInfo screenBrightness];
}

- (BOOL)multitaskingEnabled {
    return [TMSSHardwareInfo multitaskingEnabled];
}

- (BOOL)proximitySensorEnabled {
    return [TMSSHardwareInfo proximitySensorEnabled];
}

- (BOOL)debuggerAttached {
    return [TMSSHardwareInfo debuggerAttached];
}

- (BOOL)pluggedIn {
    return [TMSSHardwareInfo pluggedIn];
}

- (int)jailbroken {
    return [TMSSJailbreakcheck jailbroken];
}

- (NSInteger)numberProcessors {
    return [TMSSProcessorInfo numberProcessors];
}

- (NSInteger)numberActiveProcessors {
    return [TMSSProcessorInfo numberActiveProcessors];
}

- (NSInteger)processorSpeed {
    return [TMSSProcessorInfo processorSpeed];
}

- (NSInteger)processorBusSpeed {
    return [TMSSProcessorInfo processorBusSpeed];
}

- (BOOL)accessoriesAttached {
    return [TMSSAccessoryInfo accessoriesAttached];
}

- (BOOL)headphonesAttached {
    return [TMSSAccessoryInfo headphonesAttached];
}

- (NSInteger)numberAttachedAccessories {
    return [TMSSAccessoryInfo
            numberAttachedAccessories];
}

- (NSString *)nameAttachedAccessories {
    return [TMSSAccessoryInfo nameAttachedAccessories];
}

- (NSString *)locationTimestamp{
    return locationTimestamp;
}

- (NSString *)locationLatitude{
    return locationLatitude;
}

- (NSString *)locationLongitude{
    return locationLongitude;
}

- (NSString *)locationAltitude{
    return locationAltitude;
}

- (NSString *)locationHorizontal{
    return locationHorizontal;
}

- (NSString *)locationVertical{
    return locationVertical;
}

- (NSString *)locationCourse{
    return  locationCourse;
}

- (NSString *)locationSpeed{
    return locationSpeed;
}

- (NSString *)carrierName {
    return [TMSSCarrierInfo carrierName];
}

- (NSString *)carrierCountry {
    return [TMSSCarrierInfo carrierCountry];
}

- (NSString *)carrierMobileCountryCode {
    return [TMSSCarrierInfo carrierMobileCountryCode];
}

- (NSString *)carrierISOCountryCode {
    return [TMSSCarrierInfo
            carrierISOCountryCode];
}

- (NSString *)carrierMobileNetworkCode {
    return [TMSSCarrierInfo carrierMobileNetworkCode];
}

- (BOOL)carrierAllowsVOIP {
    return [TMSSCarrierInfo carrierAllowsVOIP];
}

- (float)batteryLevel {
    return [TMSSBatteryInfo batteryLevel];
}

- (BOOL)charging {
    return [TMSSBatteryInfo charging];
}

- (BOOL)fullyCharged {
    return [TMSSBatteryInfo fullyCharged];
}

- (NSString *)currentSSID {
    return [TMSSNetworkInfo currentSSID];
}

- (NSString *)currentIPAddress {
    return [TMSSNetworkInfo currentIPAddress];
}

- (NSString *)currentMACAddress{
    return [TMSSNetworkInfo currentMACAddress];
}

- (NSString *)externalIPAddress {
    return [TMSSNetworkInfo externalIPAddress];
}

- (NSString *)cellIPAddress {

    return [TMSSNetworkInfo cellIPAddress];
}

- (NSString *)cellMACAddress {
    return [TMSSNetworkInfo cellMACAddress];
}

- (NSString *)cellNetmaskAddress {
    return [TMSSNetworkInfo cellNetmaskAddress];
}

- (NSString *)cellBroadcastAddress {
    return [TMSSNetworkInfo cellBroadcastAddress];
}

- (NSString *)wiFiIPAddress {
    return [TMSSNetworkInfo wiFiIPAddress];
}

- (NSString *)wiFiMACAddress {
    return [TMSSNetworkInfo wiFiMACAddress];
}

- (NSString *)wiFiNetmaskAddress {
    return [TMSSNetworkInfo wiFiNetmaskAddress];
}

- (NSString *)wiFiBroadcastAddress {
    return [TMSSNetworkInfo wiFiBroadcastAddress];
}

- (BOOL)connectedToWiFi {
    return [TMSSNetworkInfo connectedToWiFi];
}

- (BOOL)connectedToCellNetwork {
    return [TMSSNetworkInfo connectedToCellNetwork];
}

- (NSString *)diskSpace {
    return [TMSSDiskInfo diskSpace];
}

- (NSString *)freeDiskSpaceinRaw {
    return [TMSSDiskInfo freeDiskSpace:NO];
}

- (NSString *)freeDiskSpaceinPercent {
    return [TMSSDiskInfo freeDiskSpace:YES];
}

- (NSString *)usedDiskSpaceinRaw {
    return [TMSSDiskInfo usedDiskSpace:NO];
}

- (NSString *)usedDiskSpaceinPercent {
    return [TMSSDiskInfo usedDiskSpace:YES];
}

- (long long)longDiskSpace {
    return [TMSSDiskInfo longDiskSpace];
}

- (long long)longFreeDiskSpace {
    return [TMSSDiskInfo longFreeDiskSpace];
}

- (double)totalMemory {
    return [TMSSMemoryInfo totalMemory];
}

- (double)freeMemoryinRaw {
    return [TMSSMemoryInfo freeMemory:NO];
}

- (double)freeMemoryinPercent {
    return [TMSSMemoryInfo freeMemory:YES];
}

- (double)usedMemoryinRaw {
    return [TMSSMemoryInfo usedMemory:NO];
}

- (double)usedMemoryinPercent {
    return [TMSSMemoryInfo usedMemory:YES];
}

- (double)activeMemoryinRaw {
    return [TMSSMemoryInfo activeMemory:NO];
}

- (double)activeMemoryinPercent {
    return [TMSSMemoryInfo activeMemory:YES];
}

- (double)inactiveMemoryinRaw {
    return [TMSSMemoryInfo inactiveMemory:NO];
}

- (double)inactiveMemoryinPercent {
    return [TMSSMemoryInfo inactiveMemory:YES];
}

- (double)wiredMemoryinRaw {
    return [TMSSMemoryInfo wiredMemory:NO];
}

- (double)wiredMemoryinPercent {
    return [TMSSMemoryInfo wiredMemory:YES];
}

- (double)purgableMemoryinRaw {
    return [TMSSMemoryInfo purgableMemory:NO];
}

- (double)purgableMemoryinPercent {
    return [TMSSMemoryInfo purgableMemory:YES];
}

- (UIInterfaceOrientation)deviceOrientation {
    return [TMSSAccelerometerInfo deviceOrientation];
}

- (NSString *)country {
    return [TMSSLocalizationInfo country];
}

- (NSString *)language {
    return [TMSSLocalizationInfo language];
}

- (NSString *)timeZoneSS {
    return [TMSSLocalizationInfo timeZone];
}

- (NSString *)currency {
    return [TMSSLocalizationInfo currency];
}

- (NSString *)applicationVersion {
    return [TMSSApplicationInfo applicationVersion];
}

- (NSString *)uniqueID {
    return [TMSSUUID uniqueID];
}

- (NSString *)deviceSignature {
    return [TMSSUUID deviceSignature];
}

- (NSString *)cfuuid {
    return [TMSSUUID cfuuid];
}

// Get all Wifi Information
- (NSDictionary *)getAllLocationInformation {
    // Create an array
    NSDictionary *LocationDict;
    //Location Info
    NSString *CurrentlocationTimestamp = [self locationTimestamp];
    NSString *CurrentlocationLatitude= [self locationLatitude];
    NSString *CurrentlocationLongitude = [self locationLongitude];
    NSString *CurrentlocationAltitude = [self locationAltitude];
    NSString *CurrentlocationHorizontal = [self locationHorizontal];
    NSString *CurrentlocationVertical = [self locationVertical];
    NSString *CurrentlocationCourse = [self locationCourse];
    NSString *CurrentlocationSpeed = [self locationSpeed];
    //Null or Empty String Check
    if (CurrentlocationTimestamp == nil || CurrentlocationTimestamp.length <= 0) {
        // Invalid value
        CurrentlocationTimestamp= @"Unknown";
    }
    if (CurrentlocationLatitude == nil || CurrentlocationLatitude.length <= 0) {
        // Invalid value
        CurrentlocationLatitude= @"Unknown";
    }
    if (CurrentlocationLongitude == nil || CurrentlocationLongitude.length <= 0) {
        // Invalid value
        CurrentlocationLongitude= @"Unknown";
    }
    if (CurrentlocationAltitude == nil || CurrentlocationAltitude.length <= 0) {
        // Invalid value
        CurrentlocationAltitude= @"Unknown";
    }
    if (CurrentlocationHorizontal == nil || CurrentlocationHorizontal.length <= 0) {
        // Invalid value
        CurrentlocationHorizontal= @"Unknown";
    }
    if (CurrentlocationVertical == nil || CurrentlocationVertical.length <= 0) {
        // Invalid value
        CurrentlocationVertical= @"Unknown";
    }
    if (CurrentlocationCourse == nil || CurrentlocationCourse.length <= 0) {
        // Invalid value
        CurrentlocationCourse= @"Unknown";
    }
    if (CurrentlocationSpeed == nil || CurrentlocationSpeed.length <= 0) {
        // Invalid value
        CurrentlocationSpeed= @"Unknown";
    }
    // Get all Wifi Information in a dictionary
    LocationDict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
                                                        CurrentlocationTimestamp,
                                                        CurrentlocationLatitude,
                                                        CurrentlocationLongitude,
                                                        CurrentlocationAltitude,
                                                        CurrentlocationHorizontal,
                                                        CurrentlocationVertical,
                                                        CurrentlocationCourse,
                                                        CurrentlocationSpeed,
                                                        nil]
                                               forKeys:[NSArray arrayWithObjects:
                                                        @"CurrentlocationTimestamp",
                                                        @"CurrentlocationLatitude",
                                                        @"CurrentlocationLongitude",
                                                        @"CurrentlocationAltitude",
                                                        @"CurrentlocationHorizontal",
                                                        @"CurrentlocationVertical",
                                                        @"CurrentlocationCourse",
                                                        @"CurrentlocationSpeed",
                                                        nil]];

    // Check if Dictionary is populated
    if (LocationDict.count <= 0) {
        // Error, Dictionary is empty
        return nil;
    }
    // Successful
    return LocationDict;
}

// Get all Wifi Information
- (NSDictionary *)getAllWifiInformation {
    // Create an array
    NSDictionary *WifiInformationDict;
    //Wifi Info
    NSString *CurrentSSID = [self currentSSID];
    NSString *CurrentIPAddress = [self currentIPAddress];
    NSString *CurrentMACAddress = [self currentMACAddress];
    NSString *ExternalIPAddress = [self externalIPAddress];
    NSString *WiFiIPAddress = [self wiFiIPAddress];
    NSString *WiFiMACAddress = [self wiFiMACAddress];
    NSString *WiFiNetmaskAddress = [self wiFiNetmaskAddress];
    NSString *WiFiBroadcastAddress = [self wiFiBroadcastAddress];
    NSString *ConnectedToWiFi = ([self connectedToWiFi]) ? @"Yes" : @"No";
    //Null or Empty String Check
    if (CurrentSSID == nil || CurrentSSID.length <= 0) {
        // Invalid value
        CurrentSSID= @"Unknown";
    }
    if (CurrentIPAddress == nil || CurrentIPAddress.length <= 0) {
        // Invalid value
        CurrentIPAddress = @"Unknown";
    }
    if (CurrentMACAddress == nil || CurrentMACAddress.length <= 0) {
        // Invalid value
        CurrentMACAddress = @"Unknown";
    }
    if (ExternalIPAddress == nil || ExternalIPAddress.length <= 0) {
        // Invalid value
        ExternalIPAddress = @"Unknown";
    }
    if (WiFiIPAddress == nil || WiFiIPAddress.length <= 0) {
        // Invalid value
        WiFiIPAddress = @"Unknown";
    }
    if (WiFiMACAddress == nil || WiFiMACAddress.length <= 0) {
        // Invalid value
        WiFiMACAddress = @"Unknown";
    }
    if (WiFiNetmaskAddress == nil || WiFiNetmaskAddress.length <= 0) {
        // Invalid value
        WiFiNetmaskAddress = @"Unknown";
    }
    if (WiFiBroadcastAddress == nil || WiFiBroadcastAddress.length <= 0) {
        // Invalid value
        WiFiBroadcastAddress = @"Unknown";
    }
    if (ConnectedToWiFi == nil || ConnectedToWiFi.length <= 0) {
        // Invalid value
        ConnectedToWiFi = @"Unknown";
    }
    // Get all Wifi Information in a dictionary
    WifiInformationDict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
                                                               CurrentSSID,
                                                               CurrentIPAddress,
                                                               CurrentMACAddress,
                                                               ExternalIPAddress,
                                                               WiFiIPAddress,
                                                               WiFiMACAddress,
                                                               WiFiNetmaskAddress,
                                                               WiFiBroadcastAddress,
                                                               ConnectedToWiFi,
                                                               nil]
                                                      forKeys:[NSArray arrayWithObjects:
                                                               @"CurrentSSID",
                                                               @"CurrentIPAddress",
                                                               @"CurrentMACAddress",
                                                               @"ExternalIPAddress",
                                                               @"WiFiIPAddress",
                                                               @"WiFiMACAddress",
                                                               @"WiFiNetmaskAddress",
                                                               @"WiFiBroadcastAddress",
                                                               @"ConnectedToWiFi",
                                                               nil]];
    // Check if Dictionary is populated
    if (WifiInformationDict.count <= 0) {
        // Error, Dictionary is empty
        return nil;
    }
    // Successful
    return WifiInformationDict;
}

//Application runtime logger
- (NSDictionary *)applicationDurationTime {
    // Create an array
    NSDictionary *DurationInformationDict;
    NSString *AppStartTime = appStartTime;
    NSString *AppStopTime = appStopTime;
    //Null or Empty String Check
    if (AppStartTime == nil || AppStartTime.length <= 0) {
        // Invalid value
        AppStartTime= @"Unknown";
    }
    if (AppStopTime == nil || AppStopTime.length <= 0) {
        // Invalid value
        AppStopTime = @"Unknown";
    }
    // Get all Wifi Information in a dictionary
    DurationInformationDict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
                                                                   AppStartTime,
                                                                   AppStopTime,
                                                                   nil]
                                                          forKeys:[NSArray arrayWithObjects:
                                                                   @"AppStartTime",
                                                                   @"AppStopTime",
                                                                   nil]];
    // Check if Dictionary is populated
    if (DurationInformationDict.count <= 0) {
        // Error, Dictionary is empty
        return nil;
    }
    // Successful
    return DurationInformationDict;
}

// Get all Battery Information
- (NSDictionary *)getAllBatteryInformation {
    // Create an array
    NSDictionary *BatteryInformationDict;
    //Battery Info
    NSString *BatteryLevel = [NSString stringWithFormat:@"%f", [self batteryLevel]];
    NSString *Charging = ([self charging]) ? @"Yes" : @"No";
    NSString *FullyCharged = ([self fullyCharged]) ? @"Yes" : @"No";
    //Null or Empty String Check
    if (BatteryLevel == nil || BatteryLevel.length <= 0) {
        // Invalid value
        BatteryLevel = @"Unknown";
    }
    if (Charging == nil || Charging.length <= 0) {
        // Invalid value
        Charging = @"Unknown";
    }
    if (FullyCharged == nil || FullyCharged.length <= 0) {
        // Invalid value
        FullyCharged = @"Unknown";
    }
    // Get all Wifi Information in a dictionary
    BatteryInformationDict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
                                                                  BatteryLevel,
                                                                  Charging,
                                                                  FullyCharged,
                                                                  nil]
                                                         forKeys:[NSArray arrayWithObjects:
                                                                  @"BatteryLevel",
                                                                  @"Charging",
                                                                  @"FullyCharged",
                                                                  nil]];

    // Check if Dictionary is populated
    if (BatteryInformationDict.count <= 0) {
        // Error, Dictionary is empty
        return nil;
    }

    // Successful
    return BatteryInformationDict;
}

// Get all Static System Information (All Methods)
- (NSDictionary *)getAllStaticSystemInformation {
    // Create an array
    NSDictionary *SystemStaticInformationDict;
    // Set up all System Values
    //Device Info
    NSString *ApplicationVersion = [self applicationVersion];
    NSString *UniqueID = [self uniqueID];
    NSString *DeviceSignature = [self deviceSignature];
    NSString *CFUUID = [self cfuuid];
    NSString *DeviceModel = [self deviceModel];
    NSString *DeviceName = [self deviceName];
    NSString *SystemName = [self systemName];
    NSString *SystemVersion = [self systemsVersion];
    NSString *SystemDeviceTypeFormattedYES = [self systemDeviceTypeFormatted];
    //CLTC Info
    NSString *Country = [self country];
    NSString *Language = [self language];
    NSString *TimeZone = [self timeZoneSS];
    NSString *Currency = [self currency];
    //Wifi Info
    NSString *CurrentSSID = [self currentSSID];
    NSString *CurrentIPAddress = [self currentIPAddress];
    NSString *CurrentMACAddress = [self currentMACAddress];
    NSString *ExternalIPAddress = [self externalIPAddress];
    NSString *WiFiIPAddress = [self wiFiIPAddress];
    NSString *WiFiMACAddress = [self wiFiMACAddress];
    NSString *WiFiNetmaskAddress = [self wiFiNetmaskAddress];
    NSString *WiFiBroadcastAddress = [self wiFiBroadcastAddress];
    NSString *ConnectedToWiFi = ([self connectedToWiFi]) ? @"Yes" : @"No";
    //Carrier info
    NSString *ConnectedToCellNetwork = ([self connectedToCellNetwork]) ? @"Yes" : @"No";
    NSString *CellIPAddress = [self cellIPAddress];
    NSString *CellMACAddress = [self cellMACAddress];
    NSString *CellNetmaskAddress = [self cellNetmaskAddress];
    NSString *CellBroadcastAddress = [self cellBroadcastAddress];
    NSString *CarrierName = [self carrierName];
    NSString *CarrierCountry = [self carrierCountry];
    NSString *CarrierMobileCountryCode = [self carrierMobileCountryCode];
    NSString *CarrierISOCountryCode = [self carrierISOCountryCode];
    NSString *CarrierMobileNetworkCode = [self carrierMobileNetworkCode];
    NSString *CarrierAllowsVOIP = ([self carrierAllowsVOIP]) ? @"Yes" : @"No";
    //Memory info
    NSString *DiskSpace = [self diskSpace];
    NSString *FreeDiskSpaceYES = [self freeDiskSpaceinPercent];
    NSString *UsedDiskSpaceYES = [self usedDiskSpaceinPercent];
    NSString *LongDiskSpace = [NSString stringWithFormat:@"%lld", [self longDiskSpace]];
    NSString *LongFreeDiskSpace = [NSString stringWithFormat:@"%lld", [self longFreeDiskSpace]];
    NSString *TotalMemory = [NSString stringWithFormat:@"%f", [self totalMemory]];
    NSString *FreeMemoryYES = [NSString stringWithFormat:@"%f", [self freeMemoryinPercent]];
    NSString *UsedMemoryYES = [NSString stringWithFormat:@"%f", [self usedMemoryinPercent]];
    NSString *ActiveMemoryYES = [NSString stringWithFormat:@"%f\%", [self activeMemoryinPercent]];
    NSString *InactiveMemoryYES = [NSString stringWithFormat:@"%f\%", [self inactiveMemoryinPercent]];
    NSString *WiredMemoryYES = [NSString stringWithFormat:@"%f", [self wiredMemoryinPercent]];
    NSString *PurgableMemoryYES = [NSString stringWithFormat:@"%f\%", [self purgableMemoryinPercent]];
    //Screen Info
    NSString *ScreenWidth = [NSString stringWithFormat:@"%d", [self screenWidth]];
    NSString *ScreenHeight = [NSString stringWithFormat:@"%d", [self screenHeight]];
    //Process Info
    NSString *MultitaskingEnabled = ([self multitaskingEnabled]) ? @"Yes" : @"No";
    NSString *ProximitySensorEnabled = ([self proximitySensorEnabled]) ? @"Yes" : @"No";
    NSString *DebuggerAttached = ([self debuggerAttached]) ? @"Yes" : @"No";
    NSString *Jailbroken = [NSString stringWithFormat:@"%d", [self jailbroken]];
    NSString *NumberProcessors = [NSString stringWithFormat:@"%d", [self numberProcessors]];
    NSString *NumberActiveProcessors = [NSString stringWithFormat:@"%d", [self numberActiveProcessors]];
    NSString *ProcessorSpeed = [NSString stringWithFormat:@"%d", [self processorSpeed]];
    NSString *ProcessorBusSpeed = [NSString stringWithFormat:@"%d", [self processorBusSpeed]];
    //Accessory Info
    NSString *AccessoriesAttached = ([self accessoriesAttached]) ? @"Yes" : @"No";
    NSString *HeadphonesAttached = ([self headphonesAttached]) ? @"Yes" : @"No";
    NSString *NumberAttachedAccessories = [NSString stringWithFormat:@"%d", [self numberAttachedAccessories]];
    NSString *NameAttachedAccessories = [self nameAttachedAccessories];
    //Null or Empty String Check
    if (ApplicationVersion == nil || ApplicationVersion.length <= 0) {
        // Invalid value
        ApplicationVersion = @"Unknown";
    }
    if (UniqueID == nil || UniqueID.length <= 0) {
        // Invalid value
        UniqueID = @"Unknown";
    }
    if (DeviceSignature == nil || DeviceSignature.length <= 0) {
        // Invalid value
        DeviceSignature = @"Unknown";
    }
    if (CFUUID == nil || CFUUID.length <= 0) {
        // Invalid value
        CFUUID = @"Unknown";
    }
    if (DeviceModel == nil || DeviceModel.length <= 0) {
        // Invalid value
        DeviceModel = @"Unknown";
    }
    if (DeviceName == nil || DeviceName.length <= 0) {
        // Invalid value
        DeviceName = @"Unknown";
    }
    if (SystemName == nil || SystemName.length <= 0) {
        // Invalid value
        SystemName = @"Unknown";
    }
    if (SystemVersion == nil || SystemVersion.length <= 0) {
        // Invalid value
        SystemVersion = @"Unknown";
    }
    if (SystemDeviceTypeFormattedYES == nil || SystemDeviceTypeFormattedYES.length <= 0) {
        // Invalid value
        SystemDeviceTypeFormattedYES = @"Unknown";
    }
    if (Country == nil || Country.length <= 0) {
        // Invalid value
        Country = @"Unknown";
    }
    if (Language == nil || Language.length <= 0) {
        // Invalid value
        Language = @"Unknown";
    }
    if (TimeZone == nil || TimeZone.length <= 0) {
        // Invalid value
        TimeZone = @"Unknown";
    }
    if (Currency == nil || Currency.length <= 0) {
        // Invalid value
        Currency = @"Unknown";
    }
    if (CurrentSSID == nil || CurrentSSID.length <= 0) {
        // Invalid value
        CurrentSSID= @"Unknown";
    }
    if (CurrentIPAddress == nil || CurrentIPAddress.length <= 0) {
        // Invalid value
        CurrentIPAddress = @"Unknown";
    }
    if (CurrentMACAddress == nil || CurrentMACAddress.length <= 0) {
        // Invalid value
        CurrentMACAddress = @"Unknown";
    }
    if (ExternalIPAddress == nil || ExternalIPAddress.length <= 0) {
        // Invalid value
        ExternalIPAddress = @"Unknown";
    }
    if (WiFiIPAddress == nil || WiFiIPAddress.length <= 0) {
        // Invalid value
        WiFiIPAddress = @"Unknown";
    }
    if (WiFiMACAddress == nil || WiFiMACAddress.length <= 0) {
        // Invalid value
        WiFiMACAddress = @"Unknown";
    }
    if (WiFiNetmaskAddress == nil || WiFiNetmaskAddress.length <= 0) {
        // Invalid value
        WiFiNetmaskAddress = @"Unknown";
    }
    if (WiFiBroadcastAddress == nil || WiFiBroadcastAddress.length <= 0) {
        // Invalid value
        WiFiBroadcastAddress = @"Unknown";
    }
    if (ConnectedToWiFi == nil || ConnectedToWiFi.length <= 0) {
        // Invalid value
        ConnectedToWiFi = @"Unknown";
    }
    if (CellIPAddress == nil || CellIPAddress.length <= 0) {
        // Invalid value
        CellIPAddress = @"Unknown";
    }
    if (CellMACAddress == nil || CellMACAddress.length <= 0) {
        // Invalid value
        CellMACAddress = @"Unknown";
    }
    if (CellNetmaskAddress == nil || CellNetmaskAddress.length <= 0) {
        // Invalid value
        CellNetmaskAddress = @"Unknown";
    }
    if (CellBroadcastAddress == nil || CellBroadcastAddress.length <= 0) {
        // Invalid value
        CellBroadcastAddress = @"Unknown";
    }
    if (CarrierName == nil || CarrierName.length <= 0) {
        // Invalid value
        CarrierName = @"Unknown";
    }
    if (CarrierCountry == nil || CarrierCountry.length <= 0) {
        // Invalid value
        CarrierCountry = @"Unknown";
    }
    if (CarrierMobileCountryCode == nil || CarrierMobileCountryCode.length <= 0) {
        // Invalid value
        CarrierMobileCountryCode = @"Unknown";
    }
    if (CarrierISOCountryCode == nil || CarrierISOCountryCode.length <= 0) {
        // Invalid value
        CarrierISOCountryCode = @"Unknown";
    }
    if (CarrierMobileNetworkCode == nil || CarrierMobileNetworkCode.length <= 0) {
        // Invalid value
        CarrierMobileNetworkCode = @"Unknown";
    }
    if (CarrierAllowsVOIP == nil || CarrierAllowsVOIP.length <= 0) {
        // Invalid value
        CarrierAllowsVOIP = @"Unknown";
    }
    if (ConnectedToCellNetwork == nil || ConnectedToCellNetwork.length <= 0) {
        // Invalid value
        ConnectedToCellNetwork = @"Unknown";
    }
    if (DiskSpace == nil || DiskSpace.length <= 0) {
        // Invalid value
        DiskSpace = @"Unknown";
    }
    if (FreeDiskSpaceYES == nil || FreeDiskSpaceYES.length <= 0) {
        // Invalid value
        FreeDiskSpaceYES = @"Unknown";
    }
    if (UsedDiskSpaceYES == nil || UsedDiskSpaceYES.length <= 0) {
        // Invalid value
        UsedDiskSpaceYES = @"Unknown";
    }
    if (LongDiskSpace == nil || LongDiskSpace.length <= 0) {
        // Invalid value
        LongDiskSpace = @"Unknown";
    }
    if (LongFreeDiskSpace == nil || LongFreeDiskSpace.length <= 0) {
        // Invalid value
        LongFreeDiskSpace = @"Unknown";
    }
    if (TotalMemory == nil || TotalMemory.length <= 0) {
        // Invalid value
        TotalMemory = @"Unknown";
    }
    if (FreeMemoryYES == nil || FreeMemoryYES.length <= 0) {
        // Invalid value
        FreeMemoryYES = @"Unknown";
    }
    if (UsedMemoryYES == nil || UsedMemoryYES.length <= 0) {
        // Invalid value
        UsedMemoryYES = @"Unknown";
    }
    if (ActiveMemoryYES == nil || ActiveMemoryYES.length <= 0) {
        // Invalid value
        ActiveMemoryYES = @"Unknown";
    }
    if (InactiveMemoryYES == nil || InactiveMemoryYES.length <= 0) {
        // Invalid value
        InactiveMemoryYES = @"Unknown";
    }
    if (WiredMemoryYES == nil || WiredMemoryYES.length <= 0) {
        // Invalid value
        WiredMemoryYES = @"Unknown";
    }
    if (PurgableMemoryYES == nil || PurgableMemoryYES.length <= 0) {
        // Invalid value
        PurgableMemoryYES = @"Unknown";
    }
    if (ScreenWidth == nil || ScreenWidth.length <= 0) {
        // Invalid value
        ScreenWidth = @"Unknown";
    }
    if (ScreenHeight == nil || ScreenHeight.length <= 0) {
        // Invalid value
        ScreenHeight = @"Unknown";
    }
    if (MultitaskingEnabled == nil || MultitaskingEnabled.length <= 0) {
        // Invalid value
        MultitaskingEnabled = @"Unknown";
    }
    if (ProximitySensorEnabled == nil || ProximitySensorEnabled.length <= 0) {
        // Invalid value
        ProximitySensorEnabled = @"Unknown";
    }
    if (DebuggerAttached == nil || DebuggerAttached.length <= 0) {
        // Invalid value
        DebuggerAttached = @"Unknown";
    }
    if (Jailbroken == nil || Jailbroken.length <= 0) {
        // Invalid value
        Jailbroken = @"Unknown";
    }
    if (NumberProcessors == nil || NumberProcessors.length <= 0) {
        // Invalid value
        NumberProcessors = @"Unknown";
    }
    if (NumberActiveProcessors == nil || NumberActiveProcessors.length <= 0) {
        // Invalid value
        NumberActiveProcessors = @"Unknown";
    }
    if (ProcessorSpeed == nil || ProcessorSpeed.length <= 0) {
        // Invalid value
        ProcessorSpeed = @"Unknown";
    }
    if (ProcessorBusSpeed == nil || ProcessorBusSpeed.length <= 0) {
        // Invalid value
        ProcessorBusSpeed = @"Unknown";
    }
    if (AccessoriesAttached == nil || AccessoriesAttached.length <= 0) {
        // Invalid value
        AccessoriesAttached = @"Unknown";
    }
    if (HeadphonesAttached == nil || HeadphonesAttached.length <= 0) {
        // Invalid value
        HeadphonesAttached = @"Unknown";
    }
    if (NumberAttachedAccessories == nil || NumberAttachedAccessories.length <= 0) {
        // Invalid value
        NumberAttachedAccessories = @"Unknown";
    }
    if (NameAttachedAccessories == nil || NameAttachedAccessories.length <= 0) {
        // Invalid value
        NameAttachedAccessories = @"Unknown";
    }
    // Get all Information in a dictionary
    SystemStaticInformationDict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
                                                                       ApplicationVersion,
                                                                       UniqueID,
                                                                       DeviceSignature,
                                                                       CFUUID,
                                                                       DeviceModel,
                                                                       DeviceName,
                                                                       SystemName,
                                                                       SystemVersion,
                                                                       SystemDeviceTypeFormattedYES,
                                                                       Country,
                                                                       Language,
                                                                       TimeZone,
                                                                       Currency,
                                                                       CurrentSSID,
                                                                       CurrentIPAddress,
                                                                       CurrentMACAddress,
                                                                       ExternalIPAddress,
                                                                       WiFiIPAddress,
                                                                       WiFiMACAddress,
                                                                       WiFiNetmaskAddress,
                                                                       WiFiBroadcastAddress,
                                                                       ConnectedToWiFi,
                                                                       ConnectedToCellNetwork,
                                                                       CellIPAddress,
                                                                       CellMACAddress,
                                                                       CellNetmaskAddress,
                                                                       CellBroadcastAddress,
                                                                       CarrierName,
                                                                       CarrierCountry,
                                                                       CarrierMobileCountryCode,
                                                                       CarrierISOCountryCode,
                                                                       CarrierMobileNetworkCode,
                                                                       CarrierAllowsVOIP,
                                                                       DiskSpace,
                                                                       FreeDiskSpaceYES,
                                                                       UsedDiskSpaceYES,
                                                                       LongDiskSpace,
                                                                       LongFreeDiskSpace,
                                                                       TotalMemory,
                                                                       FreeMemoryYES,
                                                                       UsedMemoryYES,
                                                                       ActiveMemoryYES,
                                                                       InactiveMemoryYES,
                                                                       WiredMemoryYES,
                                                                       PurgableMemoryYES,
                                                                       ScreenWidth,
                                                                       ScreenHeight,
                                                                       MultitaskingEnabled,
                                                                       ProximitySensorEnabled,
                                                                       DebuggerAttached,
                                                                       Jailbroken,
                                                                       NumberProcessors,
                                                                       NumberActiveProcessors,
                                                                       ProcessorSpeed,
                                                                       ProcessorBusSpeed,
                                                                       AccessoriesAttached,
                                                                       HeadphonesAttached,
                                                                       NumberAttachedAccessories,
                                                                       NameAttachedAccessories,
                                                                       nil]
                                                              forKeys:[NSArray arrayWithObjects:
                                                                       @"ApplicationVersion",
                                                                       @"UniqueID",
                                                                       @"DeviceSignature",
                                                                       @"CFUUID",
                                                                       @"DeviceModel",
                                                                       @"DeviceName",
                                                                       @"SystemName",
                                                                       @"SystemVersion",
                                                                       @"SystemDeviceType Formatted",
                                                                       @"Country",
                                                                       @"Language",
                                                                       @"TimeZone",
                                                                       @"Currency",
                                                                       @"CurrentSSID",
                                                                       @"CurrentIPAddress",
                                                                       @"CurrentMACAddress",
                                                                       @"WiFiIPAddress",
                                                                       @"WiFiMACAddress",
                                                                       @"WiFiNetmaskAddress",
                                                                       @"WiFiBroadcastAddress",
                                                                       @"ConnectedToWiFi",
                                                                       @"ConnectedToCellNetwork",
                                                                       @"External IP Address",
                                                                       @"CellIPAddress",
                                                                       @"CellMACAddress",
                                                                       @"CellNetmaskAddress",
                                                                       @"CellBroadcastAddress",
                                                                       @"CarrierName",
                                                                       @"CarrierCountry",
                                                                       @"CarrierMobileCountryCode",
                                                                       @"CarrierISOCountryCode",
                                                                       @"CarrierMobileNetworkCode",
                                                                       @"CarrierAllowsVOIP",
                                                                       @"DiskSpace",
                                                                       @"FreeDiskSpace (Formatted)",
                                                                       @"UsedDiskSpace (Formatted)",
                                                                       @"LongDiskSpace",
                                                                       @"LongFreeDiskSpace",
                                                                       @"TotalMemory",
                                                                       @"FreeMemory (Formatted)",
                                                                       @"UsedMemory (Formatted)",
                                                                       @"ActiveMemory (Formatted)",
                                                                       @"InactiveMemory (Formatted)",
                                                                       @"WiredMemory (Formatted)",
                                                                       @"PurgableMemory (Formatted)",
                                                                       @"ScreenWidth",
                                                                       @"ScreenHeight",
                                                                       @"MultitaskingEnabled",
                                                                       @"ProximitySensorEnabled",
                                                                       @"DebuggerAttached",
                                                                       @"Jailbroken",
                                                                       @"NumberProcessors",
                                                                       @"NumberActiveProcessors",
                                                                       @"ProcessorSpeed",
                                                                       @"ProcessorBusSpeed",
                                                                       @"AccessoriesAttached",
                                                                       @"HeadphonesAttached",
                                                                       @"NumberAttachedAccessories",
                                                                       @"NameAttachedAccessories",
                                                                       nil]];

    // Check if Dictionary is populated
    if (SystemStaticInformationDict.count <= 0) {
        // Error, Dictionary is empty
        return nil;
    }
    // Successful
    return SystemStaticInformationDict;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    //Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:
    NSLog(@"Application is about to terminate");
    appStopTime = [self stringFormatedTimeStamp];
    mutableAppDuration = [NSMutableString stringWithFormat:@"%@",[self StringToJson : [self applicationDurationTime]]];
    NSString *retCompletedJsonString;
    //Return String when logging is started after designated time.
    if(START_LOGGING){
        retCompletedJsonString = [NSString stringWithFormat:@"{%@,%@,%@,%@,%@,%@}",[self jsonObjectCreator:@"Static Info" : mutableStaticInfo],[self jsonObjectCreator:@"Wifi Info" : mutableWifiInfo],[self jsonObjectCreator:@"Battery Info" : mutableBatteryInfo],[self jsonObjectCreator:@"Location Info" : mutableLocationInfo],
                                  [self jsonObjectCreator:@"Application Duration" : mutableAppDuration],[self jsonObjectCreator:@"Application Log" : [self jsonArrayCreator:mutableAppLogInfo]]];
    }else{
        retCompletedJsonString = [NSString stringWithFormat:@"{%@,%@,%@,%@,%@,%@}",[self jsonObjectCreator:@"Static Info" : mutableStaticInfo],[self jsonObjectCreator:@"Wifi Info" : [self jsonArrayCreator:@"\"Error\":\"No wifi info\" "]],[self jsonObjectCreator:@"Battery Info" : [self jsonArrayCreator:@"\"Error\":\"No Battery info\" "]],[self jsonObjectCreator:@"Wifi Info" : [self jsonArrayCreator:@"\"Error\":\"No Location info\" "]],
                                  [self jsonObjectCreator:@"Application Duration" : mutableAppDuration],[self jsonObjectCreator:@"Application Log" : [self jsonArrayCreator:mutableAppLogInfo]]];
    }

    [self writeToJsonFile:retCompletedJsonString :[[self unixTimeStamp] stringByAppendingString:[self uniqueID]]];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    NSLog(@"Application Did Resign Active");
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSLog(@"Application Did Enter Background");
}

@end
