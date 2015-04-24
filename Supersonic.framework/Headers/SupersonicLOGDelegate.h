//
//  Copyright (c) 2015 Supersonic. All rights reserved.
//

#ifndef SUPERSONIC_LOG_DELEGATE_H
#define SUPERSONIC_LOG_DELEGATE_H

#import <Foundation/Foundation.h>

typedef enum LogLevelValues
{
    LOG_NONE = -1,
    LOG_INTERNAL = 0,
    LOG_INFO = 1,
    LOG_WARNING = 2,
    LOG_ERROR = 3,
    LOG_CRITICAL = 4,
    
} LogLevel;

typedef enum LogTagValue
{
    TAG_API,
    TAG_DELEGATE,
    TAG_ADAPTER_API,
    TAG_ADAPTER_DELEGATE,
    TAG_NETWORK,
    TAG_NATIVE,
    TAG_INTERNAL,
    
} LogTag;

@protocol SupersonicLogDelegate <NSObject>

@required

- (void)sendLog:(NSString *)log level:(LogLevel)level tag:(LogTag)tag;

@end

#endif