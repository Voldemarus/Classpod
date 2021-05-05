//
//  DebugPrint.h
//
//  Created by Водолазкий В.В. on 17/04/2018.
//  Copyright © 2018 Geomatix Laboratory S.R.O. All rights reserved.
//

#ifndef DebugPrint_h
#define DebugPrint_h

//// Тестовая печать
#ifdef DEBUG
    #ifndef DLog
        #define DLog(fmt, ...) printf("%s\n", [[NSString stringWithFormat:(@"%s[%d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__] UTF8String])
    #endif
    #ifndef ALog
        #define ALog(fmt, ...) printf("%s\n", [[NSString stringWithFormat:(fmt), ##__VA_ARGS__] UTF8String])
    #endif
#else
    #ifndef DLog
        #define DLog(...)
    #endif
    #ifndef ALog
        #define ALog(...)
    #endif
#endif

/**
 RStr - Resource String
 Provides localized string from default localization storage
 */
//#define RStr(name) NSLocalizedString(name, name)

#endif /* DebugPrint_h */

