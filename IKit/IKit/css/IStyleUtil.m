/*
 Copyright (c) 2014 ideawu. All rights reserved.
 Use of this source code is governed by a license that can be
 found in the LICENSE file.
 
 @author:  ideawu
 @website: http://www.cocoaui.com/
 */

#import "IStyleUtil.h"

@implementation IStyleUtil

static NSString *substr(NSString *str, NSUInteger offset, NSUInteger len){
	return [str substringWithRange:NSMakeRange(offset, len)];
}

static CGFloat colorVal(NSString *hex){
	hex = (hex.length == 2) ? hex : [NSString stringWithFormat:@"%@%@", hex, hex];
	unsigned num;
	[[NSScanner scannerWithString:hex] scanHexInt:&num];
	return num / 255.0;
}

+ (UIColor *)colorFromHex:(NSString *)hex {
	if([hex isEqualToString:@"none"]){
		return [UIColor clearColor];
	}
	if([hex characterAtIndex:0] == '#'){
		hex = [hex substringFromIndex:1];
	}
	
	CGFloat alpha, red, blue, green;
	switch ([hex length]) {
		case 3: // #RGB
			alpha = 1.0f;
			red   = colorVal(substr(hex, 0, 1));
			green = colorVal(substr(hex, 1, 1));
			blue  = colorVal(substr(hex, 2, 1));
			break;
		case 4: // #ARGB
			alpha = colorVal(substr(hex, 0, 1));
			red   = colorVal(substr(hex, 1, 1));
			green = colorVal(substr(hex, 2, 1));
			blue  = colorVal(substr(hex, 3, 1));
			break;
		case 6: // #RRGGBB
			alpha = 1.0f;
			red   = colorVal(substr(hex, 0, 2));
			green = colorVal(substr(hex, 2, 2));
			blue  = colorVal(substr(hex, 4, 2));
			break;
		case 8: // #AARRGGBB
			alpha = colorVal(substr(hex, 0, 2));
			red   = colorVal(substr(hex, 2, 2));
			green = colorVal(substr(hex, 4, 2));
			blue  = colorVal(substr(hex, 6, 2));
			break;
		default:
			return [UIColor clearColor];
			break;
	}
	return [UIColor colorWithRed: red green: green blue: blue alpha: alpha];
}

+ (BOOL)isHttpUrl:(NSString *)src{
	if([src rangeOfString:@"http://"].location == 0 || [src rangeOfString:@"https://"].location == 0){
		return YES;
	}
	return NO;
}

+ (NSArray *)parsePath:(NSString *)url{
	NSString *basePath, *rootPath;
	NSRange r1 = [url rangeOfString:@"http://"];
	if(r1.location != 0){
		r1 = [url rangeOfString:@"https://"];
	}
	NSRange r2 = [url rangeOfString:@"/" options:NSBackwardsSearch];
	if(r1.location != 0){ // File path
		rootPath = [NSString stringWithFormat:@"%@/", [[NSBundle mainBundle] resourcePath]];
		if(r2.location == NSNotFound){
			basePath = rootPath;
		}else{
			basePath = [NSString stringWithFormat:@"%@%@/", rootPath, [url substringToIndex:r2.location]];
		}
	}else{ // HTTP URL
		if(r2.location < r1.location + r1.length){ // like http://cocoaui.com
			basePath = [NSString stringWithFormat:@"%@/", url];
			rootPath = basePath;
		}else{
			basePath = [url substringToIndex:r2.location + 1];
			NSUInteger idx = r1.location + r1.length;
			while(idx < url.length){
				if([url characterAtIndex:idx] == '/'){
					break;
				}
				idx ++;
			}
			rootPath = [url substringToIndex:idx + 1];
		}
	}
	return [NSArray arrayWithObjects:rootPath, basePath, nil];
}

@end
