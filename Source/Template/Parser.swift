//
//  Generated by pegged $Version
//  Fork: https://github.com/dparnell/pegged
//  File is auto-generated. Do not modify.
//

import Foundation
//!$Imports

let ParserClassErrorStringLocationKey = "ParserClassErrorStringLocation"
let ParserClassErrorStringLengthKey   = "ParserClassErrorStringLength"
let ParserClassErrorStringKey         = "ParserClassErrorString"
let ParserClassErrorTypeKey           = "ParserClassErrorType"

class ParserClassCapture {
    // The position index used for text capturing
    var begin: Int = 0
    var end: Int = 0

    // The parsed ranged used for this capture
    var parsedRange: Range<Int> = Range<Int>(start: 0, end: 0)

    // The action associated with a capture
    var action: (parser: ParserClass, text: String, inout errorCode: String) -> AnyObject?

    // The count of captured results available to an action
    var capturedResultsCount: Int = 0

    // All results captured by the action
    var allResults: AnyObject[] = []

    // The index of the next result to be read by the action
    var nextResultIndex: Int = 0
    
    init() {
        // let's keep the compiler happy!

        action = {(parser: ParserClass, text: String, inout errorCode: String) -> AnyObject? in
            return nil
        }
    }
}

class ParserClass {
    /*!
    @abstract The last error state of the parser.
    @discussion ParserClassErrorStringLocationKey, ParserClassErrorStringLengthKey provides the index and length of the errorneous string (NSNumber), ParserClassErrorStringKey the errorneous string. ParserClassErrorTypeKey contains a grammar-dependent error key. The localized description of the error will be generated from the string file of the ParserClass, whereas the ParserClassErrorTypeKey will be used as localization string key.
    */    
    var lastError: NSError?
    
    /*!
    @abstract The start index of the current capture
    */
    var captureStart: Int = 0
    
    /*!
    @abstract The end index of the current capture
    */
    var captureEnd: Int = 0
    
    /*!
    @abstract The currently parsed string
    */
    var string: String = ""
    
    var _index: Int = 0
    var _limit: Int = 0
    var _lastError: NSError?
    var _capturing = false
    var _captures: ParserClassCapture[] = []
    
    // The capture of the currently performed action
    var _currentCapture: ParserClassCapture?
    
    var _actionResults: AnyObject[] = []
    
//!$ExtraCode

    func yyText(from: Int, to: Int) -> String
    {
        let len = to - from
        if (len <= 0) {
            return ""
        }
        
        let subStart = advance(string.startIndex, from, string.endIndex)
        let subEnd = advance(subStart, len, string.endIndex)
        return string.substringWithRange(Range<String.Index>(start: subStart, end: subEnd))
    }

    /*!
    @abstract Parses the given string and passes the return value of the start rule as output argument.
    @discussion Returns YES on match.
    */
    func parseString(string:String, inout result:AnyObject?) -> Bool  {
        self.string = string//!$ParserCaseSensitivity
        _index = 0
        _limit = string.utf16count
        
        _captures = []
        _actionResults = []
        
        captureStart = _index
        captureEnd = _index
        _capturing = true
        
        // Do string matching
        var matched = self.matchRule("$StartRule", startIndex: _index, asserted: true);
        
        // Process actions
        if (matched) {
            for capture in _captures {
                _currentCapture = capture
                
                // Prepare results
                let resultsCount = _currentCapture!.capturedResultsCount
                
                if (resultsCount > 0) {
                    let resultsRange = Range<Int>(start: Int(_actionResults.count - resultsCount), end: resultsCount)
                    // Read all results
                    capture.allResults = []
                    capture.allResults.reserveCapacity(resultsCount)
                    for(var i=0; i<_actionResults.count; i++) {
                        capture.allResults[i] = _actionResults[resultsRange.startIndex + i]
                    }
                    capture.nextResultIndex = 0
                    
                    // Remove results from stack
                    _actionResults.replaceRange(resultsRange, with: [])
                }
                
                var errorCode = ""
                
                let result : AnyObject? = capture.action(parser: self, text: self.yyText(capture.begin, to:capture.end), errorCode: &errorCode)
                
                // Handle errors if any
                if (errorCode != "") {
                    self.setErrorWithMessage(errorCode, location: capture.parsedRange.startIndex, length: capture.parsedRange.endIndex - capture.parsedRange.startIndex)
                    matched = false
                    break
                }
                
                // Push result
                if (result) {
                    // Set parsing range for diagnostics
                    /*
                    if ([result respondsToSelector: @selector(setSourceString:range:)])
                    [result setSourceString:_string range:capture.parsedRange];
                    */
                    
                    
                    self.pushResult(!result)
                }
            }
            
            // Provide final result if any
            if (matched && _actionResults.count > 0) {
                result = _actionResults[_actionResults.count - 1]
            }
        }
        
        // Cleanup parser
        self.string = ""
        _actionResults = []
        
        return matched
    }
    

