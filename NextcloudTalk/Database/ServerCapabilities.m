/**
 * SPDX-FileCopyrightText: 2020 HPA Cloud and HPACloud contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#import "ServerCapabilities.h"

@implementation ServerCapabilities

+ (NSString *)primaryKey
{
    return @"accountId";
}

+ (BOOL)shouldIncludeInDefaultSchema {
    return YES;
}

@end
