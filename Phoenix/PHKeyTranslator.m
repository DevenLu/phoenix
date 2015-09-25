/*
 * Phoenix is released under the MIT License. Refer to https://github.com/kasper/phoenix/blob/master/LICENSE.md
 */

@import Carbon;

#import "PHKeyTranslator.h"

@implementation PHKeyTranslator

static NSDictionary<NSString *, NSNumber *> *PHModifierStringToFlag;
static NSArray<NSNumber *> *PHLocalKeyCodes;
static NSDictionary<NSString *, NSNumber *> *PHStringToKeyCode;
static NSMutableDictionary<NSString *, NSNumber *> *PHResolvedLocalKeyCodes;

#pragma mark - Initialise

+ (void) initialize {

    /* Modifiers */

    PHModifierStringToFlag = @{ @"cmd": @(cmdKey),
                                @"alt": @(optionKey),
                                @"ctrl": @(controlKey),
                                @"shift": @(shiftKey) };

    /* Local Keys */

    PHLocalKeyCodes = @[ @(kVK_ANSI_A),
                         @(kVK_ANSI_B),
                         @(kVK_ANSI_C),
                         @(kVK_ANSI_D),
                         @(kVK_ANSI_E),
                         @(kVK_ANSI_F),
                         @(kVK_ANSI_G),
                         @(kVK_ANSI_H),
                         @(kVK_ANSI_I),
                         @(kVK_ANSI_J),
                         @(kVK_ANSI_K),
                         @(kVK_ANSI_L),
                         @(kVK_ANSI_M),
                         @(kVK_ANSI_N),
                         @(kVK_ANSI_O),
                         @(kVK_ANSI_P),
                         @(kVK_ANSI_Q),
                         @(kVK_ANSI_R),
                         @(kVK_ANSI_S),
                         @(kVK_ANSI_T),
                         @(kVK_ANSI_U),
                         @(kVK_ANSI_V),
                         @(kVK_ANSI_W),
                         @(kVK_ANSI_X),
                         @(kVK_ANSI_Y),
                         @(kVK_ANSI_Z),
                         @(kVK_ANSI_0),
                         @(kVK_ANSI_1),
                         @(kVK_ANSI_2),
                         @(kVK_ANSI_3),
                         @(kVK_ANSI_4),
                         @(kVK_ANSI_5),
                         @(kVK_ANSI_6),
                         @(kVK_ANSI_7),
                         @(kVK_ANSI_8),
                         @(kVK_ANSI_9),
                         @(kVK_ANSI_Equal),
                         @(kVK_ANSI_Minus),
                         @(kVK_ANSI_RightBracket),
                         @(kVK_ANSI_LeftBracket),
                         @(kVK_ANSI_Quote),
                         @(kVK_ANSI_Semicolon),
                         @(kVK_ANSI_Backslash),
                         @(kVK_ANSI_Comma),
                         @(kVK_ANSI_Slash),
                         @(kVK_ANSI_Period),
                         @(kVK_ANSI_Grave) ];

    /* Special Keys */

    PHStringToKeyCode = @{ /* Action Keys */

                           @"return": @(kVK_Return),
                           @"tab": @(kVK_Tab),
                           @"space": @(kVK_Space),
                           @"delete": @(kVK_Delete),
                           @"escape": @(kVK_Escape),
                           @"help": @(kVK_Help),
                           @"home": @(kVK_Home),
                           @"pageup": @(kVK_PageUp), // pageUp
                           @"forwarddelete": @(kVK_ForwardDelete), // forwardDelete
                           @"end": @(kVK_End),
                           @"pagedown": @(kVK_PageDown), // pageDown
                           @"left": @(kVK_LeftArrow),
                           @"right": @(kVK_RightArrow),
                           @"down": @(kVK_DownArrow),
                           @"up": @(kVK_UpArrow),

                           /* Function Keys */

                           @"f1": @(kVK_F1),
                           @"f2": @(kVK_F2),
                           @"f3": @(kVK_F3),
                           @"f4": @(kVK_F4),
                           @"f5": @(kVK_F5),
                           @"f6": @(kVK_F6),
                           @"f7": @(kVK_F7),
                           @"f8": @(kVK_F8),
                           @"f9": @(kVK_F9),
                           @"f10": @(kVK_F10),
                           @"f11": @(kVK_F11),
                           @"f12": @(kVK_F12),
                           @"f13": @(kVK_F13),
                           @"f14": @(kVK_F14),
                           @"f15": @(kVK_F15),
                           @"f16": @(kVK_F16),
                           @"f17": @(kVK_F17),
                           @"f18": @(kVK_F18),
                           @"f19": @(kVK_F19),

                           /* Keypad Keys */

                           @"pad.": @(kVK_ANSI_KeypadDecimal),
                           @"pad*": @(kVK_ANSI_KeypadMultiply),
                           @"pad+": @(kVK_ANSI_KeypadPlus),
                           @"padclear": @(kVK_ANSI_KeypadClear), // padClear
                           @"pad/": @(kVK_ANSI_KeypadDivide),
                           @"padenter": @(kVK_ANSI_KeypadEnter), // padEnter
                           @"pad-": @(kVK_ANSI_KeypadMinus),
                           @"pad=": @(kVK_ANSI_KeypadEquals),
                           @"pad0": @(kVK_ANSI_Keypad0),
                           @"pad1": @(kVK_ANSI_Keypad1),
                           @"pad2": @(kVK_ANSI_Keypad2),
                           @"pad3": @(kVK_ANSI_Keypad3),
                           @"pad4": @(kVK_ANSI_Keypad4),
                           @"pad5": @(kVK_ANSI_Keypad5),
                           @"pad6": @(kVK_ANSI_Keypad6),
                           @"pad7": @(kVK_ANSI_Keypad7),
                           @"pad8": @(kVK_ANSI_Keypad8),
                           @"pad9": @(kVK_ANSI_Keypad9) };

    PHResolvedLocalKeyCodes = [NSMutableDictionary dictionary];

    // Resolve local keys
    for (NSNumber *keyCode in PHLocalKeyCodes) {
        NSString *character = [self characterForKeyCode:keyCode.unsignedShortValue];
        PHResolvedLocalKeyCodes[character] = keyCode;
    }
}