    func performActionUsingCaptures(captures: Int, startIndex: Int, block: (parser: ParserClass, text: String, inout errorCode: String) -> AnyObject?)
    {
        let capture = ParserClassCapture()
    
        capture.begin = captureStart
        capture.end = captureEnd
    
        capture.action = block
        capture.parsedRange = Range<Int>(start: startIndex, end: _index - startIndex)
    
        capture.capturedResultsCount = captures;
    
        _captures += capture
    }
    
    /*!
    @abstract Provides a result for the current rule
    */
    func pushResult(result: AnyObject) {
        _actionResults.append(result)
    }
    
    /*!
    @abstract Accesses the next result of a sub-rule
    */
    func nextResult() -> AnyObject {        
        return _currentCapture!.allResults[_currentCapture!.nextResultIndex++]
    }
    
    /*!
    @abstract Accesses the next result of a sub-rule, if a certain result count matches.
    @discussion Returns nil otherwise.
    */
    func nextResultIfCount(count: Int) -> AnyObject? {
        if (_currentCapture!.allResults.count == count) {
            return self.nextResult()
        }
        
        return nil
    }
    
    /*!
    @abstract Accesses the next result of a sub-rule. Returns nil, if none is available
    */
    func nextResultOrNil() -> AnyObject? {
        if (_currentCapture!.allResults.count <= _currentCapture!.nextResultIndex) {
            return nil
        }
        
        return self.nextResult()
    }
    
    /*!
    @abstract Accesses the result of a sub-rule with a certain index
    */
    func resultAtIndex(index: Int) -> AnyObject {
        return _currentCapture!.allResults[index]
    }
    
    /*!
    @abstract Accesses the result of a sub-rule with a certain index. If the result does not exist, nil is returned.
    */
    func resultAtIndexIfAny(index:Int) -> AnyObject? {
        if (index > _currentCapture!.allResults.count) {
            return nil
        }
        
        return self.resultAtIndex(index);
    }
    
    /*!
    @abstract Provies all sub-rule results as array.
    */
    func allResults() -> AnyObject[] {
        return _currentCapture!.allResults
    }
    
    /*!
    @abstract Provides the count of results.
    */
    func resultCount() -> Int {
        return _currentCapture!.capturedResultsCount
    }
    
    /*!
    @abstract Provides the range of the current action
    */
    func rangeForCurrentAction() -> Range<Int> {
        return _currentCapture!.parsedRange
    }
    
    func beginCapture() {
        if (_capturing) {
            captureStart = _index
        }
    }
    
    func endCapture() {
        if (_capturing) {
            captureEnd = _index   
        }
        
    }

    func invertWithCaptures(inout localCaptures: Int, startIndex: Int, block: (parser: ParserClass, startIndex: Int, inout localCaptures: Int) -> Bool) -> Bool
    {
        var temporaryCaptures = localCaptures
    
        // We are in an error state. Just stop.
        if (_lastError) {
            return false
        }
    
        let matched = !self.matchOneWithCaptures(&temporaryCaptures, startIndex:startIndex, block: block)
        if (matched) {
            localCaptures = temporaryCaptures
        }
    
        return matched;
    }
    
    func lookAheadWithCaptures(inout localCaptures: Int, startIndex: Int, block:(parser: ParserClass, startIndex: Int, inout localCaptures: Int) -> Bool) -> Bool
    {
        let index=_index
    
        // We are in an error state. Just stop.
        if (_lastError) {
            return false
        }
    
        let capturing = _capturing
        _capturing = false
    
        var temporaryCaptures = localCaptures
    
        let matched = block(parser: self, startIndex: startIndex, localCaptures: &temporaryCaptures)
        _capturing = capturing;
        _index=index;
        _lastError = nil
    
        return matched
    }
    
    func matchDot() -> Bool
    {
        if (_index >= _limit) {
            return false
        }
    
        _index = _index + 1
        return true
    }
    
    func matchOneWithCaptures(inout localCaptures: Int, startIndex: Int, block:(parser:ParserClass, startIndex: Int, inout localCaptures:Int) -> Bool) -> Bool
    {
        // We are in an error state. Just stop.
        if (_lastError) {
            return false
        }
    
        let index = _index
        let captureCount = _captures.count
        var temporaryCaptures = localCaptures
    
        // Try to match
        if (block(parser: self, startIndex: startIndex, localCaptures: &temporaryCaptures)) {
            localCaptures = temporaryCaptures
            return true
        }
    
        // Restore old state
        _index=index
    
        if (_captures.count > captureCount) {
            _captures.replaceRange(Range<Int>(start: 0, end: captureCount), with: [])
        }
    
        return false
    }
    
    func matchManyWithCaptures(inout localCaptures: Int, startIndex: Int, block:(parser:ParserClass, startIndex: Int, inout localCaptures:Int) -> Bool) -> Bool
    {
        // We are in an error state. Just stop.
        if (_lastError) {
            return false
        }
    
        // We need at least one match
        if (!self.matchOneWithCaptures(&localCaptures, startIndex:startIndex, block: block)) {
            return false
        }
    
        // Match others
        var lastIndex = _index
    
        while (self.matchOneWithCaptures(&localCaptures, startIndex:startIndex, block: block)) {
            // The match did not consume any string, but matched. It should be something like (.*)*. So we can stop to prevent an infinite loop.
            if (_index == lastIndex) {
                break;
            }
    
            lastIndex = _index
        }
    
        return true
    }
    
    
    func matchRule(ruleName: String, startIndex: Int, asserted: Bool) -> Bool
    {
        var rule = _rules[ruleName]
        var lastIndex = _index
    
        // We are in an error state. Just stop.
        if (_lastError) {
            return false;
        }

        if(rule) {
            var localCaptures: Int = 0
            
            if (matchOneWithCaptures(&localCaptures, startIndex:_index, block:rule!)) {
                return true
            }
        } else {
            println("Couldn't find rule name \"\(ruleName)\".")
        }
        
        if (asserted) {
            setErrorWithMessage("Unmatched\(ruleName)", location:lastIndex, length:(_index - lastIndex))
        }
    
    
        return false
    }
    
    func matchString(literal:String, startIndex: Int, asserted:Bool) -> Bool
    {
        let saved = _index;
        let L = literal.utf16count
        let literal_chars = literal.utf16
        var i = 0
        while (i<L) {
            if ((_index >= _limit) || (string.utf16[_index] != literal_chars[i])) {
                _index = saved
    
                if (asserted) {
                    setErrorWithMessage("Missing:\(literal)", location:saved, length:(_index - saved + 1))
                }
    
                return false;
            }
            i = i + 1
            _index = _index + 1
        }
    
        return true
    }
    
    func matchClass(bits: Byte[]) -> Bool
    {
        if (_index >= _limit) {
            return false;
        }
    
        let c = Byte(string.utf16[_index])
        let a = Byte(1 << (c & 7))
        let b = bits[Int(c) >> 3]
        let bit = a & b
        
        if (bit != 0) {
            _index = _index + 1
            return true
        }
    
        return false;
    }
    
    func setErrorWithMessage(message: String, var location: Int, var length: Int)
    {
        if (length == 0) {
            if (location < string.utf16count) {
                length = 1;
            }
            else if (location > 0) {
                location = location - 1;
                length = 1;
            }
        }
    
        if (!_lastError) {
            _lastError = NSError.errorWithDomain(NSCocoaErrorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString(message, tableName: nil, bundle: NSBundle.mainBundle(), value: message, comment: message), ParserClassErrorTypeKey: message, ParserClassErrorStringLocationKey: location, ParserClassErrorStringLengthKey: length, ParserClassErrorStringKey: string ]);
        }
    }
    
    func clearError ()
    {
        _lastError = nil
    }
    
    let _rules = [
//!$ParserRules
    ]
    
}