#pragma mark - Translate

+ (NSString *) characterForKeyCode:(unsigned short)keyCode {

    id currentKeyboard = CFBridgingRelease(TISCopyCurrentKeyboardInputSource());
    CFDataRef layoutData = TISGetInputSourceProperty((__bridge TISInputSourceRef) currentKeyboard,
                                                     kTISPropertyUnicodeKeyLayoutData);
    UCKeyboardLayout * const keyboardLayout = (UCKeyboardLayout * const) CFDataGetBytePtr(layoutData);

    UInt32 deadKeyState = 0;
    UniCharCount maxStringLength = 4;
    UniCharCount actualStringLength;
    UniChar unicodeString[maxStringLength];

    OSStatus error = UCKeyTranslate(keyboardLayout,
                                    keyCode,
                                    kUCKeyActionDisplay,
                                    0,
                                    LMGetKbdType(),
                                    kUCKeyTranslateNoDeadKeysBit,
                                    &deadKeyState,
                                    maxStringLength,
                                    &actualStringLength,
                                    unicodeString);
    if (error != noErr) {
        NSLog(@"Error: Could not translate key code %hu to a Unicode character using the keyboard layout. (%d)", keyCode, error);
        return nil;
    }

    return [NSString stringWithCharacters:unicodeString length:actualStringLength];
}

+ (UInt32) modifierFlagsForModifiers:(NSArray<NSString *> *)modifiers {

    UInt32 flags = 0;

    for (NSString *modifier in modifiers) {

        NSNumber *flag = PHModifierStringToFlag[modifier];

        if (flag) {
            flags |= flag.unsignedIntValue;
        }
    }

    return flags;
}

+ (UInt32) keyCodeForString:(NSString *)string {

    // Local key
    NSNumber *keyCode = PHResolvedLocalKeyCodes[string];

    if (keyCode) {
        return keyCode.unsignedIntValue;
    }

    // Special key
    keyCode = PHStringToKeyCode[string];

    if (keyCode) {
        return keyCode.unsignedIntValue;
    }

    return UINT32_MAX;
}

@end
